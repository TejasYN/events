import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'vendor_prefs.dart';
import 'venuedashboard.dart';
import 'cateringdashboard.dart';
import 'photographydashboard.dart';
import 'decorationdashboard.dart';
import 'musicdashboard.dart';
import 'makeupdashboard.dart';

class VendorLoginPage extends StatefulWidget {
  const VendorLoginPage({super.key});

  @override
  State<VendorLoginPage> createState() => _VendorLoginPageState();
}

class _VendorLoginPageState extends State<VendorLoginPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedVendorType;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  final List<String> vendorTypes = ["Venue", "Catering","Photography", "Decorations","Music","Makeup"];

  @override
  void dispose() {
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  Future<void> _loginVendor() async {
  if (!_formKey.currentState!.validate()) return;

  final loginData = {
    "vendorType": selectedVendorType,
    "email": emailController.text.isNotEmpty ? emailController.text.trim() : null,
    "mobile": mobileController.text.isNotEmpty ? mobileController.text.trim() : null,
  };

  try {
    final res = await http.post(
      Uri.parse("http://10.13.29.36:5000/api/vendors/login"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(loginData),
    );

    final data = json.decode(res.body);

    if (res.statusCode == 200) {
      final vendor = data["vendor"];

      // ✅ Save vendor data locally, including _id
      await VendorPrefs.saveVendorData({
        "_id": vendor["_id"],
        "name": vendor["name"],
        "businessName": vendor["businessName"],
        "gstin": vendor["gstin"],
        "city": vendor["city"],
        "mobile": vendor["mobile"],
        "email": vendor["email"],
        "vendorType": vendor["vendorType"],
        "fssai": vendor["fssai"],
      });

      // ✅ Navigate
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
        SnackBar(content: Text(data["message"] ?? "Login failed")),
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

                      _buildDropdown(
                        label: "Select Vendor Type",
                        icon: Icons.category,
                        items: vendorTypes,
                        value: selectedVendorType,
                        onChanged: (val) => setState(() => selectedVendorType = val),
                        validator: (val) => val == null ? "Select vendor type" : null,
                      ),

                      _buildInputField(
                        label: "Email",
                        icon: Icons.email,
                        controller: emailController,
                        keyboard: TextInputType.emailAddress,
                        validator: (val) {
                          if (val!.isEmpty && mobileController.text.isEmpty) {
                            return "Enter email or mobile";
                          }
                          return null;
                        },
                      ),

                      _buildInputField(
                        label: "Mobile No.",
                        icon: Icons.phone,
                        controller: mobileController,
                        keyboard: TextInputType.phone,
                        validator: (val) {
                          if (val!.isEmpty && emailController.text.isEmpty) {
                            return "Enter email or mobile";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      GestureDetector(
                        onTap: _loginVendor,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Center(
                            child: Text(
                              "Login",
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                        ),
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
