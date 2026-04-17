import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_result_model.dart';

class StorageService {
  static const String _historyKey = 'quiz_history';
  static const int _maxHistoryCount = 10;

  static Future<void> saveQuizResult(QuizResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getQuizHistory();

    history.insert(0, result);

    // Keep only last 10 results
    if (history.length > _maxHistoryCount) {
      history.removeRange(_maxHistoryCount, history.length);
    }

    final jsonList = history.map((r) => json.encode(r.toJson())).toList();
    await prefs.setStringList(_historyKey, jsonList);
  }

  static Future<List<QuizResult>> getQuizHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];

    final results = <QuizResult>[];
    for (final jsonStr in jsonList) {
      try {
        final data = json.decode(jsonStr) as Map<String, dynamic>;
        results.add(QuizResult.fromJson(data));
      } catch (_) {
        // Skip corrupted entries
      }
    }
    return results;
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  static Future<Map<String, dynamic>> getStats() async {
    final history = await getQuizHistory();
    if (history.isEmpty) {
      return {
        'total_quizzes': 0,
        'average_score': 0.0,
        'best_score': 0.0,
        'total_questions_answered': 0,
      };
    }

    final scores = history.map((r) => r.scorePercentage).toList();
    final totalQuestions =
        history.fold<int>(0, (sum, r) => sum + r.totalQuestions);

    return {
      'total_quizzes': history.length,
      'average_score': scores.reduce((a, b) => a + b) / scores.length,
      'best_score': scores.reduce((a, b) => a > b ? a : b),
      'total_questions_answered': totalQuestions,
    };
  }
}
