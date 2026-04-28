import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_provider.dart';
import '../theme/app_theme.dart';
import 'result_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        if (provider.state == QuizState.completed) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ResultScreen()),
            );
          });
        }

        final question = provider.currentQuestion;
        if (question == null) return const SizedBox.shrink();

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              _showExitDialog(context, provider);
            }
          },
          child: Scaffold(
            backgroundColor: AppTheme.backgroundGrey,
            appBar: AppBar(
              backgroundColor: AppTheme.surfaceWhite,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => _showExitDialog(context, provider),
                color: AppTheme.textMedium,
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.selectedCategory?.name ?? 'Quiz',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Question ${provider.currentIndex + 1} of ${provider.totalQuestions}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMedium,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              actions: const [],

            ),
            body: SafeArea(
              child: Column(
                children: [
                  _buildProgressBar(provider),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildScoreStrip(provider),
                          const SizedBox(height: 16),
                          _buildQuestionCard(provider, question),
                          const SizedBox(height: 16),
                          _buildOptions(provider, question),
                          if (provider.answerSubmitted) ...[
                            const SizedBox(height: 16),
                            _buildExplanationCard(provider, question),
                          ],
                          const SizedBox(height: 24),
                          if (provider.answerSubmitted)
                            _buildNextButton(context, provider),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: !provider.answerSubmitted
                ? _buildSubmitBar(context, provider)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(QuizProvider provider) {
    return Container(
      color: AppTheme.surfaceWhite,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: AppTheme.dividerGrey,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildScoreStrip(QuizProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreChip(
            icon: Icons.check_circle_outline,
            label: '${provider.correctSoFar} Correct',
            color: AppTheme.successGreen,
          ),
          Container(height: 20, width: 1, color: AppTheme.dividerGrey),
          _buildScoreChip(
            icon: Icons.cancel_outlined,
            label:
                '${provider.answeredQuestions.where((q) => !q.isCorrect).length} Wrong',
            color: AppTheme.errorRed,
          ),
          Container(height: 20, width: 1, color: AppTheme.dividerGrey),
          _buildScoreChip(
            icon: Icons.radio_button_unchecked,
            label:
                '${provider.totalQuestions - provider.answeredQuestions.length} Left',
            color: AppTheme.textMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChip(
      {required IconData icon,
      required String label,
      required Color color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuizProvider provider, question) {
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
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.difficultyColor(question.difficulty)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppTheme.difficultyColor(question.difficulty)
                        .withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  question.difficulty.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.difficultyColor(question.difficulty),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Q${provider.currentIndex + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            question.question,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(QuizProvider provider, question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _buildOptionTile(provider, question, index),
        );
      }),
    );
  }

  Widget _buildOptionTile(QuizProvider provider, question, int index) {
    final isSelected = provider.selectedAnswer == index;
    final isSubmitted = provider.answerSubmitted;
    final isCorrect = index == question.correctAnswer;
    final isWrong = isSubmitted && isSelected && !isCorrect;
    final showCorrect = isSubmitted && isCorrect;

    Color borderColor = AppTheme.dividerGrey;
    Color bgColor = AppTheme.surfaceWhite;
    Color textColor = AppTheme.textDark;
    IconData? trailingIcon;

    if (isSubmitted) {
      if (showCorrect) {
        borderColor = AppTheme.successGreen;
        bgColor = AppTheme.successGreen.withValues(alpha: 0.08);
        textColor = AppTheme.successGreen;
        trailingIcon = Icons.check_circle;
      } else if (isWrong) {
        borderColor = AppTheme.errorRed;
        bgColor = AppTheme.errorRed.withValues(alpha: 0.08);
        textColor = AppTheme.errorRed;
        trailingIcon = Icons.cancel;
      } else {
        textColor = AppTheme.textLight;
      }
    } else if (isSelected) {
      borderColor = AppTheme.primaryBlue;
      bgColor = AppTheme.lightBlue;
      textColor = AppTheme.primaryBlue;
    }

    final letters = ['A', 'B', 'C', 'D'];

    return GestureDetector(
      onTap: isSubmitted ? null : () => provider.selectAnswer(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: isSelected || isSubmitted && isCorrect ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected || showCorrect
                    ? borderColor
                    : AppTheme.backgroundGrey,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                    color:
                        isSelected || showCorrect ? borderColor : AppTheme.dividerGrey),
              ),
              child: Center(
                child: Text(
                  letters[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected || showCorrect
                        ? Colors.white
                        : AppTheme.textMedium,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                question.options[index],
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight:
                      isSelected || showCorrect ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(trailingIcon, color: borderColor, size: 18),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationCard(QuizProvider provider, question) {
    final isCorrect =
        provider.selectedAnswer == question.correctAnswer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? AppTheme.successGreen.withValues(alpha: 0.06)
            : AppTheme.warningAmber.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect
              ? AppTheme.successGreen.withValues(alpha: 0.3)
              : AppTheme.warningAmber.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.lightbulb_outline : Icons.info_outline,
                size: 16,
                color: isCorrect
                    ? AppTheme.successGreen
                    : AppTheme.warningAmber,
              ),
              const SizedBox(width: 6),
              Text(
                isCorrect
                    ? 'Correct!'
                    : 'Explanation',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isCorrect
                      ? AppTheme.successGreen
                      : AppTheme.warningAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textMedium,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar(BuildContext context, QuizProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        border:
            Border(top: BorderSide(color: AppTheme.dividerGrey)),
      ),
      child: ElevatedButton(
        onPressed:
            provider.selectedAnswer == -1 ? null : provider.submitAnswer,
        style: ElevatedButton.styleFrom(
          backgroundColor: provider.selectedAnswer == -1
              ? AppTheme.dividerGrey
              : AppTheme.primaryBlue,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: Text(
          provider.selectedAnswer == -1
              ? 'Select an answer'
              : 'Submit Answer',
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, QuizProvider provider) {
    return ElevatedButton(
      onPressed: provider.nextQuestion,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryBlue,
        minimumSize: const Size(double.infinity, 48),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            provider.isLastQuestion ? 'View Results' : 'Next Question',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(width: 8),
          Icon(
            provider.isLastQuestion
                ? Icons.bar_chart_rounded
                : Icons.arrow_forward_rounded,
            size: 18,
          ),
        ],
      ),
    );
  }

  void _showExitDialog(BuildContext context, QuizProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Quiz?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text(
          'Your progress will be lost if you exit now.',
          style: TextStyle(color: AppTheme.textMedium, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue Quiz'),
          ),
          TextButton(
            onPressed: () {
              provider.resetQuiz();
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
