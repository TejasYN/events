import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'vendor_prefs.dart';
import 'vendor_helpandsupport.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VenueDashboard extends StatefulWidget {
  const VenueDashboard({super.key});

  @override
  State<VenueDashboard> createState() => _VenueDashboardState();
}

class _VenueDashboardState extends State<VenueDashboard> {
  static const String baseUrl = "http://10.13.29.36:5000";
  String username = "";
  String gstin = "";
  String fssai = "";
  String email = "";
  String vendorType = "";

  // Controllers
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController seatsController = TextEditingController();
  final TextEditingController shortDescController = TextEditingController();

  // Calendar state
  Set<DateTime> availableDates = {};
  Set<DateTime> unavailableDates = {};
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime firstDay = DateTime.utc(2020, 1, 1);
  DateTime lastDay = DateTime.utc(2030, 12, 31);

  String vendorId = "";
  List<String> imageUrls = []; // ✅ store uploaded images

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    final vendor = await VendorPrefs.getVendorData();
    setState(() {
      username = vendor["name"] ?? "";
      businessNameController.text = vendor["businessName"] ?? "My Venue";
      gstin = vendor["gstin"] ?? "";
      fssai = vendor["fssai"] ?? "";
      email = vendor["email"] ?? "";
      mobileController.text = vendor["mobile"] ?? "";
      cityController.text = vendor["city"] ?? "";
      vendorType = vendor["vendorType"] ?? "";

      addressController.text = vendor["address"] ?? "";
      priceController.text = vendor["price"]?.toString() ?? "";
      seatsController.text = vendor["seats"]?.toString() ?? "";
      shortDescController.text = vendor["shortDescription"] ?? "";
      vendorId = vendor["_id"] ?? vendor["id"] ?? vendor["vendorId"] ?? "";
      imageUrls = List<String>.from(vendor["images"] ?? []);
      selectedSubcategory = vendor["subcategory"] ?? "";

      availableDates = (vendor["availableDates"] as List? ?? [])
          .map((d) => DateTime.parse(d))
          .toSet();
      unavailableDates = (vendor["unavailableDates"] as List? ?? [])
          .map((d) => DateTime.parse(d))
          .toSet();
    });

    setState(() {});
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

  Future<void> _updateVenueDetails() async {
    final body = {
      "vendorId": vendorId,
      "venueName": businessNameController.text,
      "city": cityController.text,
      "address": addressController.text,
      "phone": mobileController.text,
      "price": int.tryParse(priceController.text) ?? 0,
      "seats": int.tryParse(seatsController.text) ?? 0,
      "shortDescription": shortDescController.text,
      "availableDates":
          availableDates.map((d) => d.toIso8601String()).toList(),
      "unavailableDates":
          unavailableDates.map((d) => d.toIso8601String()).toList(),
      "images": imageUrls, // ✅ send images to backend
      "subcategory": selectedSubcategory,
    };

    final response = await http.put(
      Uri.parse("$baseUrl/api/venues/update"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Try to parse the response and extract the correct vendorId if created
      try {
        final data = jsonDecode(response.body);
        final venue = data["venue"] ?? {};
        final newVendorId = venue["vendorId"] ?? venue["vendorld"] ?? vendorId;
        await VendorPrefs.saveVendorData({
          "_id": newVendorId,
          "name": username,
          "businessName": businessNameController.text,
          "gstin": gstin,
          "fssai": fssai,
          "email": email,
          "mobile": mobileController.text,
          "city": cityController.text,
          "vendorType": vendorType,
          "address": addressController.text,
          "price": int.tryParse(priceController.text) ?? 0,
          "seats": int.tryParse(seatsController.text) ?? 0,
          "shortDescription": shortDescController.text,
          "availableDates":
              availableDates.map((d) => d.toIso8601String()).toList(),
          "unavailableDates":
              unavailableDates.map((d) => d.toIso8601String()).toList(),
          "images": imageUrls,
          "subcategory": selectedSubcategory,
        });
      } catch (e) {
        // fallback if response is not as expected
        await VendorPrefs.saveVendorData({
          "_id": vendorId,
          "name": username,
          "businessName": businessNameController.text,
          "gstin": gstin,
          "fssai": fssai,
          "email": email,
          "mobile": mobileController.text,
          "city": cityController.text,
          "vendorType": vendorType,
          "address": addressController.text,
          "price": int.tryParse(priceController.text) ?? 0,
          "seats": int.tryParse(seatsController.text) ?? 0,
          "shortDescription": shortDescController.text,
          "availableDates":
              availableDates.map((d) => d.toIso8601String()).toList(),
          "unavailableDates":
              unavailableDates.map((d) => d.toIso8601String()).toList(),
          "images": imageUrls,
          "subcategory": selectedSubcategory,
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Venue updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: ${response.body}")),
      );
    }
  }

String selectedSubcategory = "";
final List<String> subcategories = [
  "Marriage Hall",
  "party Hall",
  "Banquet Hall",
  "Community Hall",
  "Lawn",
  "Convention and Exhibition center",
  "Lounges / Pub / Club",
  "Convention Hotel",
];

Widget buildSubcategorySection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Select Subcategory",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: subcategories.contains(selectedSubcategory) ? selectedSubcategory : null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          hintText: "Choose a subcategory",
        ),
      items: subcategories.map((String sub) {
        return DropdownMenuItem<String>(
          value: sub,
          child: Text(sub),
        );
      }).toList(),
    onChanged: (val) {
      setState(() {
        selectedSubcategory = val ?? "";
          });
        },
      ),
    ],
  );
}

  Future<void> _pickAndUploadImage() async {
  final picked = await _picker.pickImage(source: ImageSource.gallery);
  if (picked == null) return;

  File imageFile = File(picked.path);

  var request = http.MultipartRequest(
    "POST",
    Uri.parse("$baseUrl/api/upload/venues"),
  );
  request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));
  var response = await request.send();

  if (response.statusCode == 200) {
    final respStr = await response.stream.bytesToString();
    final data = jsonDecode(respStr);

    setState(() {
      imageUrls.add(data["url"]);
    });

    // ✅ Update VendorPrefs instantly
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

    // Resolve vendorId robustly from local state or stored vendor data
    final vendor = await VendorPrefs.getVendorData();
    final vId = (vendor["_id"] ?? vendor["id"] ?? vendor["vendorId"] ?? vendorId)?.toString();

    if (vId == null || vId.isEmpty || vId == 'null' || vId == 'undefined') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete failed: Missing vendorId")),
      );
      return;
    }

    // Build URI to ensure imageUrl is URL-encoded
    final uri = Uri.parse("$baseUrl/api/upload/venues/$vId?imageUrl=${Uri.encodeComponent(imageUrl)}");


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
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Upload Venue Images",
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
                child: const Icon(Icons.add_a_photo,
                    size: 40, color: Colors.red),
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

  Widget buildVenueDetails() {
    return Column(
      children: [
        TextField(
          controller: businessNameController,
          decoration: const InputDecoration(
              labelText: "Venue Name", prefixIcon: Icon(Icons.business)),
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
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: "Price", prefixIcon: Icon(Icons.money)),
        ),
        TextField(
          controller: seatsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: "Number of Seats",
              prefixIcon: Icon(Icons.event_seat)),
        ),
        TextField(
          controller: shortDescController,
          decoration: const InputDecoration(
              labelText: "Short Description",
              prefixIcon: Icon(Icons.description)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _updateVenueDetails,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red[700],
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Update Changes",
              style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        elevation: 0,
        title: const Text(
          "Venue Dashboard",
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
            buildImageUploadSection(),
            const SizedBox(height: 20),
            buildSubcategorySection(),
            const SizedBox(height: 20),
            buildVenueDetails(),
          ],
        ),
      ),
    );
  }
}
