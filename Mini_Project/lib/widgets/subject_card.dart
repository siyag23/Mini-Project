import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SubjectCard({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: Colors.indigo.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
