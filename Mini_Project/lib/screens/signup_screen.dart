import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'main_tab_controller.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  String? _emailError; // <-- EMAIL ERROR TEXT

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --------------------- EMAIL VALIDATION ---------------------
  bool _validateEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _emailError = "Email cannot be empty";
      });
      return false;
    }

    final emailRegex =
        RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$"); // Basic email pattern
    if (!emailRegex.hasMatch(email)) {
      setState(() {
        _emailError = "Enter a valid email address";
      });
      return false;
    }

    setState(() {
      _emailError = null;
    });
    return true;
  }

  // --------------------- SIGN UP ---------------------
  void _signup() async {
    if (!_validateEmail()) return; // <-- EMAIL CHECK

    setState(() => _isLoading = true);
    try {
      final user = await _auth.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainTabController()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --------------------- GOOGLE SIGN IN ---------------------
  void _googleSignIn() async {
    await _auth.signOut();
    final user = await _auth.signInWithGoogle();
    if (user != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainTabController()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ),

            Image.asset(
              'assets/images/study.png',
              height: screenHeight * 0.25,
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Create a new account",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --------------------- EMAIL FIELD ---------------------
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Enter your Email",
                          labelText: "E-mail",
                          errorText: _emailError, // <-- SHOW ERROR HERE
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.black12, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.black26, width: 1.5),
                          ),
                        ),
                        onChanged: (_) {
                          if (_emailError != null) _validateEmail();
                        },
                      ),
                      const SizedBox(height: 16),

                      // --------------------- PASSWORD FIELD ---------------------
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          labelText: "Password",
                          filled: true,
                          fillColor: Colors.white,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.black12, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: Colors.black26, width: 1.5),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --------------------- SIGNUP BUTTON ---------------------
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _signup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFBDB2FF),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                      const SizedBox(height: 10),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Text(
                            "Already a User? Log In",
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ---------------- GOOGLE BUTTON ----------------
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
                            "Sign Up with Google",
                            style: TextStyle(
                                color: Colors.white, fontSize: 16),
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
