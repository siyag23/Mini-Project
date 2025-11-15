import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final String subject;
  final int correct;
  final int wrong;
  final int unanswered;

  const ResultScreen({
    super.key,
    required this.score,
    required this.total,
    required this.subject,
    required this.correct,
    required this.wrong,
    required this.unanswered,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Edu",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF5A4FCF), // Edu in purple
              ),
            ),
            SizedBox(width: 3),
            Text(
              "Mock",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black, // Mock in black
              ),
            ),
            SizedBox(width: 5),
            Text(
              "🏆",
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Congratulations",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // 🏆 Your Image
              Image.asset(
                'assets/images/c.png', // <-- your actual image path
                height: 150,
              ),
              const SizedBox(height: 20),

              Text(
                "Your Score:\n$score/$total",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Correct / ❌ Wrong / ⏸ Unanswered
              Text(
                "Correct Answers: $correct",
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
              Text(
                "Wrong Answers: $wrong",
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
              Text(
                "Unanswered: $unanswered",
                style: const TextStyle(fontSize: 18, color: Colors.blueGrey),
              ),
              const SizedBox(height: 30),

              const Text(
                "You did a great job! Learn more by taking another test",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black), // now fully black
              ),
              const SizedBox(height: 30),

              // 🌟 Start Next Test Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDDE3FF),
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                ),
                child: const Text(
                  "Start Next Test",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}