import 'package:html_unescape/html_unescape.dart';

class Question {
  final String question;
  final String correctAnswer;
  final List<String> options;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final unescape = HtmlUnescape();

    List<String> options = List<String>.from(json['incorrect_answers']);
    options.add(json['correct_answer']);
    options.shuffle();

    return Question(
      question: unescape.convert(json['question']),
      correctAnswer: unescape.convert(json['correct_answer']),
      options: options.map((opt) => unescape.convert(opt)).toList(),
    );
  }
}
