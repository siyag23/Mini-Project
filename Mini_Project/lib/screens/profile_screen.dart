import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'edit_name_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackToHome; // Callback for back button

  const ProfileScreen({super.key, this.onBackToHome});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String displayName = "Guest User";

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut() async {
    await AuthService().signOut();
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // --- Premium Badge Widget ---
  Widget _buildPremiumBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFACC15), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.star, color: Color(0xFFFACC15), size: 16),
          SizedBox(width: 6),
          Text(
            "PREMIUM MEMBER",
            style: TextStyle(
              color: Color(0xFFFACC15),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  // -----------------------------

  @override
  Widget build(BuildContext context) {
    final bool canPop = ModalRoute.of(context)?.canPop ?? false;
    final userId = user?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("User not found")),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final bool isPremium = userData['premium'] == true;
            displayName = userData['displayName'] ?? user?.displayName ?? "Guest User";

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          if (canPop) {
                            Navigator.pop(context);
                          } else {
                            widget.onBackToHome?.call();
                          }
                        },
                      ),
                      Row(
                        children: const [
                          Text(
                            "Edu",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF5A4FCF),
                            ),
                          ),
                          SizedBox(width: 3),
                          Text(
                            "Mock",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(width: 5),
                          Text("🏆", style: TextStyle(fontSize: 18)),
                        ],
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "My Profile",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage:
                        user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                    child: user?.photoURL == null
                        ? Text(
                            displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          )
                        : null,
                  ),

                  const SizedBox(height: 10),

                  if (isPremium) _buildPremiumBadge(),

                  SizedBox(height: isPremium ? 20 : 30),

                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditNameScreen()),
                      );
                      setState(() {}); // Refresh displayName after edit
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Name", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 5),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const Icon(Icons.edit, color: Colors.grey),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Email", style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          user?.email ?? "",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text("Log Out", style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA3A7FC),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
