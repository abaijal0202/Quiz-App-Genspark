import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';
import '../models/quiz_result_model.dart';
import '../models/category_model.dart';
import 'question_service.dart';
import 'storage_service.dart';

enum QuizState { idle, inProgress, paused, completed }

class QuizProvider extends ChangeNotifier {
  QuizState _state = QuizState.idle;
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _selectedAnswer = -1;
  bool _answerSubmitted = false;
  List<AnsweredQuestion> _answeredQuestions = [];
  CategoryModel? _selectedCategory;
  int _timeRemaining = 30;
  Timer? _timer;
  QuizResult? _lastResult;
  List<QuizResult> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  QuizState get state => _state;
  List<Question> get questions => _questions;
  int get currentIndex => _currentIndex;
  Question? get currentQuestion =>
      _questions.isNotEmpty && _currentIndex < _questions.length
          ? _questions[_currentIndex]
          : null;
  int get selectedAnswer => _selectedAnswer;
  bool get answerSubmitted => _answerSubmitted;
  List<AnsweredQuestion> get answeredQuestions => _answeredQuestions;
  CategoryModel? get selectedCategory => _selectedCategory;
  int get timeRemaining => _timeRemaining;
  int get totalQuestions => _questions.length;
  QuizResult? get lastResult => _lastResult;
  List<QuizResult> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLastQuestion => _currentIndex == _questions.length - 1;
  double get progress =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  int get correctSoFar =>
      _answeredQuestions.where((q) => q.isCorrect).length;

  Future<void> loadHistory() async {
    _history = await StorageService.getQuizHistory();
    notifyListeners();
  }

  Future<void> startQuiz(CategoryModel category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final questions = QuestionService.getRandomQuestions(category.id);
      if (questions.isEmpty) {
        _errorMessage =
            'No questions available for this category. Please update the question bank.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      _questions = questions;
      _selectedCategory = category;
      _currentIndex = 0;
      _answeredQuestions = [];
      _selectedAnswer = -1;
      _answerSubmitted = false;
      _lastResult = null;
      _state = QuizState.inProgress;
      _isLoading = false;

      _startTimer();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load questions: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectAnswer(int answerIndex) {
    if (_answerSubmitted || _state != QuizState.inProgress) return;
    _selectedAnswer = answerIndex;
    notifyListeners();
  }

  void submitAnswer() {
    if (_selectedAnswer == -1 || _answerSubmitted) return;
    _answerSubmitted = true;
    _timer?.cancel();

    final question = currentQuestion!;
    final isCorrect = _selectedAnswer == question.correctAnswer;
    final timeTaken = 30 - _timeRemaining;

    _answeredQuestions.add(AnsweredQuestion(
      question: question,
      selectedAnswer: _selectedAnswer,
      isCorrect: isCorrect,
      timeTaken: timeTaken,
    ));

    notifyListeners();
  }

  void _timeOut() {
    if (_answerSubmitted) return;
    _answerSubmitted = true;
    _timer?.cancel();

    final question = currentQuestion!;
    _answeredQuestions.add(AnsweredQuestion(
      question: question,
      selectedAnswer: -1,
      isCorrect: false,
      timeTaken: 30,
    ));

    notifyListeners();

    // Auto-advance after timeout
    Future.delayed(const Duration(milliseconds: 800), () {
      if (_state == QuizState.inProgress) {
        nextQuestion();
      }
    });
  }

  void nextQuestion() {
    if (!_answerSubmitted) {
      submitAnswer();
      return;
    }

    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _selectedAnswer = -1;
      _answerSubmitted = false;
      _startTimer();
      notifyListeners();
    } else {
      _completeQuiz();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeRemaining = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        _timeOut();
      }
    });
  }

  Future<void> _completeQuiz() async {
    _timer?.cancel();
    _state = QuizState.completed;

    final result = QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      categoryId: _selectedCategory!.id,
      categoryName: _selectedCategory!.name,
      totalQuestions: _questions.length,
      correctAnswers: _answeredQuestions.where((q) => q.isCorrect).length,
      totalTimeTaken: _answeredQuestions.fold<int>(
          0, (sum, q) => sum + q.timeTaken),
      completedAt: DateTime.now(),
      answeredQuestions: List.from(_answeredQuestions),
    );

    _lastResult = result;
    await StorageService.saveQuizResult(result);
    await loadHistory();
    notifyListeners();
  }

  void resetQuiz() {
    _timer?.cancel();
    _state = QuizState.idle;
    _questions = [];
    _currentIndex = 0;
    _selectedAnswer = -1;
    _answerSubmitted = false;
    _answeredQuestions = [];
    _timeRemaining = 30;
    _lastResult = null;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await StorageService.clearHistory();
    _history = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
