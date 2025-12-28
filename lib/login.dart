import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'signup.dart';
import 'homepage.dart';
import 'vendorsignup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  bool get _canLogin =>
      _emailController.text.isNotEmpty || _mobileController.text.isNotEmpty;

  final String baseUrl = "http://10.13.29.36:5000/api/users";

  @override
  void initState() {
    super.initState();
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();

    _emailController.addListener(() => setState(() {}));
    _mobileController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mobileController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ✅ Save user data in SharedPreferences
  Future<void> _saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("username", user["username"] ?? "");
    await prefs.setString("email", user["email"] ?? "");
    await prefs.setString("mobile", user["mobile"] ?? "");
    await prefs.setString("birthdate", user["birthdate"] ?? "");
    await prefs.setString("city", user["city"] ?? "");
  }

  // ✅ API call for login
  Future<void> _loginUser() async {
    try {
      String identifier = _emailController.text.isNotEmpty
          ? _emailController.text
          : _mobileController.text;

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"identifier": identifier}),
      );

      final data = jsonDecode(response.body);
      print("Login response: $data");

      if (response.statusCode == 200) {
        final user = data['user'];

        await _saveUserData(user); // ✅ save user info

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login successful ✅")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data["message"] ?? "Login failed"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildAnimatedTextField(
      String label, IconData icon, TextEditingController controller,
      {bool obscure = false}) {
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
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.redAccent),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
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
                colors: [Colors.black.withOpacity(0.2), Colors.orange.withOpacity(0.15)],
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
                      Image.asset('assets/images/eplg2.png', height: 130),
                      const SizedBox(height: 24),
                      _buildAnimatedTextField("Email", Icons.email, _emailController),
                      _buildAnimatedTextField("Mobile", Icons.phone, _mobileController),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: _canLogin ? _loginUser : null,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _canLogin ? Colors.redAccent : Colors.grey.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))
                            ],
                          ),
                          child: const Center(
                            child: Text("Login",
                                style: TextStyle(fontSize: 18, color: Colors.white)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? ",
                              style: TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SignUpPage(
                                    prefilledEmail: _emailController.text.isNotEmpty
                                        ? _emailController.text
                                        : null,
                                  ),
                                ),
                              );
                            },
                            child: const Text('Sign Up',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (_) => VendorSignupPage()));
                        },
                        child: const Text('Vendor? Sign Up here',
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
