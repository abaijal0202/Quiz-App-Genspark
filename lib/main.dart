import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/question_service.dart';
import 'services/storage_service.dart';
import 'services/quiz_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final questionService = QuestionService();
  final storageService = StorageService();

  // Load question bank
  await questionService.loadQuestions();

  runApp(QuizMasterApp(
    questionService: questionService,
    storageService: storageService,
  ));
}

class QuizMasterApp extends StatelessWidget {
  final QuestionService questionService;
  final StorageService storageService;

  const QuizMasterApp({
    super.key,
    required this.questionService,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<QuestionService>.value(value: questionService),
        Provider<StorageService>.value(value: storageService),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(
            questionService: questionService,
            storageService: storageService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Quiz Master',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
