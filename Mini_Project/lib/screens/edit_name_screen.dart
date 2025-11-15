import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditNameScreen extends StatefulWidget {
  const EditNameScreen({super.key});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? "";
  }

  void _saveName() async {
    if (_nameController.text.isNotEmpty) {
      try {
        // 1️⃣ Update name in Firebase Auth
        await user?.updateDisplayName(_nameController.text);

        // 2️⃣ Update name in Firestore
        await FirebaseFirestore.instance
            .collection('users')        // Your collection name
            .doc(user?.uid)             // Document ID = user UID
            .update({'displayName': _nameController.text});

        // 3️⃣ Pop back with updated name
        Navigator.pop(context, _nameController.text);
      } catch (e) {
        print("Failed to update name: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update name.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
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

              const SizedBox(height: 30),
              const Text(
                "Edit Name",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Name input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Name", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 5),
                  Container(
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
                    child: TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 18),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter your name",
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveName,
                  child: const Text(
                    "Save",
                    style: TextStyle(fontSize: 16),
                  ),
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
        ),
      ),
    );
  }
}
