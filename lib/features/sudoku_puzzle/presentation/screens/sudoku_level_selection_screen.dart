import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/zip_puzzle/data/models/level_definition.dart';
import 'package:chotanews/services/game_share_helper.dart';
import '../providers/sudoku_catalog_provider.dart';
import '../widgets/sudoku_level_tile.dart';
import 'sudoku_gameplay_screen.dart';
import 'sudoku_leaderboard_screen.dart';

class SudokuLevelSelectionScreen extends StatefulWidget {
  const SudokuLevelSelectionScreen({super.key});

  @override
  State<SudokuLevelSelectionScreen> createState() =>
      _SudokuLevelSelectionScreenState();
}

class _SudokuLevelSelectionScreenState
    extends State<SudokuLevelSelectionScreen> {
  ZipDifficulty? _selectedDifficulty; // null means 'All'

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SudokuCatalogProvider>(
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
              'Sudoku Puzzle',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.share_rounded,
                  color: Color(0xFF10B981),
                ),
                tooltip: 'Share Game',
                onPressed: () {
                  GameShareHelper.shareGame(
                    context: context,
                    gameSlug: 'sudoku',
                    gameTitle: 'Sudoku',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.leaderboard_rounded,
                    color: AppColorTokens.primaryRed),
                tooltip: 'Leaderboards',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SudokuLeaderboardScreen(
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Overall Progress',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? const Color(0xFF9E9E9E)
                                              : const Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${catalog.totalCompleted} / ${catalog.allLevels.length} Completed',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1F2937),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded,
                                            size: 18,
                                            color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${catalog.totalStars}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFB45309),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: catalog.allLevels.isEmpty
                                      ? 0
                                      : catalog.totalCompleted /
                                          catalog.allLevels.length,
                                  minHeight: 8,
                                  backgroundColor: isDark
                                      ? const Color(0xFF2C2C2C)
                                      : const Color(0xFFE5E7EB),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    AppColorTokens.primaryRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Difficulty Filter Chips
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  label: 'All (${catalog.allLevels.length})',
                                  isSelected: _selectedDifficulty == null,
                                  onSelected: () => setState(
                                      () => _selectedDifficulty = null),
                                  isDark: isDark,
                                ),
                                const SizedBox(width: 8),
                                ...ZipDifficulty.values.map((diff) {
                                  final count = catalog.allLevels
                                      .where((l) => l.difficulty == diff)
                                      .length;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: _buildFilterChip(
                                      label: '${diff.displayName} ($count)',
                                      isSelected:
                                          _selectedDifficulty == diff,
                                      onSelected: () => setState(
                                          () => _selectedDifficulty = diff),
                                      accentColor: diff.accentColor,
                                      isDark: isDark,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // 100-Level Grid
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final filtered = _selectedDifficulty == null
                                  ? catalog.allLevels
                                  : catalog.allLevels
                                      .where((l) =>
                                          l.difficulty ==
                                          _selectedDifficulty)
                                      .toList();

                              if (index >= filtered.length) return null;
                              final level = filtered[index];
                              final progress =
                                  catalog.getProgress(level.levelNumber);

                              return SudokuLevelTile(
                                level: level,
                                progress: progress,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          SudokuGameplayScreen(level: level),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: _selectedDifficulty == null
                                ? catalog.allLevels.length
                                : catalog.allLevels
                                    .where((l) =>
                                        l.difficulty == _selectedDifficulty)
                                    .length,
                          ),
                        ),
                      ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? accentColor,
    required bool isDark,
  }) {
    final effectiveAccent = accentColor ?? AppColorTokens.primaryRed;

    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected
              ? Colors.white
              : (isDark ? Colors.white70 : const Color(0xFF4B5563)),
        ),
      ),
      selected: isSelected,
      selectedColor: effectiveAccent,
      backgroundColor:
          isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
      side: BorderSide(
        color: isSelected
            ? effectiveAccent
            : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onSelected: (_) => onSelected(),
    );
  }
}
