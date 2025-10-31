import 'package:co2_detection_app_flutter/screens/homepage.dart';
import 'package:co2_detection_app_flutter/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<void> _checkLoginStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(Homepage.routeName);
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check login status when the splash screen is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus(context);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
