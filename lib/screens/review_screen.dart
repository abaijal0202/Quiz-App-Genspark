import 'package:flutter/material.dart';
import '../models/quiz_result_model.dart';
import '../theme/app_theme.dart';

class ReviewScreen extends StatefulWidget {
  final QuizResult result;

  const ReviewScreen({super.key, required this.result});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  bool _showOnlyMistakes = true;
  int _expandedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final questions = _showOnlyMistakes
        ? widget.result.mistakes
        : widget.result.answeredQuestions;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review Answers',
              style: TextStyle(
                  fontWeight: FontWeight.w700, color: AppTheme.textDark),
            ),
            Text(
              widget.result.categoryName,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textMedium, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                _showOnlyMistakes ? 'Mistakes' : 'All',
                style: const TextStyle(fontSize: 12),
              ),
              selected: _showOnlyMistakes,
              onSelected: (val) {
                setState(() {
                  _showOnlyMistakes = val;
                  _expandedIndex = -1;
                });
              },
              selectedColor: AppTheme.errorRed.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.errorRed,
              side: BorderSide(
                color: _showOnlyMistakes
                    ? AppTheme.errorRed
                    : AppTheme.dividerGrey,
              ),
              labelStyle: TextStyle(
                color: _showOnlyMistakes ? AppTheme.errorRed : AppTheme.textMedium,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryBar(),
            Expanded(
              child: questions.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionReviewCard(
                            questions[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryBar() {
    final correct = widget.result.correctAnswers;
    final wrong = widget.result.wrongAnswers;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppTheme.surfaceWhite,
      child: Row(
        children: [
          _buildSummaryChip(
              '$correct', 'Correct', AppTheme.successGreen, Icons.check_circle_outline),
          const SizedBox(width: 12),
          _buildSummaryChip(
              '$wrong', 'Wrong', AppTheme.errorRed, Icons.cancel_outlined),
          const Spacer(),
          Text(
            '${widget.result.scorePercentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.scoreColor(widget.result.scorePercentage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip(
      String count, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.celebration_outlined,
              size: 56, color: AppTheme.successGreen),
          const SizedBox(height: 16),
          const Text(
            'Perfect Score!',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'You got all questions correct.',
            style:
                TextStyle(fontSize: 14, color: AppTheme.textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionReviewCard(AnsweredQuestion aq, int index) {
    final isCorrect = aq.isCorrect;
    final isExpanded = _expandedIndex == index;
    final letters = ['A', 'B', 'C', 'D'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? AppTheme.successGreen.withValues(alpha: 0.3)
              : AppTheme.errorRed.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedIndex = isExpanded ? -1 : index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: isCorrect
                          ? AppTheme.successGreen
                          : AppTheme.errorRed,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      aq.question.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        height: 1.4,
                      ),
                      maxLines: isExpanded ? null : 2,
                      overflow:
                          isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: AppTheme.textLight,
                    size: 20,
                  ),
                ],
              ),

              // Compact answer pills
              if (!isExpanded) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (aq.selectedAnswer != -1)
                      _buildAnswerPill(
                        label: 'Your answer',
                        value:
                            '${letters[aq.selectedAnswer]}. ${aq.question.options[aq.selectedAnswer]}',
                        color: isCorrect
                            ? AppTheme.successGreen
                            : AppTheme.errorRed,
                        isCorrect: isCorrect,
                      )
                    else
                      _buildAnswerPill(
                        label: 'No Answer',
                        value: 'Timed out',
                        color: AppTheme.warningAmber,
                        isCorrect: false,
                      ),
                    if (!isCorrect) ...[
                      const SizedBox(width: 8),
                      _buildAnswerPill(
                        label: 'Correct',
                        value:
                            '${letters[aq.question.correctAnswer]}. ${aq.question.options[aq.question.correctAnswer]}',
                        color: AppTheme.successGreen,
                        isCorrect: true,
                      ),
                    ],
                  ],
                ),
              ],

              // Expanded detail view
              if (isExpanded) ...[
                const SizedBox(height: 14),
                const Divider(color: AppTheme.dividerGrey),
                const SizedBox(height: 10),
                const Text(
                  'Options',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMedium,
                  ),
                ),
                const SizedBox(height: 8),
                ...List.generate(aq.question.options.length, (i) {
                  final isUserAnswer = i == aq.selectedAnswer;
                  final isCorrectAnswer = i == aq.question.correctAnswer;

                  Color bgColor = Colors.transparent;
                  Color borderColor = AppTheme.dividerGrey;
                  Color textColor = AppTheme.textDark;
                  IconData? icon;

                  if (isCorrectAnswer) {
                    bgColor = AppTheme.successGreen.withValues(alpha: 0.08);
                    borderColor = AppTheme.successGreen.withValues(alpha: 0.4);
                    textColor = AppTheme.successGreen;
                    icon = Icons.check_circle;
                  } else if (isUserAnswer && !isCorrectAnswer) {
                    bgColor = AppTheme.errorRed.withValues(alpha: 0.08);
                    borderColor = AppTheme.errorRed.withValues(alpha: 0.4);
                    textColor = AppTheme.errorRed;
                    icon = Icons.cancel;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isCorrectAnswer
                                ? AppTheme.successGreen
                                : isUserAnswer
                                    ? AppTheme.errorRed
                                    : AppTheme.dividerGrey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              letters[i],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: isCorrectAnswer || isUserAnswer
                                    ? Colors.white
                                    : AppTheme.textMedium,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            aq.question.options[i],
                            style: TextStyle(
                              fontSize: 13,
                              color: textColor,
                              fontWeight:
                                  isCorrectAnswer || isUserAnswer
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                            ),
                          ),
                        ),
                        if (icon != null)
                          Icon(icon, size: 16, color: textColor),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppTheme.accentBlue.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 15, color: AppTheme.accentBlue),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          aq.question.explanation,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryBlue,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildTagChip(
                      aq.question.difficulty,
                      AppTheme.difficultyColor(aq.question.difficulty),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerPill(
      {required String label,
      required String value,
      required Color color,
      required bool isCorrect}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                  fontSize: 9,
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
