import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final String subject;

  const QuizScreen({
    super.key,
    required this.categoryId,
    required this.subject,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final ApiService _apiService = ApiService();
  List<Question> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _hasError = false;

  List<String?> userAnswers = [];
  bool _resultSaved = false;

  Timer? _timer;
  int _remainingSeconds = 300;
  int _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final questions = await _apiService.fetchQuestions(widget.categoryId);
      setState(() {
        _questions = questions;
        userAnswers = List.filled(questions.length, null);
        _isLoading = false;
      });

      if (_questions.isNotEmpty) {
        _startTimer();
      }
    } catch (e) {
      debugPrint("Error loading questions: $e");
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _elapsedSeconds++;
        });
      } else {
        timer.cancel();
        _autoSubmitQuiz();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

  Future<void> _saveResultToFirestoreOnce(
      int correct, int wrong, int unanswered) async {
    if (_resultSaved) return;
    _resultSaved = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('results')
          .add({
        'subject': widget.subject,
        'correct': correct,
        'wrong': wrong,
        'unanswered': unanswered,
        'total': _questions.length,
        'timeTakenSeconds': _elapsedSeconds,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("❌ Error saving result: $e");
    }
  }

  Future<void> _autoSubmitQuiz() async {
    int correct = 0;
    int wrong = 0;
    int unanswered = 0;

    for (int i = 0; i < _questions.length; i++) {
      if (userAnswers[i] == null) {
        unanswered++;
      } else if (userAnswers[i] == _questions[i].correctAnswer) {
        correct++;
      } else {
        wrong++;
      }
    }

    await _saveResultToFirestoreOnce(correct, wrong, unanswered);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: correct,
          total: _questions.length,
          subject: widget.subject,
          correct: correct,
          wrong: wrong,
          unanswered: unanswered,
        ),
      ),
    );
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _submitQuiz() async {
    _timer?.cancel();
    int correct = 0;
    int wrong = 0;
    int unanswered = 0;

    for (int i = 0; i < _questions.length; i++) {
      if (userAnswers[i] == null) {
        unanswered++;
      } else if (userAnswers[i] == _questions[i].correctAnswer) {
        correct++;
      } else {
        wrong++;
      }
    }

    await _saveResultToFirestoreOnce(correct, wrong, unanswered);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          score: correct,
          total: _questions.length,
          subject: widget.subject,
          correct: correct,
          wrong: wrong,
          unanswered: unanswered,
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    bool leave = false;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Exit Test?"),
        content: const Text("Your progress will be lost if you leave. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () {
              leave = false;
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              leave = true;
              Navigator.pop(context);
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
    return leave;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _hasError
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Network issue. Please check your connection and retry.",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _loadQuestions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A4FCF),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Retry"),
                ),
              ],
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () async {
                        if (await _onWillPop()) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                    const Row(
                      children: [
                        Text(
                          "Edu",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF5A4FCF),
                          ),
                        ),
                        Text(
                          "Mock",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text("🏆"),
                      ],
                    ),
                    const SizedBox(width: 40),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Subject title
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D3FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              "${widget.subject.toUpperCase()} TEST",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Timer
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFDDD)),
                          ),
                          child: Text(
                            "⏰ Time Left: ${_formatTime(_remainingSeconds)}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "Question ${_currentIndex + 1} of ${_questions.length}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          _questions[_currentIndex].question,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Options
                        ..._questions[_currentIndex].options.map((option) {
                          final isSelected = userAnswers[_currentIndex] == option;
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? const Color(0xFF5A4FCF) : const Color(0xFFE4E0FF),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                shadowColor: Colors.black26,
                                elevation: 2,
                              ),
                              onPressed: () {
                                setState(() {
                                  userAnswers[_currentIndex] = option;
                                });
                              },
                              child: Text(
                                option,
                                softWrap: true,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 20),

                        // Navigation Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _previousQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB8B8FF),
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Previous",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8D84FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _currentIndex == _questions.length - 1 ? "Submit" : "Next",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}