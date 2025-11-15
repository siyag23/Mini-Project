import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

// --- Color Palette
const Color kPrimaryColor = Color(0xFF5A4FCF);
const Color kCardBackgroundColor = Color(0xFFBFBDFE);
const Color kAppBackgroundColor = Colors.white;
const Color kTotalCardColor = Color(0xFFBFBDFE);
const Color kPremiumColor = Color(0xFFFFF7C4); // Card background when premium
const Color kDarkerPremiumTrack = Color(0xFFF7E69C); // Track color when premium (for contrast)
const Color kLightPurple = Color(0xFFBFBDFE);

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchEmail = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kAppBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Text(
                  "Edu",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  "Mock 🏆",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.black54),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 5),
            const Text(
              'Admin Panel',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // SEARCH BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    searchEmail = value.trim().toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search by Email",
                  prefixIcon: const Icon(Icons.search, color: kPrimaryColor),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: kLightPurple, width: 1.4),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: kPrimaryColor, width: 1.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            _TotalUsersCard(),

            const SizedBox(height: 18),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs;

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final userData = users[index].data() as Map<String, dynamic>;
                      final email =
                          (userData['email'] ?? "").toString().toLowerCase();

                      if (searchEmail.isNotEmpty &&
                          !email.contains(searchEmail)) {
                        return const SizedBox.shrink();
                      }

                      return _UserListItem(
                        userId: users[index].id,
                        name: userData['displayName'] ?? 'Guest User',
                        email: userData['email'] ?? 'N/A',
                        isPremium: userData['premium'] == true,
                        role: userData['role'] ?? 'user',
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

/// =====================================
/// ⭐ TOTAL USERS CARD
/// =====================================
class _TotalUsersCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const double imageStandardHeight = 160.0;
    const double imageTopOffset = -35.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          final totalUsers = snapshot.data?.docs.length ?? 0;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 90,
                decoration: BoxDecoration(
                  color: kTotalCardColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Total Users:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$totalUsers',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                left: -5,
                top: imageTopOffset,
                child: Image.asset(
                  'assets/images/lap.png',
                  height: imageStandardHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// =======================
/// ⭐ USER LIST ITEM
/// =======================
class _UserListItem extends StatelessWidget {
  final String userId;
  final String name;
  final String email;
  final bool isPremium;
  final String role;

  const _UserListItem({
    required this.userId,
    required this.name,
    required this.email,
    required this.isPremium,
    required this.role,
  });

  Future<void> _togglePremium(BuildContext context, bool currentStatus) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(userId);

    await docRef.update({'premium': !currentStatus});

    // Audit log
    await FirebaseFirestore.instance.collection('auditLogs').add({
      'action': 'toggled premium',
      'targetUser': email,
      'admin': FirebaseAuth.instance.currentUser!.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(); // Or a loading widget
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final currentPremium = userData['premium'] == true;
        final Color itemColor =
            currentPremium ? kPremiumColor : kCardBackgroundColor.withOpacity(0.3);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Role + Star
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          role.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (currentPremium)
                          Image.asset(
                            'assets/images/star.png',
                            height: 20,
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Email + Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: currentPremium,
                        onChanged: (_) => _togglePremium(context, currentPremium),
                        activeColor: Colors.white,
                        activeTrackColor: kDarkerPremiumTrack,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor: kCardBackgroundColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
