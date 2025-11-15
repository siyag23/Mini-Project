import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'login_screen.dart';

// Define the custom colors used in the image
const Color _kProgressTextColor = Color(0xFF6B5CD9);
const Color _kButtonBackgroundColor = Color(0xFFEEEAFF);

// New Widget to handle the guaranteed status check for sensitive tabs
class _AuthGuard extends StatelessWidget {
  final Widget child;
  final Widget placeholder;

  const _AuthGuard({required this.child, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    // Check the LIVE user status directly from Firebase
    final user = FirebaseAuth.instance.currentUser;
    final bool isAnonymous = user != null && user.isAnonymous;

    // If we've detected an anonymous user, even if the MainTabController thought
    // it was rendering the full screen, we force the placeholder.
    if (isAnonymous) {
      return placeholder;
    }
    // If the user is fully logged in or null (which should be handled by AuthWrapper),
    // render the actual feature.
    return child;
  }
}


class MainTabController extends StatefulWidget {
  final bool isGuest;
  const MainTabController({super.key, this.isGuest = false});

  @override
  State<MainTabController> createState() => _MainTabControllerState();
}

class _MainTabControllerState extends State<MainTabController> {
  int _currentIndex = 0;

  void _switchToProfileTab() {
    setState(() {
      _currentIndex = 3;
    });
  }

  void _backToHome() {
    setState(() {
      _currentIndex = 0;
    });
  }

  late final List<Widget> _pages;

  // The placeholder is defined outside of initState for use in the _AuthGuard
  late Widget _profilePlaceholder;
  late Widget _progressPlaceholder;

  @override
  void initState() {
    super.initState();

    // Initialize placeholders here
    _progressPlaceholder = _guestFeaturePlaceholder("Progress");
    _profilePlaceholder = _guestFeaturePlaceholder("Profile");

    // We now simplify the logic using the new AuthGuard widget
    _pages = [
      // ⭐ FIX APPLIED HERE: Pass the isGuest status to HomeScreen
      HomeScreen(
          onSwitchToProfile: _switchToProfileTab,
          isGuest: widget.isGuest // Pass the status from the constructor
      ),

      ExploreScreen(onBackToHome: _backToHome),

      // Progress Tab (Index 2): Use the AuthGuard
      widget.isGuest
          ? _progressPlaceholder
          : _AuthGuard(
        placeholder: _progressPlaceholder,
        child: ProgressScreen(onBackToHome: _backToHome),
      ),

      // Profile Tab (Index 3): Use the AuthGuard
      widget.isGuest
          ? _profilePlaceholder
          : _AuthGuard(
        placeholder: _profilePlaceholder,
        child: ProfileScreen(onBackToHome: _backToHome),
      ),
    ];
  }

  /// Guest placeholder page (remains the same)
  Widget _guestFeaturePlaceholder(String featureName) {
    String capitalizedFeatureName = '${featureName[0].toUpperCase()}${featureName.substring(1).toLowerCase()}';

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            // ... (Header and other existing UI remains the same) ...
            Padding(
              padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: _backToHome,
                      ),
                      const Text('EduMock 🏆', style: TextStyle(color: Color(0xFF5A4FCF), fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'My ${capitalizedFeatureName}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // --- Main Content Section (Text and Button) ---
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${capitalizedFeatureName} is available for \nSigned-in users only.",
                    style: TextStyle(fontSize: 18, color: _kProgressTextColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        // CRITICAL FIX: Ensure sign-out happens here
                        await FirebaseAuth.instance.signOut();

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (Route<dynamic> route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kButtonBackgroundColor,
                        foregroundColor: _kProgressTextColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        minimumSize: const Size(250, 50),
                        elevation: 0,
                      ),
                      child: const Text("Sign In to get more features", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Standard Scaffold builder
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5A4FCF),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}