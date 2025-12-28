import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Help & Support",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red.shade800,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildExpansionTile(
            title: "How to access admin panel",
            steps: [
              "1) Go to More",
              "2) Locate 'Switch to Admin Panel'",
              "3) Click on that",
              "4) Sign in by filling up the required details",
              "OR",
              "1) Logout",
              "2) Locate 'Sign in as Admin' on Sign Up page",
            ],
          ),
          _buildExpansionTile(
            title: "How to book",
            steps: [
              "1) Choose the option that you want to book",
              "2) Look out for details and compare with your requirement",
              "3) Add to cart",
              "4) Choose a payment method",
              "5) Book",
              "",
              "📦 Booking a whole package (e.g., Wedding):",
              "1) Everything required is listed side by side",
              "2) Choose all or skip items you don’t need",
              "3) Add everything, go to cart, and checkout",
            ],
          ),
          _buildExpansionTile(
            title: "Post order and verification",
            steps: [
              "1) After order, a QR code appears in WhatsApp, Email, and bell icon on homepage",
              "2) Show the QR to vendor for safe and secure verification",
              "3) Enjoy your event 🎉",
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpansionTile({required String title, required List<String> steps}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      shadowColor: Colors.red.shade200,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        collapsedIconColor: Colors.red.shade800,
        iconColor: Colors.red.shade800,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.red.shade800,
          ),
        ),
        children: steps
            .map((step) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    step,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 14,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}