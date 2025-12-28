import 'userprofile.dart';
import 'user_helpandsupport.dart';
import 'login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = "Guest User";
  String _email = "guest@example.com";
  String _mobile = "";
  String _birthdate = "";
  String _city = "";

  bool _personalizedSuggestions = true;
  bool _darkTheme = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ✅ Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString("username") ?? "Guest User";
      _email = prefs.getString("email") ?? "guest@example.com";
      _mobile = prefs.getString("mobile") ?? "";
      _birthdate = prefs.getString("birthdate") ?? "";
      _city = prefs.getString("city") ?? "";
    });
  }

  // ✅ Logout: clear SharedPreferences and navigate to login page
  Future<void> _logout() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // remove all stored data

  if (!mounted) return;

  // Navigate to LoginPage (replace route)
  Navigator.push(
                context,
                  MaterialPageRoute(
                    builder: (_) => LoginPage(),
                  ),
                );

  // Optionally show confirmation
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Logged out successfully")),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade800,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top user section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      child: Text(
                        _username.isNotEmpty ? _username[0].toUpperCase() : "U",
                        style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _username,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _email,
                          style:
                              const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserProfilePage(),
                              ),
                            );
                          },
                          child: const Text(
                            "View More >",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // Premium section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Premium Member",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text("Exclusive benefits for your celebrations",
                              style: TextStyle(color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bookings & Coupons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoCard("My Bookings", "0 upcoming", Icons.event),
                  _buildInfoCard("My Coupons", "0 new offers", Icons.local_offer),
                ],
              ),

              // Profile completion
              Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToggle("Show Personalized Suggestions", "", _personalizedSuggestions, (value) {
                      setState(() {
                        _personalizedSuggestions = value;
                      });
                    }),
                    _buildToggle("Dark Theme", "", _darkTheme, (value) {
                      setState(() {
                        _darkTheme = value;
                      });
                    }),
                    const SizedBox(height: 8),
                    Text("Terms & Conditions >",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade800)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HelpSupportPage()),
                        );
                      },
                      child: Text(
                        "Help & Support >",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Collections
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerLeft,
                child: const Text("Collections",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildCollection("Wedding", "assets/images/wedding.jpg"),
                    _buildCollection("Catering", "assets/images/catering.jpg"),
                    _buildCollection("Makeup", "assets/images/makeup.jpg"),
                    _buildCollection("Music & DJ", "assets/images/music.jpg"),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.red.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )),
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: _logout,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String subtitle, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.red, size: 40),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool enabled, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      value: enabled,
      onChanged: onChanged,
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
    );
  }

  Widget _buildCollection(String title, String imgPath) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: AssetImage(imgPath), fit: BoxFit.cover),
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(6),
        color: Colors.black54,
        child: Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 14)),
      ),
    );
  }
}
