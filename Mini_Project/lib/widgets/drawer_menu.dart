import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/profile_screen.dart'; // ✅ make sure this import is correct

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? "User"),
            accountEmail: Text(user?.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.photoURL != null && user!.photoURL!.isNotEmpty
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user?.photoURL == null || user!.photoURL!.isEmpty
                  ? const Icon(Icons.person, size: 40, color: Colors.white)
                  : null,
            ),
          ),

          // ✅ Profile Button
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () async {
              Navigator.pop(context); // closes drawer
              await Future.delayed(const Duration(milliseconds: 150));
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          const Divider(),

          // ✅ Sign Out Button
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Sign Out"),
            onTap: () async {
              await AuthService().signOut();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
