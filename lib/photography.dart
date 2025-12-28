import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PhotographyPage extends StatefulWidget {
  const PhotographyPage({super.key});

  @override
  State<PhotographyPage> createState() => _PhotographyPageState();
}

class _PhotographyPageState extends State<PhotographyPage> {
  List<dynamic> _photographers = [];
  List<dynamic> _filteredPhotographers = [];
  bool _loading = true;

  // Filters
  Set<String> selectedCities = {};
  Set<String> selectedCategories = {};
  Set<String> selectedExperience = {};

  final List<String> cities = [
    'Mumbai', 'Delhi', 'Bengaluru', 'Hyderabad',
    'Chennai', 'Kolkata', 'Pune', 'Ahmedabad'
  ];

  final List<String> categoryTypes = [
    "Wedding",
    "Candid",
    "Traditional",
    "Drone",
    "Corporate",
    "Event",
    "Fashion"
  ];

  final List<Map<String, dynamic>> experienceOptions = [
    {"label": "5 years or less", "id": "<=5"},
    {"label": "10 years or less", "id": "<=10"},
    {"label": "10 years or more", "id": ">=10"},
  ];

  @override
  void initState() {
    super.initState();
    fetchPhotographers();
  }

  Future<void> fetchPhotographers() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse("http://10.13.29.36:5000/api/photography/all"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _photographers = data;
          _filteredPhotographers = data;
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
      _filteredPhotographers = _photographers.where((p) {
        final cityMatch = selectedCities.isEmpty || selectedCities.contains(p["city"]);
        final categories = (p["categories"] as Map?)?.keys.toList() ?? [];
        final categoryMatch = selectedCategories.isEmpty ||
            categories.any((c) => selectedCategories.contains(c.toString()));
        final experienceMatch = selectedExperience.isEmpty || _matchExperience(p, selectedExperience);
        return cityMatch && categoryMatch && experienceMatch;
      }).toList();
    });
  }

  bool _matchExperience(dynamic p, Set<String> selections) {
    final experience = (p["experience"] ?? 0) as num;
    for (var id in selections) {
      if (id == "<=5" && experience <= 5) return true;
      if (id == "<=10" && experience <= 10) return true;
      if (id == ">=10" && experience >= 10) return true;
    }
    return false;
  }

  void clearAllFilters() {
    setState(() {
      selectedCities.clear();
      selectedCategories.clear();
      selectedExperience.clear();
      _filteredPhotographers = List.from(_photographers);
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
          } else if (filterType == "Category") {
            final options = categoryTypes.map((cat) {
              final checked = selectedCategories.contains(cat);
              return CheckboxListTile(
                title: Text(cat),
                value: checked,
                onChanged: (val) => sheetSetState(() {
                  if (val == true) selectedCategories.add(cat);
                  else selectedCategories.remove(cat);
                }),
              );
            }).toList();
            return buildOptionsList(options);
          } else if (filterType == "Experience") {
            final options = experienceOptions.map((opt) {
              final checked = selectedExperience.contains(opt["id"]);
              return CheckboxListTile(
                title: Text(opt["label"]),
                value: checked,
                onChanged: (val) => sheetSetState(() {
                  if (val == true) selectedExperience.add(opt["id"]);
                  else selectedExperience.remove(opt["id"]);
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
    if (label == "Category") return selectedCategories.isNotEmpty;
    if (label == "Experience") return selectedExperience.isNotEmpty;
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
                    "Photography Studios",
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
                      filterButton("Category"),
                      const SizedBox(width: 8),
                      filterButton("Experience"),
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

              // List of photographers
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredPhotographers.isEmpty
                        ? const Center(child: Text("No photographers found"))
                        : ListView.builder(
                            itemCount: _filteredPhotographers.length,
                            itemBuilder: (context, index) {
                              final photo = _filteredPhotographers[index];
                              final imageUrl = (photo["images"] != null && photo["images"].isNotEmpty)
                                  ? photo["images"][0]
                                  : "https://via.placeholder.com/150";

                              final categories = (photo["categories"] ?? {}) as Map;

                              return Card(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: Image.network(
                                        imageUrl,
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          height: 180,
                                          color: Colors.grey[200],
                                          child: const Center(child: Icon(Icons.broken_image)),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            photo["studioName"] ?? "Unnamed Studio",
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            photo["shortDescription"] ?? "",
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, color: Colors.red, size: 18),
                                              const SizedBox(width: 4),
                                              Text(photo["city"] ?? "Unknown City"),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text("${photo["experience"] ?? 0} years experience"),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text(
                                            "Categories:",
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          ...categories.entries.map((entry) {
                                            return Text("• ${entry.key}: ₹${entry.value}");
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
