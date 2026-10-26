import 'package:flutter/material.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import '../../data/repositories/sudoku_catalog.dart';
import '../../data/repositories/sudoku_puzzle_repository.dart';

class SudokuLeaderboardScreen extends StatefulWidget {
  final int initialLevel;

  const SudokuLeaderboardScreen({super.key, this.initialLevel = 1});

  @override
  State<SudokuLeaderboardScreen> createState() =>
      _SudokuLeaderboardScreenState();
}

class _SudokuLeaderboardScreenState extends State<SudokuLeaderboardScreen> {
  final SudokuPuzzleRepository _repository = SudokuPuzzleRepository();
  late int _selectedLevel;
  List<SudokuLeaderboardEntry> _entries = [];
  String _displayName = 'Player';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final name = await _repository.getPlayerDisplayName();
    final list = await _repository.getLeaderboard(_selectedLevel);
    if (mounted) {
      setState(() {
        _displayName = name;
        _entries = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: _displayName);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          title: Text(
            'Change Player Name',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 15,
            decoration: const InputDecoration(
              hintText: 'Enter your name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorTokens.primaryRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && result.trim().isNotEmpty) {
      await _repository.setPlayerDisplayName(result.trim());
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
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
          'Sudoku Leaderboards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Bar: Player Profile & Level Dropdown Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Player Name Pill
                InkWell(
                  onTap: _showEditNameDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF282828)
                          : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF383838)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_rounded,
                            size: 16, color: AppColorTokens.primaryRed),
                        const SizedBox(width: 6),
                        Text(
                          _displayName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.edit_rounded,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF9E9E9E)
                                : const Color(0xFF6B7280)),
                      ],
                    ),
                  ),
                ),

                // Level Selector Dropdown
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF282828)
                        : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF383838)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedLevel,
                      dropdownColor:
                          isDark ? const Color(0xFF282828) : Colors.white,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: List.generate(SudokuCatalog.totalLevels, (i) {
                        final levelNum = i + 1;
                        final lvl = SudokuCatalog.getLevel(levelNum);
                        return DropdownMenuItem<int>(
                          value: levelNum,
                          child: Text(
                            'Level $levelNum (${lvl.difficulty.displayName})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedLevel = val);
                          _loadData();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Subtitle Note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: isDark
                ? const Color(0xFF16181B)
                : const Color(0xFFF9FAFB),
            child: Text(
              'Leaderboard shows best finish times on this device.',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),

          const Divider(height: 1),

          // Leaderboard Entries List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColorTokens.primaryRed,
                    ),
                  )
                : _entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.emoji_events_outlined,
                              size: 64,
                              color: isDark
                                  ? const Color(0xFF404040)
                                  : const Color(0xFFD1D5DB),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No records for Level $_selectedLevel yet!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? const Color(0xFF9E9E9E)
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Solve this level to place on the board.',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF6B7280)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _entries.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          final rank = index + 1;

                          Color rankColor;
                          if (rank == 1) {
                            rankColor = const Color(0xFFF59E0B); // Gold
                          } else if (rank == 2) {
                            rankColor = const Color(0xFF9CA3AF); // Silver
                          } else if (rank == 3) {
                            rankColor = const Color(0xFFD97706); // Bronze
                          } else {
                            rankColor = isDark
                                ? const Color(0xFF6B7280)
                                : const Color(0xFF9CA3AF);
                          }

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: entry.isUser
                                    ? AppColorTokens.primaryRed
                                        .withValues(alpha: 0.5)
                                    : (isDark
                                        ? const Color(0xFF333333)
                                        : const Color(0xFFE5E7EB)),
                                width: entry.isUser ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Rank Badge
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: rankColor.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$rank',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: rankColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Player Name
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.playerName,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : const Color(0xFF1F2937),
                                        ),
                                      ),
                                      if (entry.isUser)
                                        const Text(
                                          'You',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                AppColorTokens.primaryRed,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // Time Taken
                                Text(
                                  entry.formattedTime,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColorTokens.primaryRed,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
