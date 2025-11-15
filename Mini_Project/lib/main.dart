import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'screens/explore_screen.dart'; 
import 'screens/home_screen.dart'; 
import 'screens/profile_screen.dart'; 
import 'screens/progress_screen.dart'; 
import 'screens/AuthCheck.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const EduMockApp());
}

class EduMockApp extends StatelessWidget {
  const EduMockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EduMock',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFFF9F9FF),
        fontFamily: 'Poppins',
      ),
      // App starts at SplashScreen, which will navigate to AuthWrapper
      home: const SplashScreen(),
    );
  }
}
