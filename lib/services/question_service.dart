import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question_model.dart';
import '../models/category_model.dart';
import 'package:http/http.dart' as http;

class QuestionService {
  List<Question> _allQuestions = [];
  List<CategoryModel> _categories = [];
  bool _loaded = false;
  String? _loadError;

  Future<void> loadQuestions() async {
    if (_loaded) return;
    const url = 'https://storage.googleapis.com/dell-laptop-backup-2026/Quiz_app/question_bank.json';
    
    try {
      print('Attempting to fetch questions from: $url');
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
      
      // Use utf8.decode on bodyBytes to safely handle special characters like °, ₹, etc.
      final jsonString = utf8.decode(response.bodyBytes);
      final data = json.decode(jsonString) as Map<String, dynamic>;
      
      _parseData(data);
      _loaded = true;
      _loadError = null;
      print('Successfully loaded questions from online source.');
    } catch (e) {
      print('Error fetching online questions: $e');
      _loadError = 'Failed to fetch latest questions. Using offline version.';
      
      try {
        print('Attempting to load questions from local assets...');
        final jsonString = await rootBundle.loadString('assets/questions/question_bank.json');
        final data = json.decode(jsonString) as Map<String, dynamic>;
        _parseData(data);
        _loaded = true;
        print('Successfully loaded questions from local assets.');
      } catch (e2) {
        print('Critical error: Failed to load local questions: $e2');
        _loaded = false;
        _loadError = 'Failed to load questions completely.';
        rethrow;
      }
    }
  }

  void _parseData(Map<String, dynamic> data) {
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
  }

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  String? get loadError => _loadError;

  List<Question> getAllQuestions() => List.unmodifiable(_allQuestions);

  List<Question> getQuestionsByCategory(String categoryId) {
    return _allQuestions
        .where((q) => q.category == categoryId)
        .toList();
  }

  List<Question> getRandomQuestions(String categoryId,
      {int count = 10}) {
    final categoryQuestions = getQuestionsByCategory(categoryId);
    categoryQuestions.shuffle();
    return categoryQuestions.take(count).toList();
  }

  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void reloadQuestions() {
    _loaded = false;
    _allQuestions = [];
    _categories = [];
  }

  Future<void> syncQuestions() async {
    _loaded = false; // Force reload
    await loadQuestions();
  }
}
