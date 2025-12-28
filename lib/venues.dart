import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VenuesPage extends StatefulWidget {
  const VenuesPage({super.key});

  @override
  State<VenuesPage> createState() => _VenuesPageState();
}

class _VenuesPageState extends State<VenuesPage> {
  List<dynamic> _venues = [];
  List<dynamic> _filteredVenues = [];
  bool _loading = true;

  // allow multiple selections
  Set<String> selectedCities = {};
  Set<String> selectedTypes = {};
  Set<String> selectedSeats = {};
  Set<String> selectedPrices = {};
 

  final List<String> cities = [
    'Mumbai', 'Delhi', 'Bengaluru', 'Hyderabad',
    'Chennai', 'Kolkata', 'Pune', 'Ahmedabad'
  ];

  final List<String> venueTypes = [
    "Marriage Hall",
    "Party Hall",
    "Banquet Hall",
    "Community Hall",
    "Lawn",
    "Convention and Exhibition Center",
    "Lounges / Pub / Club",
    "Convention Hotel"
  ];

  // seats options (now "2000 or more")
  final List<Map<String, dynamic>> seatOptions = [
    {"label": "500 or less", "id": "<=500"},
    {"label": "1000 or less", "id": "<=1000"},
    {"label": "2000 or less", "id": "<=2000"},
    {"label": "2000 or more", "id": ">=2000"},
  ];

  // price presets requested
  final List<Map<String, dynamic>> priceOptions = [
    {"label": "25000 or less", "id": "<=25000"},
    {"label": "50000 or less", "id": "<=50000"},
    {"label": "100000 or less", "id": "<=100000"},
    {"label": "100000 or more", "id": ">=100000"},
  ];

  @override
  void initState() {
    super.initState();
    fetchVenues();
  }

  Future<void> fetchVenues() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(Uri.parse("http://10.13.29.36:5000/api/venues/all"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _venues = data;
          _filteredVenues = data;
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
      _filteredVenues = _venues.where((venue) {
        final cityMatch = selectedCities.isEmpty || selectedCities.contains(venue["city"]);

        // Use subcategory if venueType missing, compare case-insensitively
        final venueTypeValue = ((venue["venueType"] ?? venue["subcategory"]) ?? "")
            .toString()
            .toLowerCase()
            .trim();
        final typeMatch = selectedTypes.isEmpty ||
            selectedTypes.any((sel) => sel.toString().toLowerCase().trim() == venueTypeValue);

        final seatsMatch = selectedSeats.isEmpty || _matchSeats(venue, selectedSeats);
        final priceMatch = selectedPrices.isEmpty || _matchPrice(venue, selectedPrices);

        return cityMatch && typeMatch && seatsMatch && priceMatch;
      }).toList();
    });
  }

  bool _matchSeats(dynamic venue, Set<String> selections) {
    final seats = (venue["seats"] ?? 0) as num;
    for (var id in selections) {
      if (id == "<=500" && seats <= 500) return true;
      if (id == "<=1000" && seats <= 1000) return true;
      if (id == "<=2000" && seats <= 2000) return true; // <-- added
      if (id == ">=2000" && seats >= 2000) return true;
    }
    return false;
  }

  bool _matchPrice(dynamic venue, Set<String> selections) {
    final price = double.tryParse((venue["price"] ?? 0).toString()) ?? 0;
    for (var id in selections) {
      if (id == "<=25000" && price <= 25000) return true;
      if (id == "<=50000" && price <= 50000) return true;
      if (id == "<=100000" && price <= 100000) return true;
      if (id == ">=100000" && price >= 100000) return true;
    }
    return false;
  }

  void clearAllFilters() {
    setState(() {
      selectedCities.clear();
      selectedTypes.clear();
      selectedSeats.clear();
      selectedPrices.clear();
      _filteredVenues = List.from(_venues);
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
                left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Select $filterType", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
          } else if (filterType == "Venue Type") {
            final options = venueTypes.map((t) {
              final checked = selectedTypes.contains(t);
              return CheckboxListTile(
                title: Text(t),
                value: checked,
                onChanged: (val) => sheetSetState(() {
                  if (val == true) selectedTypes.add(t);
                  else selectedTypes.remove(t);
                }),
              );
            }).toList();
            return buildOptionsList(options);
          } else if (filterType == "Seats") {
            final options = seatOptions.map((opt) {
              final checked = selectedSeats.contains(opt["id"]);
              return CheckboxListTile(
                title: Text(opt["label"]),
                value: checked,
                onChanged: (val) => sheetSetState(() {
                  if (val == true) selectedSeats.add(opt["id"]);
                  else selectedSeats.remove(opt["id"]);
                }),
              );
            }).toList();
            return buildOptionsList(options);
          } else if (filterType == "Price") {
            final options = priceOptions.map((opt) {
              final checked = selectedPrices.contains(opt["id"]);
              return CheckboxListTile(
                title: Text(opt["label"]),
                value: checked,
                onChanged: (val) => sheetSetState(() {
                  if (val == true) selectedPrices.add(opt["id"]);
                  else selectedPrices.remove(opt["id"]);
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
    if (label == "Venue Type") return selectedTypes.isNotEmpty;
    if (label == "Seats") return selectedSeats.isNotEmpty;
    if (label == "Price") return selectedPrices.isNotEmpty;
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
                    "Venues",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),

              // Filter bar - horizontally scrollable to avoid overflow, Clear at end
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      filterButton("City"),
                      const SizedBox(width: 8),
                      filterButton("Venue Type"),
                      const SizedBox(width: 8),
                      filterButton("Seats"),
                      const SizedBox(width: 8),
                      filterButton("Price"),
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

              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredVenues.isEmpty
                        ? const Center(child: Text("No venues found"))
                        : ListView.builder(
                            itemCount: _filteredVenues.length,
                            itemBuilder: (context, index) {
                              final venue = _filteredVenues[index];
                              final imageUrl = (venue["images"] != null && venue["images"].isNotEmpty)
                                  ? venue["images"][0]
                                  : "https://via.placeholder.com/150";

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
                                            venue["venueName"] ?? "Unnamed Venue",
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            venue["shortDescription"] ?? "",
                                            style: const TextStyle(color: Colors.grey),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, color: Colors.red, size: 18),
                                              const SizedBox(width: 4),
                                              Text(venue["city"] ?? "Unknown City"),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[100],
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text("${venue["seats"] ?? 0} seats"),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            "₹${venue["price"] ?? 0}",
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red,
                                            ),
                                          ),
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
