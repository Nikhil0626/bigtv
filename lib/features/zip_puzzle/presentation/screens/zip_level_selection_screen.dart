import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../data/models/level_definition.dart';
import '../providers/zip_catalog_provider.dart';
import '../widgets/zip_level_tile.dart';
import 'zip_gameplay_screen.dart';
import 'zip_leaderboard_screen.dart';

class ZipLevelSelectionScreen extends StatelessWidget {
  const ZipLevelSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ZipCatalogProvider>(
      builder: (context, catalog, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Zip Puzzle',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded),
                tooltip: 'Leaderboards',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const ZipLeaderboardScreen(initialLevel: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          body: catalog.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => catalog.refresh(),
                  child: CustomScrollView(
                    slivers: [
                      // Header Progress Card
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        const Color(0xFF2B1D1D),
                                        const Color(0xFF1E1E1E)
                                      ]
                                    : [
                                        const Color(0xFFFFF1F1),
                                        const Color(0xFFFFFFFF)
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF442222)
                                    : const Color(0xFFFFD5D5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Progress Overview',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: isDark
                                                  ? const Color(0xFFBDBDBD)
                                                  : const Color(0xFF6B7280),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${catalog.completedCount} / ${catalog.totalLevels} Solved',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppColorTokens.primaryRed,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppColorTokens.primaryRed
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Current: Lvl ${catalog.highestUnlockedLevel}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColorTokens.primaryRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: catalog.progressFraction,
                                    minHeight: 8,
                                    backgroundColor: isDark
                                        ? const Color(0xFF333333)
                                        : const Color(0xFFE5E7EB),
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            AppColorTokens.primaryRed),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Difficulty Filter Tabs
                      SliverToBoxAdapter(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              _buildFilterChip(
                                context: context,
                                label: 'All (100)',
                                isSelected:
                                    catalog.selectedDifficultyFilter == null,
                                onTap: () => catalog.setFilter(null),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context: context,
                                label: 'Easy (20)',
                                isSelected: catalog.selectedDifficultyFilter ==
                                    ZipDifficulty.easy,
                                onTap: () =>
                                    catalog.setFilter(ZipDifficulty.easy),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context: context,
                                label: 'Medium (30)',
                                isSelected: catalog.selectedDifficultyFilter ==
                                    ZipDifficulty.medium,
                                onTap: () =>
                                    catalog.setFilter(ZipDifficulty.medium),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context: context,
                                label: 'Hard (30)',
                                isSelected: catalog.selectedDifficultyFilter ==
                                    ZipDifficulty.hard,
                                onTap: () =>
                                    catalog.setFilter(ZipDifficulty.hard),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context: context,
                                label: 'Expert (20)',
                                isSelected: catalog.selectedDifficultyFilter ==
                                    ZipDifficulty.expert,
                                onTap: () =>
                                    catalog.setFilter(ZipDifficulty.expert),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 100 Levels Responsive Grid
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 0.85,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final level = catalog.filteredLevels[index];
                              final progress =
                                  catalog.getProgress(level.levelNumber);

                              return ZipLevelTile(
                                level: level,
                                progress: progress,
                                onTap: () {
                                  if (!progress.isUnlocked) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Level ${level.levelNumber} is locked. Complete Level ${level.levelNumber - 1} to unlock!'),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ZipGameplayScreen(level: level),
                                    ),
                                  ).then((_) {
                                    catalog.refresh();
                                  });
                                },
                              );
                            },
                            childCount: catalog.filteredLevels.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorTokens.primaryRed
              : (isDark ? const Color(0xFF222222) : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColorTokens.primaryRed
                : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563)),
          ),
        ),
      ),
    );
  }
}
