import 'package:flutter/material.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/zip_puzzle/data/models/leaderboard_entry.dart';
import '../../data/repositories/patches_catalog.dart';
import '../../data/repositories/patches_puzzle_repository.dart';

class PatchesLeaderboardScreen extends StatefulWidget {
  final int initialLevel;

  const PatchesLeaderboardScreen({super.key, this.initialLevel = 1});

  @override
  State<PatchesLeaderboardScreen> createState() =>
      _PatchesLeaderboardScreenState();
}

class _PatchesLeaderboardScreenState extends State<PatchesLeaderboardScreen> {
  final PatchesPuzzleRepository _repository = PatchesPuzzleRepository();
  late int _selectedLevel;
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;
  String _currentPlayerName = 'You';

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel.clamp(1, PatchesCatalog.totalLevels);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final name = await _repository.getPlayerName();
    final entries = await _repository.getLeaderboardForLevel(_selectedLevel);
    if (!mounted) return;
    setState(() {
      _currentPlayerName = name;
      _entries = entries;
      _isLoading = false;
    });
  }

  void _onLevelChanged(int newLevel) {
    if (newLevel < 1 || newLevel > PatchesCatalog.totalLevels) return;
    setState(() {
      _selectedLevel = newLevel;
    });
    _loadData();
  }

  void _editPlayerName() {
    final controller = TextEditingController(text: _currentPlayerName);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Edit Display Name'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Player Name',
              hintText: 'Enter your name',
            ),
            maxLength: 20,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await _repository.setPlayerName(newName);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                  }
                  if (mounted) {
                    setState(() => _currentPlayerName = newName);
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patches Leaderboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Change Player Name',
            onPressed: _editPlayerName,
          ),
        ],
      ),
      body: Column(
        children: [
          // Level Selector Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF333333)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded),
                    onPressed: _selectedLevel > 1
                        ? () => _onLevelChanged(_selectedLevel - 1)
                        : null,
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _selectedLevel,
                      items: List.generate(
                        PatchesCatalog.totalLevels,
                        (index) => DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text(
                            'Level ${index + 1}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val != null) _onLevelChanged(val);
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded),
                    onPressed: _selectedLevel < PatchesCatalog.totalLevels
                        ? () => _onLevelChanged(_selectedLevel + 1)
                        : null,
                  ),
                ],
              ),
            ),
          ),

          // Honest labeling badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_android_rounded,
                  size: 14,
                  color: isDark
                      ? const Color(0xFF9E9E9E)
                      : const Color(0xFF6B7280),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'Device Local Leaderboard • Player: $_currentPlayerName',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 16),

          // Entries List or Empty State
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.timer_off_outlined,
                              size: 56,
                              color: isDark
                                  ? const Color(0xFF555555)
                                  : const Color(0xFFCCCCCC),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No records yet for Level $_selectedLevel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF4B5563),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Complete this level to set the first record!',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? const Color(0xFF888888)
                                    : const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: _entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final entry = _entries[index];
                          final rank = index + 1;
                          final isCurrentPlayer =
                              entry.playerName == _currentPlayerName;

                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isCurrentPlayer
                                  ? (isDark
                                      ? AppColorTokens.primaryRed
                                          .withValues(alpha: 0.12)
                                      : const Color(0xFFFFF0F0))
                                  : (isDark
                                      ? const Color(0xFF1E1E1E)
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isCurrentPlayer
                                    ? AppColorTokens.primaryRed
                                        .withValues(alpha: 0.5)
                                    : (isDark
                                        ? const Color(0xFF333333)
                                        : const Color(0xFFE5E7EB)),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Rank Badge
                                _buildRankBadge(rank),
                                const SizedBox(width: 14),

                                // Player Name + Date
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            entry.playerName,
                                            style: TextStyle(
                                              fontWeight: isCurrentPlayer
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                              fontSize: 15,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1F2937),
                                            ),
                                          ),
                                          if (isCurrentPlayer) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 1),
                                              decoration: BoxDecoration(
                                                color:
                                                    AppColorTokens.primaryRed,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: const Text(
                                                'YOU',
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')} ${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark
                                              ? const Color(0xFF888888)
                                              : const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Time
                                Text(
                                  entry.formattedTime,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    fontFamily: 'monospace',
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

  Widget _buildRankBadge(int rank) {
    if (rank == 1) {
      return const CircleAvatar(
        radius: 14,
        backgroundColor: Color(0xFFFFD700),
        child: Icon(Icons.emoji_events_rounded, size: 16, color: Colors.white),
      );
    } else if (rank == 2) {
      return const CircleAvatar(
        radius: 14,
        backgroundColor: Color(0xFFC0C0C0),
        child: Icon(Icons.emoji_events_rounded, size: 16, color: Colors.white),
      );
    } else if (rank == 3) {
      return const CircleAvatar(
        radius: 14,
        backgroundColor: Color(0xFFCD7F32),
        child: Icon(Icons.emoji_events_rounded, size: 16, color: Colors.white),
      );
    }
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.transparent,
      child: Text(
        '#$rank',
        style: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
