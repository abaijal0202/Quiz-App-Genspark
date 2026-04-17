import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../models/category_model.dart';

class QuestionService {
  static List<Question> _allQuestions = [];
  static List<CategoryModel> _categories = [];
  static bool _loaded = false;

  static Future<void> loadQuestions() async {
    if (_loaded) return;
    try {
      final jsonString = await rootBundle
          .loadString('assets/questions/question_bank.json');
      final data = json.decode(jsonString) as Map<String, dynamic>;

      _categories = (data['categories'] as List)
          .map((c) => CategoryModel.fromJson(c as Map<String, dynamic>))
          .toList();

      _allQuestions = (data['questions'] as List)
          .map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList();

      // Set question counts per category
      for (final category in _categories) {
        category.questionCount = _allQuestions
            .where((q) => q.category == category.id)
            .length;
      }

      _loaded = true;
    } catch (e) {
      _loaded = false;
      rethrow;
    }
  }

  static List<CategoryModel> get categories => List.unmodifiable(_categories);

  static List<Question> getAllQuestions() => List.unmodifiable(_allQuestions);

  static List<Question> getQuestionsByCategory(String categoryId) {
    return _allQuestions
        .where((q) => q.category == categoryId)
        .toList();
  }

  static List<Question> getRandomQuestions(String categoryId,
      {int count = 10}) {
    final categoryQuestions = getQuestionsByCategory(categoryId);
    categoryQuestions.shuffle();
    return categoryQuestions.take(count).toList();
  }

  static CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static void reloadQuestions() {
    _loaded = false;
    _allQuestions = [];
    _categories = [];
  }
}
