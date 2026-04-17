import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_provider.dart';
import '../models/quiz_result_model.dart';
import '../theme/app_theme.dart';
import 'review_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text(
          'Quiz History',
          style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textDark),
        ),
        actions: [
          Consumer<QuizProvider>(
            builder: (context, provider, _) {
              if (provider.history.isEmpty) return const SizedBox.shrink();
              return TextButton.icon(
                onPressed: () => _confirmClear(context, provider),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Clear'),
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.errorRed),
              );
            },
          ),
        ],
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, _) {
          final history = provider.history;

          if (history.isEmpty) {
            return _buildEmptyState();
          }

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildOverallStats(history)),
                SliverToBoxAdapter(child: _buildScoreChart(history)),
                SliverToBoxAdapter(
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Text(
                      'Recent Quizzes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildHistoryCard(
                          context, history[index], index),
                      childCount: history.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.lightBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.history_outlined,
                size: 40, color: AppTheme.primaryBlue),
          ),
          const SizedBox(height: 20),
          const Text(
            'No History Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete a quiz to see your history here.',
            style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildOverallStats(List<QuizResult> history) {
    final avgScore = history
            .map((r) => r.scorePercentage)
            .reduce((a, b) => a + b) /
        history.length;
    final bestScore = history
        .map((r) => r.scorePercentage)
        .reduce((a, b) => a > b ? a : b);
    final totalQ =
        history.fold<int>(0, (sum, r) => sum + r.totalQuestions);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 6),
              Text(
                'Overall Statistics',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(
                  '${avgScore.toStringAsFixed(0)}%', 'Avg Score',
                  Colors.white),
              _buildStatChip(
                  '${bestScore.toStringAsFixed(0)}%', 'Best Score',
                  Colors.white),
              _buildStatChip('${history.length}', 'Quizzes', Colors.white),
              _buildStatChip('$totalQ', 'Questions', Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreChart(List<QuizResult> history) {
    final chartData = history.reversed.take(10).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Score Trend (Last 10)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: chartData.map((result) {
                final height = (result.scorePercentage / 100) * 72 + 4;
                final color = AppTheme.scoreColor(result.scorePercentage);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${result.scorePercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 8,
                              color: color,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                                color: color.withValues(alpha: 0.5),
                                width: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
      BuildContext context, QuizResult result, int index) {
    final scoreColor = AppTheme.scoreColor(result.scorePercentage);
    final dateStr = _formatDate(result.completedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerGrey),
      ),
      child: InkWell(
        onTap: result.mistakes.isNotEmpty
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ReviewScreen(result: result)),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: index == 0
                      ? AppTheme.primaryBlue.withValues(alpha: 0.1)
                      : AppTheme.backgroundGrey,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: index == 0
                        ? AppTheme.primaryBlue.withValues(alpha: 0.3)
                        : AppTheme.dividerGrey,
                  ),
                ),
                child: Center(
                  child: Text(
                    index == 0 ? '★' : '#${index + 1}',
                    style: TextStyle(
                      fontSize: index == 0 ? 16 : 11,
                      color: index == 0
                          ? AppTheme.primaryBlue
                          : AppTheme.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.categoryName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          dateStr,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textLight),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.textLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${result.correctAnswers}/${result.totalQuestions} correct',
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${result.scorePercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: scoreColor,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      result.grade,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: scoreColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (result.mistakes.isNotEmpty) ...[
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right,
                    color: AppTheme.textLight, size: 18),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _confirmClear(BuildContext context, QuizProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text(
            'All quiz history will be permanently deleted.',
            style: TextStyle(color: AppTheme.textMedium, fontSize: 14)),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await provider.clearHistory();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style:
                TextButton.styleFrom(foregroundColor: AppTheme.errorRed),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
