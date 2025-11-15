import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'paywall_screen.dart';

class ProgressScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;
  const ProgressScreen({super.key, this.onBackToHome});

  final Color kPrimaryColor = const Color(0xFF5A4FCF);
  final Color kLightPurple = const Color(0xFFBFBDFE); // Border color (Light Purple)
  final Color kVeryLightPurpleBackground = const Color(0xFFF9F7FF); // ⭐ NEW: Single, very light purple background shade

  // --- Helper Functions ---

  String _formatTime(int totalSeconds) {
    if (totalSeconds == 0) return '0 s';
    final int minutes = totalSeconds ~/ 60;
    final int seconds = totalSeconds % 60;

    if (minutes > 0) {
      return '$minutes min $seconds s';
    }
    return '$totalSeconds s';
  }

  Widget _buildStatRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // --- 1. Line Chart: Accuracy Trend (Premium) ---
  Widget _buildAccuracyLineChart(List<QueryDocumentSnapshot> trendResults) {
    if (trendResults.length < 2) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Need at least 2 test attempts for an accuracy trend chart.",
          style: TextStyle(color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      );
    }

    List<FlSpot> spots = [];
    double maxAccuracy = 0;

    for (int i = 0; i < trendResults.length; i++) {
      final data = trendResults[i].data() as Map<String, dynamic>;
      final correct = (data['correct'] ?? 0).toDouble();
      final total = (data['total'] ?? 1).toDouble();
      final accuracy = (correct / total) * 100.0;

      spots.add(FlSpot(i.toDouble(), accuracy.roundToDouble()));
      if (accuracy > maxAccuracy) maxAccuracy = accuracy;
    }

    final bottomTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          space: 8.0,
          child: Text('T${value.toInt() + 1}', style: const TextStyle(fontSize: 10)),
        ),
        interval: 1,
      ),
    );

    final leftTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)),
        interval: 20,
      ),
    );


    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 6, top: 10),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: bottomTitles,
            leftTitles: leftTitles,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: kPrimaryColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: true, color: kPrimaryColor.withOpacity(0.2)),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Bar Chart: Subject Breakdown (Premium) ---
  Widget _buildSubjectBarChart(List<QueryDocumentSnapshot> allResults) {
    if (allResults.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("No test results available for subject breakdown.", style: TextStyle(color: Colors.black54)),
      );
    }

    Map<String, List<double>> subjectStats = {};

    for (var doc in allResults) {
      final data = doc.data() as Map<String, dynamic>;
      final subject = data['subject'] as String? ?? 'Other';
      final correct = (data['correct'] ?? 0).toDouble();
      final total = (data['total'] ?? 1).toDouble();

      final accuracy = (correct / total);

      subjectStats.putIfAbsent(subject, () => [0.0, 0.0]);
      subjectStats[subject]![0] += accuracy;
      subjectStats[subject]![1] += 1.0;
    }

    List<BarChartGroupData> barGroups = [];
    List<String> subjectLabels = [];

    subjectStats.keys.toList().asMap().forEach((index, subject) {
      final totalAccuracy = subjectStats[subject]![0];
      final count = subjectStats[subject]![1];
      final avgAccuracy = (totalAccuracy / count) * 100.0;

      subjectLabels.add(subject);

      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: avgAccuracy.roundToDouble(),
              color: kPrimaryColor,
              width: 15,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6)
              ),
            ),
          ],
        ),
      );
    });

    final bottomTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        getTitlesWidget: (value, meta) => SideTitleWidget(
          axisSide: meta.axisSide,
          space: 4.0,
          child: Text(
            subjectLabels[value.toInt()],
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    final leftTitles = AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 40,
        getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 10)),
        interval: 25,
      ),
    );


    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 6, top: 10),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: bottomTitles,
            leftTitles: leftTitles,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25),
          borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
          barGroups: barGroups,
        ),
      ),
    );
  }

  // --- 3. Chart Container Caller ---
  Widget _buildAnalyticsCharts(BuildContext context, List<QueryDocumentSnapshot> allResults) {

    final int maxTests = 10;
    final int startIndex = allResults.length > maxTests ? allResults.length - maxTests : 0;

    final trendResults = allResults.sublist(startIndex).toList().reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Accuracy Trend Chart ---
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            // ⭐ BORDER: Light Purple Border
            side: BorderSide(color: kLightPurple, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Accuracy Trend (Line Chart)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 200,
                  child: _buildAccuracyLineChart(trendResults),
                ),
              ],
            ),
          ),
        ),

        // --- 2. Subject Weakness Breakdown Chart ---
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            // ⭐ BORDER: Light Purple Border
            side: BorderSide(color: kLightPurple, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performance by Subject (Bar Chart)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 250,
                  child: _buildSubjectBarChart(allResults),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  // 💡 Premium Content: Shows charts and detailed analytics
  Widget _buildPremiumContent(BuildContext context, String uid) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: firestore
          .collection('users')
          .doc(uid)
          .collection('results')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No mock test results recorded yet."));
        }

        final results = snapshot.data!.docs;

        // ⭐ OVERFLOW FIX: Use ListView for the main content
        return ListView(
          children: [
            // ⭐ 1. THE CHARTS SECTION ⭐
            _buildAnalyticsCharts(context, results),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Full Test History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            const SizedBox(height: 10),

            // ⭐ 2. THE DETAILED LIST SECTION (With Colored Cards) ⭐
            // Since we are already in a ListView, we use Column and map the items.
            Column(
              children: results.map((doc) {
                final result = doc.data() as Map<String, dynamic>;
                final String subject = result['subject'] ?? 'Other';
                final timestamp = result['timestamp'] != null
                    ? (result['timestamp'] as Timestamp).toDate()
                    : null;
                final formattedDate = timestamp != null
                    ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp)
                    : "Unknown date";

                final int correct = result['correct'] ?? 0;
                final int wrong = result['wrong'] ?? 0;
                final int totalQuestions = result['total'] ?? 0;
                final int timeTakenSeconds = result['timeTakenSeconds'] ?? 0;

                final int unanswered = totalQuestions - correct - wrong;
                final int attempted = correct + wrong;
                final double accuracy = totalQuestions > 0 ? (correct / totalQuestions) * 100 : 0.0;
                final double avgTimePerQuestion = attempted > 0 ? timeTakenSeconds / attempted : 0.0;

                // ⭐ Single Light Purple Color for all history cards ⭐
                final cardColor = kVeryLightPurpleBackground;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // ⭐ Use the single light purple background color ⭐
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    // ⭐ BORDER: Light Purple Border
                    border: Border.all(color: kLightPurple, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            subject, // Use the extracted subject
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Total: $totalQuestions Qs',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const Divider(height: 20),

                      // PREMIUM: DETAILED ANALYTICS
                      _buildStatRow('Correct Answers', '$correct answers', Colors.green),
                      _buildStatRow('Wrong Answers', '$wrong answers', Colors.red),
                      _buildStatRow('Unanswered', '$unanswered answers', Colors.grey.shade600),

                      const Divider(height: 20),

                      // TIME & EFFICIENCY (SI Units)
                      _buildStatRow('Total Time Taken', _formatTime(timeTakenSeconds), kPrimaryColor),
                      _buildStatRow('Avg. Time/Question', '${avgTimePerQuestion.toStringAsFixed(1)} s', Colors.orange),
                      _buildStatRow('Overall Accuracy', '${accuracy.toStringAsFixed(1)}%', Colors.purple),

                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  // 💡 Free Content: Shows basic score and upgrade prompt (FIXED to push card to bottom)
  Widget _buildFreeContent(BuildContext context, String uid) {
    final firestore = FirebaseFirestore.instance;

    // 💡 FIX 1: Change to Column. Its parent (Expanded in the main build method)
    // gives it the full height, allowing us to use another Expanded inside.
    return Column( 
      children: [
        // Basic Results List (Showing only Score)
        Expanded( // 💡 FIX 2: This makes the ListView take up all available space
          child: StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('users')
                .doc(uid)
                .collection('results')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No test attempts yet.", style: TextStyle(color: Colors.black54)),
                );
              }

              final results = snapshot.data!.docs;

              return ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index].data() as Map<String, dynamic>;
                  final timestamp = result['timestamp'] != null
                      ? (result['timestamp'] as Timestamp).toDate()
                      : null;
                  final formattedDate = timestamp != null
                      ? DateFormat('dd MMM yyyy').format(timestamp)
                      : "Unknown date";

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECEBFF),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              result['subject'] ?? "Unknown Subject",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 13, color: Colors.black54),
                            ),
                          ],
                        ),
                        Text(
                          "Score: ${result['correct'] ?? 0}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5A4FCF),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Upgrade Prompt Card (Automatically pushed to the bottom by Expanded above)
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kPrimaryColor.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              const Text(
                'Unlock Detailed Analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Go Premium to see time spent, accuracy rates, and a full breakdown of wrong and unanswered questions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PaywallScreen()),
                  );
                },
                icon: const Icon(Icons.workspace_premium),
                label: const Text('Upgrade Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10), // Bottom padding
      ],
    );
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;

    if (user == null) {
      return const Center(child: Text('Please log in to view your progress.'));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // 🔹 Header (EduMock + Back button)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.pop(context);
                      } else {
                        onBackToHome?.call();
                      }
                    },
                  ),
                  Row(
                    children: [
                      Text(
                        "Edu",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Text(
                        "Mock",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text("🏆", style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(width: 40),
                ],
              ),

              const SizedBox(height: 20),

              const Text(
                "My Progress",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 Gating Logic: Check User's Premium Status
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: firestore.collection('users').doc(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    bool isPremium = false;
                    if (snapshot.hasData && snapshot.data!.data() != null) {
                      final data = snapshot.data!.data() as Map<String, dynamic>;
                      isPremium = data['premium'] == true;
                    }

                    if (isPremium) {
                      return _buildPremiumContent(context, user.uid);
                    } else {
                      return _buildFreeContent(context, user.uid);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}