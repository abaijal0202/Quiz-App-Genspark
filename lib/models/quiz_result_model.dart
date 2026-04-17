import 'question_model.dart';

class AnsweredQuestion {
  final Question question;
  final int selectedAnswer; // -1 if not answered (timed out)
  final bool isCorrect;
  final int timeTaken; // in seconds

  AnsweredQuestion({
    required this.question,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.timeTaken,
  });

  Map<String, dynamic> toJson() {
    return {
      'question': question.toJson(),
      'selected_answer': selectedAnswer,
      'is_correct': isCorrect,
      'time_taken': timeTaken,
    };
  }

  factory AnsweredQuestion.fromJson(Map<String, dynamic> json) {
    return AnsweredQuestion(
      question: Question.fromJson(json['question'] as Map<String, dynamic>),
      selectedAnswer: json['selected_answer'] as int,
      isCorrect: json['is_correct'] as bool,
      timeTaken: json['time_taken'] as int,
    );
  }
}

class QuizResult {
  final String id;
  final String categoryId;
  final String categoryName;
  final int totalQuestions;
  final int correctAnswers;
  final int totalTimeTaken; // in seconds
  final DateTime completedAt;
  final List<AnsweredQuestion> answeredQuestions;

  QuizResult({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.totalTimeTaken,
    required this.completedAt,
    required this.answeredQuestions,
  });

  double get scorePercentage =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  int get wrongAnswers => totalQuestions - correctAnswers;

  String get grade {
    final pct = scorePercentage;
    if (pct >= 90) return 'A+';
    if (pct >= 80) return 'A';
    if (pct >= 70) return 'B';
    if (pct >= 60) return 'C';
    if (pct >= 50) return 'D';
    return 'F';
  }

  String get gradeMessage {
    final pct = scorePercentage;
    if (pct >= 90) return 'Outstanding!';
    if (pct >= 80) return 'Excellent!';
    if (pct >= 70) return 'Good Job!';
    if (pct >= 60) return 'Keep Going!';
    if (pct >= 50) return 'Almost There!';
    return 'Keep Practicing!';
  }

  List<AnsweredQuestion> get mistakes =>
      answeredQuestions.where((q) => !q.isCorrect).toList();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'total_time_taken': totalTimeTaken,
      'completed_at': completedAt.toIso8601String(),
      'answered_questions':
          answeredQuestions.map((aq) => aq.toJson()).toList(),
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      categoryName: json['category_name'] as String,
      totalQuestions: json['total_questions'] as int,
      correctAnswers: json['correct_answers'] as int,
      totalTimeTaken: json['total_time_taken'] as int,
      completedAt: DateTime.parse(json['completed_at'] as String),
      answeredQuestions: (json['answered_questions'] as List)
          .map((aq) => AnsweredQuestion.fromJson(aq as Map<String, dynamic>))
          .toList(),
    );
  }
}
