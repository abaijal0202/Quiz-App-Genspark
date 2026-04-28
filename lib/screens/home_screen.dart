import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/quiz_provider.dart';
import '../services/question_service.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import 'quiz_screen.dart';
import 'history_screen.dart';
import '../widgets/category_card.dart';
import '../widgets/stats_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().loadHistory();
      
      final questionService = context.read<QuestionService>();
      if (questionService.loadError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(questionService.loadError!),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  void _onCategoryTap(CategoryModel category) async {
    final provider = context.read<QuizProvider>();
    await provider.startQuiz(category);

    if (!mounted) return;

    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    if (provider.state == QuizState.inProgress) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QuizScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch QuizProvider to rebuild when sync completes or isLoading changes
    context.watch<QuizProvider>();
    final categories = context.read<QuestionService>().categories;

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildStatsSection()),
            SliverToBoxAdapter(child: _buildSectionTitle('Select Category')),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return CategoryCard(
                      category: categories[index],
                      onTap: () => _onCategoryTap(categories[index]),
                    );
                  },
                  childCount: categories.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      color: AppTheme.surfaceWhite,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.quiz_outlined,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quiz Master',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  letterSpacing: 0.2,
                ),
              ),
              Text(
                'Test your knowledge',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMedium,
                ),
              ),
            ],
          ),
          const Spacer(),
          Consumer<QuizProvider>(
            builder: (context, provider, _) {
              return IconButton(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                        try {
                          await provider.syncQuestions();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Successfully synced with online question bank'),
                                backgroundColor: AppTheme.successGreen,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Sync failed: $e'),
                                backgroundColor: AppTheme.errorRed,
                              ),
                            );
                          }
                        }
                      },
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.primaryBlue,
                        ))
                    : const Icon(Icons.sync),
                color: AppTheme.textMedium,
                tooltip: 'Sync Questions',
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
            icon: const Icon(Icons.history_outlined),
            color: AppTheme.textMedium,
            tooltip: 'Quiz History',
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        if (provider.history.isEmpty) {
          return _buildWelcomeBanner();
        }
        return const Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: StatsBar(),
        );
      },
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.accentBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.waving_hand_outlined,
              color: AppTheme.accentBlue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome to Quiz Master!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a category below to start your first quiz.',
                  style: TextStyle(
                    color: AppTheme.textMedium,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDark,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
