import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';
import 'main_tab_controller.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _navigateBasedOnRole(User user) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final role = userDoc['role'] ?? 'user';

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainTabController(isGuest: false)),
      );
    }
  }

  void _login() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Email validation
    if (email.isEmpty) {
      setState(() => _emailError = "Email cannot be empty");
      return;
    } else if (!_isValidEmail(email)) {
      setState(() => _emailError = "Enter a valid email address");
      return;
    }

    // Password validation
    if (password.isEmpty) {
      setState(() => _passwordError = "Password cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _auth.signInWithEmail(email, password);
      if (user != null && mounted) {
        await _navigateBasedOnRole(user);
      }
    } catch (e) {
      setState(() => _passwordError = "Incorrect email or password");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _googleSignIn() async {
    await _auth.signOut();
    final user = await _auth.signInWithGoogle();
    if (user != null && mounted) {
      await _navigateBasedOnRole(user);
    }
  }

  void _guestLogin() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final uid = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'isGuest': true,
        'createdAt': FieldValue.serverTimestamp(),
        'progress': {},
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainTabController(isGuest: true)),
        );
      }
    } catch (e) {
      setState(() {});
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDB2FF),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  );
                },
              ),
            ),

            Image.asset(
              'assets/images/study.png',
              height: 200,
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(60)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Column(
                    children: [
                      const Text(
                        "Log In to your account",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // EMAIL FIELD + RED ERROR
                      TextField(
                        controller: _emailController,
                        onChanged: (val) {
                          setState(() => _emailError = null);
                        },
                        decoration: InputDecoration(
                          hintText: "Enter your Email",
                          labelText: "E-mail",
                          filled: true,
                          fillColor: Colors.white,
                          errorText: null, // We show custom red text instead
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                        ),
                      ),

                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _emailError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // PASSWORD FIELD + RED ERROR
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        onChanged: (val) {
                          setState(() => _passwordError = null);
                        },
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          filled: true,
                          fillColor: Colors.white,
                          errorText: null,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black26),
                          ),
                        ),
                      ),

                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 5, left: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _passwordError!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 25),

                      _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFBDB2FF),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                "Log In",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          );
                        },
                        child: const Text("New User? Sign Up"),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _googleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF9A00FF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Sign In with Google",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _guestLogin,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: const BorderSide(color: Colors.black26),
                          ),
                          child: const Text(
                            "Continue as Guest",
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
