import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'main_tab_controller.dart';
import 'welcome_screen.dart';
import 'admin_screen.dart'; 

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<String> _getUserRole(String uid) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data()?['role'] != null) {
      return doc.data()!['role'] as String;
    }
    return 'user'; // default role
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          if (user.isAnonymous) {
            // Persistent Guest detected. Force sign out and route to WelcomeScreen.
            Future.microtask(() async {
              await FirebaseAuth.instance.signOut();
            });
            return const WelcomeScreen();
          } else {
            // Fully signed-in user. Check Firestore role.
            return FutureBuilder<String>(
              future: _getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final role = roleSnapshot.data ?? 'user';
                if (role == 'admin') {
                  return const AdminPage();
                } else {
                  return const MainTabController(isGuest: false);
                }
              },
            );
          }
        } else {
          // User is not signed in
          return const WelcomeScreen();
        }
      },
    );
  }
}
