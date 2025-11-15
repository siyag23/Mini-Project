import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';
import 'paywall_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onSwitchToProfile;
  final bool isGuest;

  const HomeScreen({super.key, this.onSwitchToProfile, this.isGuest = false});

  // 1. Widget to display the score and actions for SIGNED-IN users
  Widget _buildSignedInScoreContent(BuildContext context, User? currentUser) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "You're improving every time!",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        const Text(
          "Score till now:",
          style: TextStyle(color: Colors.white, fontSize: 15),
        ),
        const SizedBox(height: 6),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Dynamic total score from Firestore
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(currentUser?.uid)
                  .collection('results')
                  .snapshots(),
              builder: (context, snapshot) {
                int totalScore = 0;

                if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data();
                    if (data is Map<String, dynamic>) {
                      final correct = data['correct'];

                      if (correct is num) {
                        totalScore += correct.toInt();
                      }
                    }
                  }
                }

                return Text(
                  "$totalScore",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10), // Vertical space before button
        Align(
          alignment: Alignment.centerLeft,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF5A4FCF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExploreScreen()),
              );
            },
            child: const Text("Start Test"),
          ),
        ),
      ],
    );
  }

  // 2. Widget to display the message for GUEST users
  Widget _buildGuestScoreContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The main message: "Sign Up to track your score."
        const Text(
          "Sign Up to track your score.",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10), // Vertical space before button

        // Start Test button
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF5A4FCF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ExploreScreen()),
            );
          },
          child: const Text("Start Test"),
        ),
      ],
    );
  }

  // ⭐ NEW WIDGET: Card shown when the user is already premium
  Widget _buildPremiumMemberCard(BuildContext context) {
    const Color kPrimaryColor = Color(0xFF5A4FCF);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.1), // Light purple background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.workspace_premium, size: 40, color: kPrimaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "PREMIUM MEMBER",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                SizedBox(height: 6),
                Text(
                  "Thank you! You have access to all exclusive features.",
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ MODIFIED WIDGET: Card shown when the user needs to buy premium (for Signed-in non-premium users)
  Widget _buildBuyNowCard(BuildContext context) {
    const Color kPrimaryColor = Color(0xFF5A4FCF);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFBDFE)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/p.png',
            height: 120,
            width: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "GET PREMIUM",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Get all the new exciting features!",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      // ⭐ ACTION: Navigate to the new PaywallScreen ⭐
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaywallScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Buy Now",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ⭐ NEW WIDGET: Card shown when the GUEST user needs to sign in for premium
  Widget _buildGuestPremiumCard(BuildContext context) {
    const Color kPrimaryColor = Color(0xFF5A4FCF);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFBDFE)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/p.png',
            height: 120,
            width: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "SIGN IN to get Premium",
                  style: TextStyle(
                      color: kPrimaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Sign in to access all the exciting premium features!",
                  style: TextStyle(color: Colors.black54, fontSize: 15),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () {
                      // ⭐ ACTION: Navigate to ProfileScreen for sign-in ⭐
                      if (onSwitchToProfile != null) {
                        onSwitchToProfile!();
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ProfileScreen()),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Sign In",
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final userDocRef =
    FirebaseFirestore.instance.collection('users').doc(currentUser?.uid);

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9FF),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (No changes needed)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Text("Edu", style: TextStyle(color: Color(0xFF5A4FCF), fontWeight: FontWeight.bold, fontSize: 24)),
                        Text("Mock 🏆", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (onSwitchToProfile != null) {
                          onSwitchToProfile!();
                        } else {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                        }
                      },
                      child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 20,
                        child: Icon(Icons.person_outline, color: Colors.black54),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Greeting (No changes needed)
                StreamBuilder<DocumentSnapshot>(
                  stream: userDocRef.snapshots(),
                  builder: (context, snapshot) {
                    String displayName = (currentUser == null || currentUser.isAnonymous) ? "Guest" : "User";
                    if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data!.data() != null) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      displayName = data['displayName'] ?? displayName;
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hi $displayName!", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                        const Text("Ready to begin your mock test?", style: TextStyle(color: Colors.black54)),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Score Card with Floating Trophy (MODIFIED SECTION)
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBFBDFE),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 60),
                              child: isGuest
                                  ? _buildGuestScoreContent(context)
                                  : _buildSignedInScoreContent(context, currentUser),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: -50,
                      child: Image.asset(
                        'assets/images/c.png',
                        height: 160,
                        width: 160,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // --- Featured Categories ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Featured Categories",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ExploreScreen()),
                        );
                      },
                      child: const Text(
                        "View All",
                        style: TextStyle(
                          color: Color(0xFF5A4FCF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryCard('Science', 'assets/images/s.png'),
                    _buildCategoryCard('Maths', 'assets/images/m.png'),
                    _buildCategoryCard('History', 'assets/images/h.png'),
                  ],
                ),
                const SizedBox(height: 28),

                // ⭐ PREMIUM SECTION LOGIC: Check Firestore and display the correct card ⭐
                if (currentUser != null && !currentUser.isAnonymous)
                  StreamBuilder<DocumentSnapshot>(
                    stream: userDocRef.snapshots(),
                    builder: (context, snapshot) {
                      bool isPremium = false;
                      // Safely check for data and the 'premium' field
                      if (snapshot.hasData && snapshot.data!.data() != null) {
                        final data = snapshot.data!.data() as Map<String, dynamic>;
                       
                        isPremium = data['premium'] == true;
                      }

                      // Display the appropriate card for SIGNED-IN users
                      if (isPremium) {
                        return _buildPremiumMemberCard(context);
                      } else {
                        return _buildBuyNowCard(context);
                      }
                    },
                  )
                else
                // Show the sign-in card if the user is a guest (currentUser is null or anonymous)
                
                  _buildGuestPremiumCard(context),
                // --- End Premium Section Logic ---
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, String imagePath) {
    return Column(
      children: [
        Container(
          height: 85,
          width: 85,
          decoration: BoxDecoration(
            color: const Color(0xFFF5EFFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}