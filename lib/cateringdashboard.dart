import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'vendor_prefs.dart';
import 'vendor_helpandsupport.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CateringDashboard extends StatefulWidget {
  const CateringDashboard({super.key});

  @override
  State<CateringDashboard> createState() => _CateringDashboardState();
}

class _CateringDashboardState extends State<CateringDashboard> {
  static const String baseUrl = "http://10.13.29.36:5000";

  String username = "";
  String email = "";
  String vendorType = "";
  String vendorId = "";
  String selectedCategory = ""; // ✅ added category selection

  // Controllers
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController maxPlatesController = TextEditingController();
  final TextEditingController minPlatesController = TextEditingController();
  final TextEditingController shortDescController = TextEditingController();

  // Calendar state
  Set<DateTime> availableDates = {};
  Set<DateTime> unavailableDates = {};
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime firstDay = DateTime.utc(2020, 1, 1);
  DateTime lastDay = DateTime.utc(2030, 12, 31);

  // Store Image URLs
  List<String> imageUrls = [];

  // Menus
  List<Map<String, dynamic>> vegMeals = [];
  List<Map<String, dynamic>> nonVegMeals = [];

  final ImagePicker _picker = ImagePicker();

  final List<String> categories = [
    "Full course",
    "Buffet",
    "Plated",
    "Corporate",
    "Drop off",
    "Live counter",
  ];
  Map<String, bool> selectedCategories = {};
  Map<String, TextEditingController> categoryPriceControllers = {};

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    final vendor = await VendorPrefs.getVendorData();
    setState(() {
      username = vendor["name"] ?? "";
      email = vendor["email"] ?? "";
      vendorType = vendor["vendorType"] ?? "";
      vendorId = vendor["_id"] ?? vendor["id"] ?? vendor["vendorId"] ?? "";
      businessNameController.text = vendor["businessName"] ?? "My Catering";
      cityController.text = vendor["city"] ?? "";
      mobileController.text = vendor["mobile"] ?? "";
      addressController.text = vendor["address"] ?? "";
      maxPlatesController.text = (vendor["maxPlates"] ?? "").toString();
      minPlatesController.text = (vendor["minPlates"] ?? "").toString();
      shortDescController.text = vendor["shortDescription"] ?? "";
      imageUrls = List<String>.from(vendor["images"] ?? []);
      selectedCategory = vendor["category"] ?? ""; // ✅ load saved category

      availableDates = (vendor["availableDates"] as List? ?? [])
          .map((d) => DateTime.parse(d))
          .toSet();
      unavailableDates = (vendor["unavailableDates"] as List? ?? [])
          .map((d) => DateTime.parse(d))
          .toSet();

      vegMeals = List<Map<String, dynamic>>.from(vendor["vegMeals"] ?? []);
      nonVegMeals = List<Map<String, dynamic>>.from(vendor["nonVegMeals"] ?? []);

      // Restore category selections
      final savedCategories = vendor["categories"] is Map
          ? vendor["categories"]
          : (vendor["categories"] is List
              ? Map<String, int>.fromIterable(
                  vendor["categories"], key: (e) => e, value: (_) => 0)
              : {});
      for (var c in categories) {
        selectedCategories[c] = savedCategories.containsKey(c);
        categoryPriceControllers[c] =
            TextEditingController(text: savedCategories[c]?.toString() ?? "");
      }
    });
  }

  void toggleDate(DateTime day) {
    setState(() {
      if (availableDates.any((d) => isSameDay(d, day))) {
        availableDates.removeWhere((d) => isSameDay(d, day));
        unavailableDates.add(day);
      } else if (unavailableDates.any((d) => isSameDay(d, day))) {
        unavailableDates.removeWhere((d) => isSameDay(d, day));
      } else {
        availableDates.add(day);
      }
    });
  }

  // ✅ Update details (now includes category)
  Future<void> _updateCateringDetails() async {
    // Collect categories with prices
    Map<String, int> providedCategories = {};
    for (var c in categories) {
      if (selectedCategories[c] == true) {
        providedCategories[c] =
            int.tryParse(categoryPriceControllers[c]?.text ?? "0") ?? 0;
      }
    }

    final body = {
      "vendorId": vendorId,
      "cateringName": businessNameController.text,
      "city": cityController.text,
      "address": addressController.text,
      "phone": mobileController.text,
      "maxPlates": int.tryParse(maxPlatesController.text) ?? 0,
      "minPlates": int.tryParse(minPlatesController.text) ?? 0,
      "shortDescription": shortDescController.text,
      "availableDates": availableDates.map((d) => d.toIso8601String()).toList(),
      "unavailableDates": unavailableDates.map((d) => d.toIso8601String()).toList(),
      "images": imageUrls,
      "vegMeals": vegMeals,
      "nonVegMeals": nonVegMeals,
      "categories": providedCategories, // <-- send categories as map
    };

    final response = await http.put(
      Uri.parse("$baseUrl/api/caterings/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final data = jsonDecode(response.body);
        final catering = data["catering"] ?? {};
        final newVendorId =
            catering["vendorId"] ?? catering["vendorld"] ?? vendorId;

        await VendorPrefs.saveVendorData({
          "_id": newVendorId,
          "name": username,
          "email": email,
          "vendorType": vendorType,
          "cateringName": businessNameController.text,
          "city": cityController.text,
          "mobile": mobileController.text,
          "address": addressController.text,
          "maxPlates": int.tryParse(maxPlatesController.text) ?? 0,
          "minPlates": int.tryParse(minPlatesController.text) ?? 0,
          "shortDescription": shortDescController.text,
          "availableDates":
              availableDates.map((d) => d.toIso8601String()).toList(),
          "unavailableDates":
              unavailableDates.map((d) => d.toIso8601String()).toList(),
          "images": imageUrls,
          "vegMeals": vegMeals,
          "nonVegMeals": nonVegMeals,
          "categories": providedCategories, // <-- save locally
        });
      } catch (e) {
        await VendorPrefs.saveVendorData({
          "_id": vendorId,
          "name": username,
          "email": email,
          "vendorType": vendorType,
          "cateringName": businessNameController.text,
          "city": cityController.text,
          "mobile": mobileController.text,
          "address": addressController.text,
          "maxPlates": int.tryParse(maxPlatesController.text) ?? 0,
          "minPlates": int.tryParse(minPlatesController.text) ?? 0,
          "shortDescription": shortDescController.text,
          "availableDates":
              availableDates.map((d) => d.toIso8601String()).toList(),
          "unavailableDates":
              unavailableDates.map((d) => d.toIso8601String()).toList(),
          "images": imageUrls,
          "vegMeals": vegMeals,
          "nonVegMeals": nonVegMeals,
          "categories": providedCategories,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Catering updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: ${response.body}")),
      );
    }
  }

  // ✅ Category section
  Widget buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Catering Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...categories.map((c) {
          return Row(
            children: [
              Checkbox(
                value: selectedCategories[c] ?? false,
                onChanged: (val) {
                  setState(() {
                    selectedCategories[c] = val ?? false;
                  });
                },
              ),
              Expanded(child: Text(c)),
              if (selectedCategories[c] == true)
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: categoryPriceControllers[c],
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Price",
                      isDense: true,
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }
  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    File imageFile = File(picked.path);

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/api/upload/catering"),
    );
    request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));
    var response = await request.send();

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = jsonDecode(respStr);

      setState(() {
        imageUrls.add(data["url"]);
      });

      final vendor = await VendorPrefs.getVendorData();
      vendor["images"] = imageUrls;
      await VendorPrefs.saveVendorData(vendor);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image uploaded")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: ${response.statusCode}")),
      );
    }
  }

  void _deleteImage(int index) async {
    final imageUrl = imageUrls[index];

    final vendor = await VendorPrefs.getVendorData();
    final vId = (vendor["_id"] ??
            vendor["id"] ??
            vendor["vendorId"] ??
            vendorId)
        ?.toString();

    if (vId == null || vId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed: Missing vendorId")),
      );
      return;
    }

    final uri = Uri.parse(
        "$baseUrl/api/upload/catering/$vId?imageUrl=${Uri.encodeComponent(imageUrl)}");

    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      setState(() {
        imageUrls.removeAt(index);
      });

      vendor["images"] = imageUrls;
      await VendorPrefs.saveVendorData(vendor);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image deleted")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: ${response.body}")),
      );
    }
  }

  // ---------- UI Builders ----------

  Widget buildCalendar() {
    return Column(
      children: [
        TableCalendar(
          firstDay: firstDay,
          lastDay: lastDay,
          focusedDay: focusedDay,
          calendarFormat: calendarFormat,
          selectedDayPredicate: (_) => false,
          onDaySelected: (selectedDay, focusedDay) {
            toggleDate(selectedDay);
            setState(() {
              this.focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            this.focusedDay = focusedDay;
          },
          calendarBuilders: CalendarBuilders(
            defaultBuilder: (context, day, focusedDay) {
              if (availableDates.any((d) => isSameDay(d, day))) {
                return _buildCalendarCell(day, Colors.green);
              } else if (unavailableDates.any((d) => isSameDay(d, day))) {
                return _buildCalendarCell(day, Colors.red);
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 4),
            Text("Available"),
            SizedBox(width: 16),
            Icon(Icons.cancel, color: Colors.red),
            SizedBox(width: 4),
            Text("Unavailable"),
          ],
        )
      ],
    );
  }

  Widget _buildCalendarCell(DateTime day, Color color) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          "${day.day}",
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildMealsSection(String type) {
  List<Map<String, dynamic>> Meals = type == "veg" ? vegMeals : nonVegMeals;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            type == "veg" ? "Veg Meals" : "Non-Veg Meals",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.red),
            onPressed: () => _showAddMealsDialog(type),
          )
        ],
      ),
      ...Meals.map((menu) => Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              title: Text(menu["mealName"]),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Items: ${menu["items"].join(", ")}"),
                  Text("Price: ₹${menu["price"]}"),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditMealsDialog(type, menu),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        Meals.remove(menu);
                      });
                    },
                  ),
                ],
              ),
            ),
          ))
    ],
  );
}

void _showAddMealsDialog(String type) {
  final TextEditingController menuNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  List<String> items = [];
  final TextEditingController itemNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: const Text("Add Meal"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: menuNameController,
                  decoration: const InputDecoration(labelText: "Meal Name"),
                ),
                const SizedBox(height: 10),
                ...items.map((item) => ListTile(title: Text(item))),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: itemNameController,
                        decoration: const InputDecoration(hintText: "Item"),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (itemNameController.text.isNotEmpty) {
                          setStateDialog(() {
                            items.add(itemNameController.text);
                            itemNameController.clear();
                          });
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Meal Price"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (menuNameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  setState(() {
                    final newMenu = {
                      "mealName": menuNameController.text,
                      "items": items,
                      "price": int.tryParse(priceController.text) ?? 0,
                    };
                    if (type == "veg") {
                      vegMeals.add(newMenu);
                    } else {
                      nonVegMeals.add(newMenu);
                    }
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"),
            )
          ],
        );
      });
    },
  );
}

void _showEditMealsDialog(String type, Map<String, dynamic> menu) {
  final TextEditingController menuNameController =
      TextEditingController(text: menu["mealName"]);
  final TextEditingController priceController =
      TextEditingController(text: menu["price"].toString());
  List<String> items = List<String>.from(menu["items"]);
  final TextEditingController itemNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          title: const Text("Edit Meal"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: menuNameController,
                  decoration: const InputDecoration(labelText: "Meal Name"),
                ),
                const SizedBox(height: 10),
                ...items.map((item) => ListTile(
                      title: Text(item),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setStateDialog(() {
                            items.remove(item);
                          });
                        },
                      ),
                    )),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: itemNameController,
                        decoration: const InputDecoration(hintText: "Add Item"),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        if (itemNameController.text.isNotEmpty) {
                          setStateDialog(() {
                            items.add(itemNameController.text);
                            itemNameController.clear();
                          });
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Meal Price"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  menu["mealName"] = menuNameController.text;
                  menu["items"] = items;
                  menu["price"] = int.tryParse(priceController.text) ?? 0;
                });
                Navigator.pop(context);
              },
              child: const Text("Save Changes"),
            )
          ],
        );
      });
    },
  );
}


  Widget buildCateringDetails() {
    return Column(
      children: [
        TextField(
          controller: businessNameController,
          decoration: const InputDecoration(
              labelText: "Catering Name", prefixIcon: Icon(Icons.business)),
        ),
        TextField(
          controller: cityController,
          decoration: const InputDecoration(
              labelText: "City", prefixIcon: Icon(Icons.location_city)),
        ),
        TextField(
          controller: mobileController,
          decoration: const InputDecoration(
              labelText: "Phone", prefixIcon: Icon(Icons.phone)),
        ),
        TextField(
          controller: addressController,
          decoration: const InputDecoration(
              labelText: "Address", prefixIcon: Icon(Icons.home)),
        ),
        TextField(
          controller: maxPlatesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: "Max Plates", prefixIcon: Icon(Icons.restaurant)),
        ),
        TextField(
          controller: minPlatesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: "Min Plates", prefixIcon: Icon(Icons.restaurant_menu)),
        ),
        TextField(
          controller: shortDescController,
          decoration: const InputDecoration(
              labelText: "Short Description",
              prefixIcon: Icon(Icons.description)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _updateCateringDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Update Changes",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
      ],
    );
  }

  Widget buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upload Catering Images",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: [
            GestureDetector(
              onTap: _pickAndUploadImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.add_a_photo, size: 40, color: Colors.red),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Visual fallback for errors (e.g., 403, host unreachable)
                              return Container(
                                color: Colors.black12,
                                alignment: Alignment.center,
                                child: const Icon(Icons.broken_image, color: Colors.red),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _deleteImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.close,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        elevation: 0,
        title: const Text(
          "Catering Dashboard",
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.red),
              accountName: Text(
                  username.isNotEmpty ? username : businessNameController.text),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.store, size: 40, color: Colors.red),
              ),
            ),
            ListTile(
                leading: const Icon(Icons.phone),
                title: Text(mobileController.text)),
            ListTile(
                leading: const Icon(Icons.help_outline, color: Colors.red),
                title: const Text("Help & Support"),
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VendorHelpSupportPage(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildCalendar(),
            const SizedBox(height: 20),
            buildCategorySection(), // <-- add here
            const SizedBox(height: 20),
            buildMealsSection("veg"),
            const SizedBox(height: 20),
            buildMealsSection("nonveg"),
            const SizedBox(height: 20),
            buildCateringDetails(),
            const SizedBox(height: 20),
            buildImageUploadSection(),
          ],
        ),
      ),
    );
  }
}
