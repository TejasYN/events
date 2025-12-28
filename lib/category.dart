import 'package:flutter/material.dart';
import 'homepage.dart';
import 'venues.dart';
import 'catering.dart';
import 'photography.dart';
import 'decoration.dart';
import 'music.dart';
import 'makeup.dart';
import 'invitationcard.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, const Color(0xFF8B0000)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back arrow (left)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HomePage()),
                        );
                      },
                    ),
                  ),
                  // Centered title
                  const Text(
                    "Categories",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            categoryCard(context, "Venue", "Search and book venues",
                "assets/images/venues.jpg"),
            categoryCard(context, "Catering", "Order food for your event",
                "assets/images/catering.jpg"),
            categoryCard(context, "Photography", "Find a photographer",
                "assets/images/photography.jpg"),
            categoryCard(context, "Decoration", "Explore decoration ideas",
                "assets/images/decoration.jpg"),
            categoryCard(context, "Music & DJ", "Book a DJ or band",
                "assets/images/music.jpg"),
            categoryCard(context, "Makeup", "Find a makeup artist",
                "assets/images/makeup.jpg"),
            categoryCard(context, "Invitaion card", "Invite your people",
                "assets/images/Invitationcard.jpg"),
          ],
        ),
      ),
      
    );
  }

  Widget categoryCard(BuildContext context, String title, String subtitle, String imageUrl) {
    return InkWell(
      onTap: () {
        if (title == "Venue") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VenuesPage()),
          );
        } else if (title == "Catering") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CateringPage()),
          );
        } else if (title == "Photography") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PhotographyPage()),
          );
        }else if (title == "Decoration") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DecorationPage()),
          );
        } else if (title == "Music & DJ") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MusicPage()),
          );
        } else if (title == "Makeup") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MakeupPage()),
          );
        }
        else if (title == "Invitaion card") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Invitationcard()),
          );
        }
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                alignment: (imageUrl.contains('catering.jpg') || imageUrl.contains('makeup.jpg')) ? const Alignment(0, -0.3) : Alignment.center,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.red, size: 40),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
