import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CateringPage extends StatefulWidget {
  const CateringPage({super.key});

  @override
  State<CateringPage> createState() => _CateringPageState();
}

class _CateringPageState extends State<CateringPage> {
  List<dynamic> _caterings = [];
  List<dynamic> _filteredCaterings = [];
  bool _loading = true;

  // Filters
  Set<String> selectedCities = {};
  Set<String> selectedServices = {};
  Set<String> selectedPlates = {};

  final List<String> cities = [
    'Mumbai', 'Delhi', 'Bengaluru', 'Hyderabad',
    'Chennai', 'Kolkata', 'Pune', 'Ahmedabad'
  ];

  final List<String> serviceTypes = [
    "Full course",
    "Buffet",
    "Plated",
    "Corporate",
    "Drop off",
    "Live counter"
  ];

  final List<Map<String, dynamic>> plateOptions = [
    {"label": "500 or less", "id": "<=500"},
    {"label": "1000 or less", "id": "<=1000"},
    {"label": "2500 or less", "id": "<=2500"},
    {"label": "2500 or more", "id": ">=2500"},
  ];

  @override
  void initState() {
    super.initState();
    fetchCaterings();
  }

  Future<void> fetchCaterings() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse("http://10.13.29.36:5000/api/caterings/all"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _caterings = data;
          _filteredCaterings = data;
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  void applyFilters() {
    setState(() {
      _filteredCaterings = _caterings.where((catering) {
        final cityMatch = selectedCities.isEmpty || selectedCities.contains(catering["city"]);
        final services = (catering["categories"] as Map?)?.keys.toList() ?? [];
        final serviceMatch = selectedServices.isEmpty ||
            services.any((s) => selectedServices.contains(s.toString()));
        final plateMatch = selectedPlates.isEmpty || _matchPlates(catering, selectedPlates);
        return cityMatch && serviceMatch && plateMatch;
      }).toList();
    });
  }

  bool _matchPlates(dynamic catering, Set<String> selections) {
    final maxPlates = (catering["maxPlates"] ?? 0) as num;
    for (var id in selections) {
      if (id == "<=500" && maxPlates <= 500) return true;
      if (id == "<=1000" && maxPlates <= 1000) return true;
      if (id == "<=2500" && maxPlates <= 2500) return true;
      if (id == ">=2500" && maxPlates >= 2500) return true;
    }
    return false;
  }

  void clearAllFilters() {
    setState(() {
      selectedCities.clear();
      selectedServices.clear();
      selectedPlates.clear();
      _filteredCaterings = List.from(_caterings);
    });
  }

  void openFilterSheet(String filterType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return StatefulBuilder(builder: (context, sheetSetState) {
          Widget buildOptionsList(List<Widget> children) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Select $filterType",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  SizedBox(height: 300, child: ListView(children: children)),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Apply Filters", style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          }

          if (filterType == "City") {
            final options = cities.map((city) {
              final checked = selectedCities.contains(city);
              return CheckboxListTile(
                title: Text(city),
                value: checked,
                onChanged: (val) => sheetSetState(() {
                  if (val == true) selectedCities.add(city);
                  else selectedCities.remove(city);
                }),
              );
            }).toList();
            return buildOptionsList(options);
          } else if (filterType == "Service Type") {
            final options = serviceTypes.map((type) {
              final checked = selectedServices.contains(type);
              return CheckboxListTile(
                title: Text(type),
                value: checked,
                onChanged: (val) => sheetSetState(() {
                  if (val == true) selectedServices.add(type);
                  else selectedServices.remove(type);
                }),
              );
            }).toList();
            return buildOptionsList(options);
          } else if (filterType == "Plates") {
            final options = plateOptions.map((opt) {
              final checked = selectedPlates.contains(opt["id"]);
              return CheckboxListTile(
                title: Text(opt["label"]),
                value: checked,
                onChanged: (val) => sheetSetState(() {
                  if (val == true) selectedPlates.add(opt["id"]);
                  else selectedPlates.remove(opt["id"]);
                }),
              );
            }).toList();
            return buildOptionsList(options);
          }

          return const SizedBox.shrink();
        });
      },
    );
  }

  bool isFilterActive(String label) {
    if (label == "City") return selectedCities.isNotEmpty;
    if (label == "Service Type") return selectedServices.isNotEmpty;
    if (label == "Plates") return selectedPlates.isNotEmpty;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/epbg.jpg", fit: BoxFit.cover),
          ),
          Column(
            children: [
              // Header
              Container(
                height: 90,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.redAccent, Color(0xFF8B0000)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Catering Services",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Filter bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      filterButton("City"),
                      const SizedBox(width: 8),
                      filterButton("Service Type"),
                      const SizedBox(width: 8),
                      filterButton("Plates"),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => clearAllFilters(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        child: const Text("Clear"),
                      ),
                    ],
                  ),
                ),
              ),

              // List of caterings
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredCaterings.isEmpty
                        ? const Center(child: Text("No catering services found"))
                        : ListView.builder(
                            itemCount: _filteredCaterings.length,
                            itemBuilder: (context, index) {
                              final catering = _filteredCaterings[index];
                              final imageUrl = (catering["images"] != null &&
                                      catering["images"].isNotEmpty)
                                  ? catering["images"][0]
                                  : "https://via.placeholder.com/150";

                              final categories = (catering["categories"] ?? {}) as Map;

                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(16)),
                                      child: Image.network(
                                        imageUrl,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 180,
                                          color: Colors.grey[200],
                                          child: const Center(
                                              child: Icon(Icons.broken_image)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            catering["cateringName"] ??
                                                "Unnamed Catering",
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            catering["shortDescription"] ?? "",
                                            style: const TextStyle(
                                                color: Colors.grey),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  color: Colors.red, size: 18),
                                              const SizedBox(width: 4),
                                              Text(catering["city"] ??
                                                  "Unknown City"),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                                "${catering["maxPlates"] ?? 0} plates"),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Additional Prices:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          ...categories.entries.map((entry) {
                                            return Text(
                                                "• ${entry.key}: ₹${entry.value}");
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget filterButton(String label) {
    final active = isFilterActive(label);
    return ElevatedButton(
      onPressed: () => openFilterSheet(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Colors.redAccent : Colors.white.withOpacity(0.9),
        foregroundColor: active ? Colors.white : Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      child: Text(label),
    );
  }
}
