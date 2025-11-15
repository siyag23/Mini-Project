import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';

class ApiService {
  Future<List<Question>> fetchQuestions(int categoryId) async {
    final url =
        "https://opentdb.com/api.php?amount=10&category=$categoryId&type=multiple";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['results'];

      return results.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception("Failed to fetch questions");
    }
  }
}
