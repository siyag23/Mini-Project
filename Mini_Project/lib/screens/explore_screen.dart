import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class ExploreScreen extends StatelessWidget {
  final VoidCallback? onBackToHome; // ✅ Optional callback for bottom nav

  const ExploreScreen({super.key, this.onBackToHome});

  final List<Map<String, dynamic>> subjects = const [
    {"title": "HISTORY", "image": "assets/images/hist.png", "categoryId": 23},
    {"title": "ENGLISH", "image": "assets/images/eng.png", "categoryId": 10},
    {"title": "MATHEMATICS", "image": "assets/images/math.png", "categoryId": 19},
    {"title": "ENVIRONMENT", "image": "assets/images/envt.png", "categoryId": 22},
    {"title": "GENERAL KNOWLEDGE", "image": "assets/images/gk.png", "categoryId": 9},
    {"title": "SCIENCE", "image": "assets/images/sci.png", "categoryId": 17},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8D5FF),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            if (onBackToHome != null) {
              onBackToHome!(); // ✅ Switch to Home tab in bottom nav
            } else {
              Navigator.pop(context); // ✅ Works if opened separately
            }
          },
        ),
        title: const Text("EXPLORE SUBJECTS"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        itemCount: subjects.length + 1, // extra for intro text
        itemBuilder: (context, index) {
          // 🟣 Intro text at the top
          if (index == 0) {
            return Container(
              margin: const EdgeInsets.only(bottom: 30),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFDAD6FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                "Explore subjects and start your mock test now!",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.indigo,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          // 🔹 Subject cards
          final subject = subjects[index - 1];

          double imgHeight = 200;
          double imgWidth = 200;
          double topOffset = -65;
          double rightOffset = -5;

          switch (subject["title"]) {
            case "HISTORY":
              imgHeight = 240;
              imgWidth = 240;
              topOffset = -70;
              rightOffset = -5;
              break;
            case "ENGLISH":
              imgHeight = 230;
              imgWidth = 230;
              topOffset = -50;
              rightOffset = -5;
              break;
            case "MATHEMATICS":
              imgHeight = 230;
              imgWidth = 230;
              topOffset = -68;
              rightOffset = -25;
              break;
            case "ENVIRONMENT":
              imgHeight = 200;
              imgWidth = 200;
              topOffset = -55;
              rightOffset = -15;
              break;
            case "GENERAL KNOWLEDGE":
              imgHeight = 210;
              imgWidth = 210;
              topOffset = -60;
              rightOffset = -40;
              break;
            case "SCIENCE":
              imgHeight = 235;
              imgWidth = 235;
              topOffset = -70;
              rightOffset = -5;
              break;
          }

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(
                    categoryId: subject["categoryId"],
                    subject: subject["title"],
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 70),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(2, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 25, bottom: 20),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 1.2,
                              width: 90,
                              color: Colors.indigo.withOpacity(0.4),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subject["title"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: rightOffset,
                    top: topOffset,
                    child: SizedBox(
                      height: imgHeight,
                      width: imgWidth,
                      child: Image.asset(
                        subject["image"],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
