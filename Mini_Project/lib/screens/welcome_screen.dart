import 'package:flutter/material.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        // 🔄 Apply the solid background color from the splash screen
        decoration: const BoxDecoration(
          color: Color(0xFFBDB2FF),
          // Removed the LinearGradient
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // App name: EduMock (Using white text for contrast on the medium background)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Edu",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, // Changed to white
                        fontSize: 45,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Georgia',
                      ),
                    ),
                    Text(
                      "Mock",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, // Changed to white
                        fontSize: 45,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Georgia',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Illustration
                // Note: Ensure 'assets/images/person.png' is visible on this background.
                // If it's a dark image, it will work well.
                Image.asset(
                  'assets/images/person.png',
                  height: 220,
                  fit: BoxFit.contain,
                ),

                const Spacer(),

                // Get Started button (Color maintained from original code)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA18AFF),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 60, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}