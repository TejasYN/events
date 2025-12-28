import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'login.dart';
import 'homepage.dart';
import 'venuedashboard.dart';
import 'cateringdashboard.dart';
import 'photographydashboard.dart';
import 'decorationdashboard.dart';
import 'musicdashboard.dart';
import 'makeupdashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showText = false;

  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  void _startSplash() {
    // Show text after 1.5 seconds
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showText = true);
      }
    });

    // Navigate after 3 seconds
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();

      // 🔹 First check normal user login
      final userEmail = prefs.getString("email");

      // 🔹 Then check vendor login
      final vendorEmail = prefs.getString("vendor_email");
      final vendorType = prefs.getString("vendor_vendorType");

      if (userEmail != null && userEmail.isNotEmpty) {
        _navigateTo(const HomePage()); // user home
      } else if (vendorEmail != null && vendorEmail.isNotEmpty) {
        if (vendorType == "Venue") {
          _navigateTo(const VenueDashboard());
        } else if (vendorType == "Catering") {
          _navigateTo(const CateringDashboard());
        } else if (vendorType == "Photography") {
          _navigateTo(const PhotographyDashboard());
        } else if (vendorType == "Decorations") {
          _navigateTo(const DecorationDashboard());
        } else if (vendorType == "Music") {
          _navigateTo(const MusicDashboard());
        }else if (vendorType == "Makeup") {
          _navigateTo(const MakeupDashboard());
        } else {
          _navigateTo(const LoginPage()); // fallback
        }
      } else {
        _navigateTo(const LoginPage());
      }
    });
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          );
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          );
          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(opacity: fadeAnimation, child: child),
          );
        },
        transitionDuration: const Duration(milliseconds: 900),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/eplg.jpeg',
                  width: 150,
                  height: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: _showText ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: const Text(
                    "Unforgettable Events, Seamlessly Done",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(bottom: 40.0),
            child: SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                backgroundColor: Colors.white24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
