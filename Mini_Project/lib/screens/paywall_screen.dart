import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  Future<void> _handlePurchase(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to purchase Premium.')),
      );
      return;
    }

    try {
      await Future.delayed(const Duration(seconds: 1));
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'premium': true,
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('🎉 Premium Activated! Enjoy the features.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Purchase failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color kPrimaryColor = Color(0xFF5A4FCF);
    const Color kLightPurple = Color(0xFFE0DCFF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            // ✅ Back button replaced with arrow icon (like ProfileScreen)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 26),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 4),
            const Text(
              'Edu',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const Text(
              'Mock',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const Text(' 🏆', style: TextStyle(fontSize: 22)),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🌟 Go Premium banner
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: kLightPurple,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Go Premium ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 22, // Bigger font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Image.asset(
                      'assets/images/star.png',
                      height: 26,
                      width: 26,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Unlock Your Full Potential',
              style: TextStyle(
                color: kPrimaryColor,
                fontSize: 20, // Bigger font
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 25),

            // ✅ Feature list
            _buildFeature('Advanced Performance Analytics', Icons.bar_chart, kPrimaryColor),
            _buildFeature('Time Analysis', Icons.access_time, kPrimaryColor),
            _buildFeature('Comprehensive Question Breakdown', Icons.analytics_outlined, kPrimaryColor),
            _buildFeature('Deep Subject Mastery', Icons.school, kPrimaryColor),

            const SizedBox(height: 40),

            // ✅ Choose Your Plan section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose Your Plan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Monthly subscription card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: kLightPurple, width: 2),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                title: const Text(
                  'Monthly Subscription',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Access all features for 30 days.'),
                trailing: const Text(
                  '₹99',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),

            const SizedBox(height: 20),

            // Pay ₹99 button card
            Card(
              color: kPrimaryColor,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () => _handlePurchase(context),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Center(
                    child: Text(
                      'Pay ₹99 and Go Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Feature row widget
  Widget _buildFeature(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
