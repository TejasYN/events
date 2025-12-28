import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'vendor_prefs.dart';
import 'vendorlogin.dart';
import 'venuedashboard.dart';
import 'cateringdashboard.dart';
import 'photographydashboard.dart';
import 'decorationdashboard.dart';
import 'musicdashboard.dart';
import 'makeupdashboard.dart';

class VendorSignupPage extends StatefulWidget {
  const VendorSignupPage({super.key});

  @override
  VendorSignupPageState createState() => VendorSignupPageState();
}

class VendorSignupPageState extends State<VendorSignupPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedVendorType;
  String? selectedLocation;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController businessController = TextEditingController();
  final TextEditingController gstinController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController fssaiController = TextEditingController();

  final List<String> vendorTypes = [
    'Venue',
    'Music',
    'Decorations',
    'Catering',
    'Photography',
    'Makeup',
  ];

  final List<String> metroCities = [
    'Mumbai',
    'Delhi',
    'Bengaluru',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
  ];

  @override
  void dispose() {
    nameController.dispose();
    businessController.dispose();
    gstinController.dispose();
    mobileController.dispose();
    emailController.dispose();
    fssaiController.dispose();
    super.dispose();
  }

  Future<void> _registerVendor() async {
  if (!_formKey.currentState!.validate()) return;

  final vendorData = {
    "name": nameController.text.trim(),
    "businessName": businessController.text.trim(),
    "gstin": gstinController.text.trim(),
    "city": selectedLocation,
    "mobile": mobileController.text.trim(),
    "email": emailController.text.trim(),
    "vendorType": selectedVendorType,
    if (selectedVendorType == "Catering")
      "fssai": fssaiController.text.trim(),
  };

  try {
    final res = await http.post(
      Uri.parse("http://10.13.29.36:5000/api/vendors/register"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(vendorData),
    );

    final data = json.decode(res.body);

    if (res.statusCode == 200 || res.statusCode == 201) {
      final vendor = data["vendor"]; // ✅ get vendor with _id from backend

      // ✅ Save vendor data locally (including _id)
      await VendorPrefs.saveVendorData({
        "_id": vendor["_id"], // ✅ store id here
        "name": vendor["name"],
        "businessName": vendor["businessName"],
        "gstin": vendor["gstin"],
        "city": vendor["city"],
        "mobile": vendor["mobile"],
        "email": vendor["email"],
        "vendorType": vendor["vendorType"],
        "fssai": vendor["fssai"],
      });

      // ✅ Navigate to correct dashboard
      if (selectedVendorType == "Venue") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VenueDashboard()),
        );
      } else if (selectedVendorType == "Catering") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CateringDashboard()),
        );
      } else if (selectedVendorType == "Photography") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PhotographyDashboard()),
        );
      } else if (selectedVendorType == "Decorations") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DecorationDashboard()),
        );
      } else if (selectedVendorType == "Music") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MusicDashboard()),
        );
      } else if (selectedVendorType == "Makeup") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MakeupDashboard()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No such vendor type supported yet")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data["message"] ?? "Signup failed")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}



  Widget _buildInputField({
    required String label,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.redAccent),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required List<String> items,
    String? value,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Colors.black87,
        hint: Text(label, style: const TextStyle(color: Colors.white70)),
        items: items
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(color: Colors.white)),
                ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.redAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/images/lg1.jpg", fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.3), Colors.red.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Image.asset("assets/images/eplg2.png", height: 120, fit: BoxFit.contain),
                      const SizedBox(height: 24),

                      _buildInputField(
                        label: "Name",
                        icon: Icons.person,
                        controller: nameController,
                        validator: (val) => val == null || val.isEmpty ? "Enter name" : null,
                      ),

                      _buildInputField(
                        label: "Business Name",
                        icon: Icons.business,
                        controller: businessController,
                        validator: (val) => val == null || val.isEmpty ? "Enter business name" : null,
                      ),

                      _buildDropdown(
                        label: "Select Vendor Type",
                        icon: Icons.category,
                        items: vendorTypes,
                        value: selectedVendorType,
                        onChanged: (val) => setState(() => selectedVendorType = val),
                        validator: (val) => val == null ? "Select vendor type" : null,
                      ),

                      _buildInputField(
                        label: "GSTIN",
                        icon: Icons.confirmation_number,
                        controller: gstinController,
                      ),

                      if (selectedVendorType == "Catering")
                        _buildInputField(
                          label: "FSSAI Number",
                          icon: Icons.food_bank,
                          controller: fssaiController,
                          keyboard: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.isEmpty) return "Enter FSSAI number";
                            if (!RegExp(r'^\d{14}$').hasMatch(val)) return "Must be 14 digits";
                            return null;
                          },
                        ),

                      _buildDropdown(
                        label: "City",
                        icon: Icons.location_city,
                        items: metroCities,
                        value: selectedLocation,
                        onChanged: (val) => setState(() => selectedLocation = val),
                        validator: (val) => val == null ? "Select location" : null,
                      ),

                      _buildInputField(
                        label: "Mobile No.",
                        icon: Icons.phone,
                        controller: mobileController,
                        keyboard: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? "Enter mobile" : null,
                      ),

                      _buildInputField(
                        label: "Email",
                        icon: Icons.email,
                        controller: emailController,
                        keyboard: TextInputType.emailAddress,
                        validator: (val) => val == null || val.isEmpty ? "Enter email" : null,
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: _registerVendor,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              "Sign Up",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (_) => VendorLoginPage()));
                        },
                        child: const Text("Already have an account? Login",
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
