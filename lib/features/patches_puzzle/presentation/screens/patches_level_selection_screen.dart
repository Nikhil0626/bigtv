import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import '../providers/patches_catalog_provider.dart';
import '../widgets/patches_level_tile.dart';
import 'patches_gameplay_screen.dart';
import 'patches_leaderboard_screen.dart';

class PatchesLevelSelectionScreen extends StatefulWidget {
  const PatchesLevelSelectionScreen({super.key});

  @override
  State<PatchesLevelSelectionScreen> createState() =>
      _PatchesLevelSelectionScreenState();
}

class _PatchesLevelSelectionScreenState
    extends State<PatchesLevelSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<PatchesCatalogProvider>(
      builder: (context, catalog, child) {
        return Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
          appBar: AppBar(
            backgroundColor:
                isDark ? const Color(0xFF1E1E1E) : Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Patches Puzzle',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded,
                    color: AppColorTokens.primaryRed),
                tooltip: 'Leaderboards',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PatchesLeaderboardScreen(
                        initialLevel: 1,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: catalog.isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColorTokens.primaryRed,
                  ),
                )
              : RefreshIndicator(
                  color: AppColorTokens.primaryRed,
                  onRefresh: () => catalog.refresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header Progress Banner
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF333333)
                                  : const Color(0xFFE5E7EB),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.3 : 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
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
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? const Color(0xFF9E9E9E)
                                                : const Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${catalog.solvedCount} / 100 Solved',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF111827),
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
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
                                isSelected:
                                    catalog.selectedDifficultyFilter ==
                                        ZipDifficulty.easy,
                                onTap: () =>
                                    catalog.setFilter(ZipDifficulty.easy),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context: context,
                                label: 'Medium (30)',
                                isSelected:
                                    catalog.selectedDifficultyFilter ==
                                        ZipDifficulty.medium,
                                onTap: () =>
                                    catalog.setFilter(ZipDifficulty.medium),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context: context,
                                label: 'Hard (30)',
                                isSelected:
                                    catalog.selectedDifficultyFilter ==
                                        ZipDifficulty.hard,
                                onTap: () =>
                                    catalog.setFilter(ZipDifficulty.hard),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                context: context,
                                label: 'Expert (20)',
                                isSelected:
                                    catalog.selectedDifficultyFilter ==
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

                              return PatchesLevelTile(
                                level: level,
                                progress: progress,
                                onTap: () {
                                  if (!progress.isUnlocked) {
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
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
                                          PatchesGameplayScreen(
                                              level: level),
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
              : (isDark
                  ? const Color(0xFF222222)
                  : const Color(0xFFF3F4F6)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColorTokens.primaryRed
                : (isDark
                    ? const Color(0xFF333333)
                    : const Color(0xFFE5E7EB)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFF4B5563)),
          ),
        ),
      ),
    );
  }
}
