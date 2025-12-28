import 'package:flutter/material.dart';

/// Simple model for each FAQ item
class FAQItem {
  final String title;
  final List<String> steps;

  const FAQItem({
    required this.title,
    required this.steps,
  });
}

class VendorHelpSupportPage extends StatelessWidget {
  // FAQ data (made const so it's safe at compile time)
  final List<FAQItem> faqItems = const [
    FAQItem(
      title: "How to update profile",
      steps: [
        "All the details should be given in the Sign Up page.",
        "Images and sub-categories should be added in Profile.",
        "When clicked on Profile, choose the sub-categories you provide.",
        "Add images in the Home page."
      ],
    ),
    FAQItem(
      title: "How to accept orders",
      steps: [
        "Order requests will be shown at the bottom of the Home page.",
        "You cannot reject the order once it is done.",
        "You have an option to click on the dates in the Calendar if the provided time slot or date is fixed and unavailable."
      ],
    ),
    FAQItem(
      title: "Post order and verification",
      steps: [
        "You have a QR scanner on the Current Order page.",
        "When you click on it, the scanner opens.",
        "Once you scan the code, the order is verified and you can proceed."
      ],
    ),
  ];

  VendorHelpSupportPage({Key? key}) : super(key: key);

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
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          final item = faqItems[index];
          return _buildExpansionTile(
            context,
            title: item.title,
            steps: item.steps,
          );
        },
      ),
    );
  }

  /// Builds a Card containing an ExpansionTile for each FAQ item
  Widget _buildExpansionTile(BuildContext context,
      {required String title, required List<String> steps}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        childrenPadding: const EdgeInsets.only(bottom: 12),
        children: steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final stepText = entry.value;
          return ListTile(
            visualDensity: VisualDensity.compact,
            leading: CircleAvatar(
              radius: 14,
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade800,
              child: Text(
                '${idx + 1}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(stepText),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          );
        }).toList(),
      ),
    );
  }
}
