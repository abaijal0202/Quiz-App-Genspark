import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_provider.dart';
import '../theme/app_theme.dart';

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        final history = provider.history;
        if (history.isEmpty) return const SizedBox.shrink();

        final recentScores = history.take(5).toList();
        final avgScore = recentScores
                .map((r) => r.scorePercentage)
                .reduce((a, b) => a + b) /
            recentScores.length;
        final bestScore = recentScores
            .map((r) => r.scorePercentage)
            .reduce((a, b) => a > b ? a : b);

        return Container(
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
                'Recent Performance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatItem(
                    label: 'Avg Score',
                    value: '${avgScore.toStringAsFixed(0)}%',
                    color: AppTheme.scoreColor(avgScore),
                  ),
                  _buildDivider(),
                  _buildStatItem(
                    label: 'Best Score',
                    value: '${bestScore.toStringAsFixed(0)}%',
                    color: AppTheme.successGreen,
                  ),
                  _buildDivider(),
                  _buildStatItem(
                    label: 'Quizzes',
                    value: '${history.length}',
                    color: AppTheme.primaryBlue,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildMiniChart(recentScores.reversed.toList()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
      {required String label, required String value, required Color color}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: AppTheme.dividerGrey,
    );
  }

  Widget _buildMiniChart(List<dynamic> scores) {
    return SizedBox(
      height: 40,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          for (int i = 0; i < scores.length; i++) ...[
            Flexible(
              child: _buildBar(scores[i].scorePercentage),
            ),
            if (i < scores.length - 1) const SizedBox(width: 4),
          ],
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildBar(double percentage) {
    final color = AppTheme.scoreColor(percentage);
    final height = (percentage / 100) * 36 + 4;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }
}
