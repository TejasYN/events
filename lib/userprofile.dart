import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String _username = "Guest User";
  String _email = "guest@example.com";
  String _mobile = "";
  String _birthdate = "";
  String _city = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _username = prefs.getString("username") ?? "Guest User";
    _email = prefs.getString("email") ?? "guest@example.com";
    _mobile = prefs.getString("mobile") ?? "";
    
    String rawDate = prefs.getString("birthdate") ?? "";
    if (rawDate.isNotEmpty) {
      try {
        DateTime parsed = DateTime.parse(rawDate);
        // Format as dd/MM/yyyy
        _birthdate = DateFormat("dd/MM/yyyy").format(parsed);
      } catch (e) {
        _birthdate = rawDate; // fallback
      }
    } else {
      _birthdate = "";
    }

    _city = prefs.getString("city") ?? "";
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade800,
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Top profile circle with first letter
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 20),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Text(
                _username.isNotEmpty ? _username[0].toUpperCase() : "U",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade800,
                ),
              ),
            ),
          ),

          // White card for details
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildField("Name", _username),
                    const SizedBox(height: 16),
                    buildField("Date of Birth", _birthdate),
                    const SizedBox(height: 16),
                    buildField("Email", _email),
                    const SizedBox(height: 16),
                    buildField("Phone", _mobile),
                    const SizedBox(height: 16),
                    buildField("Location", _city),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable widget to build profile fields
  Widget buildField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.red.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value.isNotEmpty ? value : "Not provided",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
