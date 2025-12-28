import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  final String? prefilledEmail;
  const SignUpPage({super.key, this.prefilledEmail});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  String? _selectedCity;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _metroCities = [
    "Bangalore",
    "Mumbai",
    "Delhi",
    "Chennai",
    "Kolkata",
    "Hyderabad",
    "Pune",
    "Ahmedabad"
  ];

  // ✅ Backend Base URL
  final String baseUrl = "http://10.13.29.36:5000/api/users";

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null) {
      _emailController.text = widget.prefilledEmail!;
    }
    _fadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  bool get _canSignUp =>
      _nameController.text.isNotEmpty &&
      _emailController.text.isNotEmpty &&
      _phoneController.text.isNotEmpty &&
      _dobController.text.isNotEmpty &&
      _selectedCity != null;

  // ✅ Reusable Input Field
  Widget _buildTextField(String label, IconData icon,
      TextEditingController controller, bool readOnly, VoidCallback? onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.redAccent),
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ✅ City Dropdown
  Widget _buildCityDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedCity,
        items: _metroCities.map((city) {
          return DropdownMenuItem<String>(
            value: city,
            child: Text(
              city,
              style: TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() => _selectedCity = value);
        },
        dropdownColor: Colors.black87,
        decoration: InputDecoration(
          labelText: "Select City",
          labelStyle: TextStyle(color: Colors.white70),
          border: InputBorder.none,
        ),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // ✅ Show Snackbar
  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  // ✅ Complete Signup (Save details to SharedPreferences)
  Future<void> _completeSignup() async {
    _showMessage("Signing up...");

    try {
      // 🔒 Ensure birthday is always ISO (YYYY-MM-DD)
      String birthdate = _dobController.text;
      try {
        final parsedDate = DateTime.parse(birthdate);
        birthdate = parsedDate.toIso8601String().split('T')[0];
      } catch (_) {
        // fallback: leave as-is if parsing fails
      }

      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': _nameController.text,
          'email': _emailController.text,
          'mobile': _phoneController.text,
          'birthdate': birthdate,
          'city': _selectedCity,
        }),
      );

      final data = jsonDecode(response.body);
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        _showMessage("Signup successful ✅");

        // ✅ Save details in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("username", _nameController.text);
        await prefs.setString("email", _emailController.text);
        await prefs.setString("mobile", _phoneController.text);
        await prefs.setString("birthdate", birthdate);
        await prefs.setString("city", _selectedCity ?? "");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage()),
        );
      } else {
        _showMessage(data['message'] ?? "Signup failed", error: true);
      }
    } catch (e) {
      _showMessage("Error: $e", error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/lg1.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.3), Colors.orange.withOpacity(0.2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black45, blurRadius: 20, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset('assets/images/eplg2.png', height: 120),
                      const SizedBox(height: 20),

                      _buildTextField("Full Name", Icons.person, _nameController, false, null),
                      _buildTextField("Email", Icons.email, _emailController, false, null),
                      _buildTextField("Mobile No", Icons.phone, _phoneController, false, null),

                      _buildTextField(
                        "Birthday",
                        Icons.cake,
                        _dobController,
                        true,
                        () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              // ✅ Save in ISO format
                              _dobController.text =
                                  pickedDate.toIso8601String().split('T')[0];
                            });
                          }
                        },
                      ),

                      _buildCityDropdown(),

                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _canSignUp ? _completeSignup : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _canSignUp
                                ? Colors.redAccent
                                : Colors.grey.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                              child: Text("Sign Up",
                                  style: TextStyle(fontSize: 18, color: Colors.white))),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already have an account? ",
                              style: TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()));
                            },
                            child: const Text("Login",
                                style: TextStyle(color: Colors.white)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
