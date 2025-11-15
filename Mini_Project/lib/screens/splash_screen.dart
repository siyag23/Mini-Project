import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'AuthCheck.dart'; // AuthWrapper handles role-based navigation

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    // Initialize Firebase (if not already initialized in main.dart)
    await Firebase.initializeApp();

    // Optional: Wait a bit to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Navigate to AuthWrapper which decides where to go:
    // AdminPage, MainTabController, or WelcomeScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDB2FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Card(
              color: Color(0xFFA18AFF),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Icon(
                  Icons.school_outlined,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              "EduMock",
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Practice Perfected",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 60),
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
