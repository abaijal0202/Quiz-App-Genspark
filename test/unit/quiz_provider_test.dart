import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:quiz_master/services/quiz_provider.dart';
import 'package:quiz_master/services/question_service.dart';
import 'package:quiz_master/services/storage_service.dart';
import 'package:quiz_master/models/category_model.dart';
import 'package:quiz_master/models/question_model.dart';

class MockQuestionService extends Mock implements QuestionService {}
class MockStorageService extends Mock implements StorageService {}

void main() {
  late QuizProvider quizProvider;
  late MockQuestionService mockQuestionService;
  late MockStorageService mockStorageService;

  setUp(() {
    mockQuestionService = MockQuestionService();
    mockStorageService = MockStorageService();
    quizProvider = QuizProvider(
      questionService: mockQuestionService,
      storageService: mockStorageService,
    );
  });

  group('QuizProvider Tests', () {
    test('initial state is correct', () {
      expect(quizProvider.state, QuizState.idle);
      expect(quizProvider.questions, isEmpty);
      expect(quizProvider.currentIndex, 0);
      expect(quizProvider.timeRemaining, 30);
    });

    test('startQuiz sets up the quiz correctly when questions are available', () async {
      final category = CategoryModel(
        id: '1',
        name: 'Math',
        icon: 'math_icon',
        color: '0xFF0000',
        questionCount: 1,
      );

      final questions = [
        Question(
          id: '1',
          category: '1',
          text: '1+1=?',
          options: ['1', '2', '3', '4'],
          correctAnswer: 1,
          explanation: 'It is 2.',
        ),
      ];

      when(() => mockQuestionService.getRandomQuestions('1'))
          .thenReturn(questions);

      await quizProvider.startQuiz(category);

      expect(quizProvider.state, QuizState.inProgress);
      expect(quizProvider.questions, equals(questions));
      expect(quizProvider.selectedCategory, equals(category));
      expect(quizProvider.timeRemaining, 30);
      expect(quizProvider.isLoading, false);
      expect(quizProvider.errorMessage, isNull);
    });

    test('startQuiz sets error when no questions are available', () async {
      final category = CategoryModel(
        id: '1',
        name: 'Math',
        icon: 'math_icon',
        color: '0xFF0000',
        questionCount: 0,
      );

      when(() => mockQuestionService.getRandomQuestions('1')).thenReturn([]);

      await quizProvider.startQuiz(category);

      expect(quizProvider.state, QuizState.idle);
      expect(quizProvider.errorMessage, isNotNull);
      expect(quizProvider.isLoading, false);
    });
  });
}
