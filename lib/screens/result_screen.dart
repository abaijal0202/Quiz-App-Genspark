import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'quiz_screen.dart';
import 'review_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        final result = provider.lastResult;
        if (result == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: AppTheme.backgroundGrey,
            appBar: AppBar(
              backgroundColor: AppTheme.surfaceWhite,
              automaticallyImplyLeading: false,
              title: const Text(
                'Quiz Results',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: AppTheme.textDark),
              ),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildScoreCard(result),
                    const SizedBox(height: 16),
                    _buildBreakdownCard(result),
                    const SizedBox(height: 16),
                    _buildCategoryBreakdown(result),
                    const SizedBox(height: 24),
                    _buildActionButtons(context, provider, result),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard(result) {
    final scoreColor = AppTheme.scoreColor(result.scorePercentage);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: Column(
        children: [
          Text(
            result.categoryName,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: result.scorePercentage / 100,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.dividerGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${result.scorePercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    result.grade,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMedium,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            result.gradeMessage,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: scoreColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You scored ${result.correctAnswers} out of ${result.totalQuestions}',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(result) {


    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStat(
                icon: Icons.check_circle_outline,
                value: '${result.correctAnswers}',
                label: 'Correct',
                color: AppTheme.successGreen,
              ),
              _buildStat(
                icon: Icons.cancel_outlined,
                value: '${result.wrongAnswers}',
                label: 'Wrong',
                color: AppTheme.errorRed,
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildStat(
      {required IconData icon,
      required String value,
      required String label,
      required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(result) {
    // Group by difficulty
    final easy = result.answeredQuestions
        .where((q) => q.question.difficulty == 'easy');
    final medium = result.answeredQuestions
        .where((q) => q.question.difficulty == 'medium');
    final hard = result.answeredQuestions
        .where((q) => q.question.difficulty == 'hard');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'By Difficulty',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),
          if (easy.isNotEmpty)
            _buildDifficultyRow('Easy', easy.toList(),
                AppTheme.difficultyColor('easy')),
          if (medium.isNotEmpty)
            _buildDifficultyRow('Medium', medium.toList(),
                AppTheme.difficultyColor('medium')),
          if (hard.isNotEmpty)
            _buildDifficultyRow(
                'Hard', hard.toList(), AppTheme.difficultyColor('hard')),
        ],
      ),
    );
  }

  Widget _buildDifficultyRow(String label, List<dynamic> questions, Color color) {
    final correct = questions.where((q) => q.isCorrect).length;
    final total = questions.length;
    final pct = total > 0 ? correct / total : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: color.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$correct/$total',
            style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMedium,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, QuizProvider provider, result) {
    return Column(
      children: [
        if (result.mistakes.isNotEmpty)
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ReviewScreen(result: result)),
              );
            },
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: Text(
                'Review ${result.mistakes.length} Mistake${result.mistakes.length > 1 ? 's' : ''}'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () async {
            provider.resetQuiz();
            await provider.startQuiz(provider.selectedCategory!);
            if (!context.mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            );
          },
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Retake Quiz'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            provider.resetQuiz();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
          icon: const Icon(Icons.home_outlined, size: 18),
          label: const Text('Back to Home'),
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.textMedium,
          ),
        ),
      ],
    );
  }
}
