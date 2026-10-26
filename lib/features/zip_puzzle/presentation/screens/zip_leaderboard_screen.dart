import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../data/models/leaderboard_entry.dart';
import '../../data/repositories/zip_puzzle_repository.dart';
import '../providers/daily_puzzle_provider.dart';

class ZipLeaderboardScreen extends StatefulWidget {
  final int initialLevel;
  final int? totalLevels;
  final bool isDailyLeaderboard;

  const ZipLeaderboardScreen({
    super.key,
    this.initialLevel = 1,
    this.totalLevels,
    this.isDailyLeaderboard = false,
  });

  @override
  State<ZipLeaderboardScreen> createState() => _ZipLeaderboardScreenState();
}

class _ZipLeaderboardScreenState extends State<ZipLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final ZipPuzzleRepository _repository = ZipPuzzleRepository();
  late TabController _tabController;

  late int _selectedLevel;
  List<LeaderboardEntry> _practiceEntries = [];
  bool _isLoadingPractice = true;
  String _currentPlayerName = 'You';

  int get _maxLevels => widget.totalLevels ?? 100;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.initialLevel.clamp(1, _maxLevels);
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.isDailyLeaderboard ? 0 : 1,
    );
    _loadPracticeData();

    // Trigger daily leaderboard fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DailyPuzzleProvider>().loadTodayLeaderboard();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPracticeData() async {
    setState(() => _isLoadingPractice = true);
    final name = await _repository.getPlayerName();
    final entries = await _repository.getLeaderboardForLevel(_selectedLevel);
    if (!mounted) return;
    setState(() {
      _currentPlayerName = name;
      _practiceEntries = entries;
      _isLoadingPractice = false;
    });
  }

  void _onLevelChanged(int newLevel) {
    if (newLevel < 1 || newLevel > _maxLevels) return;
    setState(() {
      _selectedLevel = newLevel;
    });
    _loadPracticeData();
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
        title: const Text(
          'Leaderboards',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Change Player Name',
            onPressed: _editPlayerName,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColorTokens.primaryRed,
          labelColor: AppColorTokens.primaryRed,
          unselectedLabelColor: isDark ? Colors.white60 : const Color(0xFF6B7280),
          tabs: const [
            Tab(
              icon: Icon(Icons.bolt_rounded, size: 20),
              text: "Today's Speed",
            ),
            Tab(
              icon: Icon(Icons.extension_rounded, size: 20),
              text: 'Practice Levels',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Today's Speed Leaderboard (Daily Puzzle API)
          _buildDailyLeaderboardTab(context, isDark),

          // Tab 2: Practice Levels Local Records
          _buildPracticeLeaderboardTab(context, isDark),
        ],
      ),
    );
  }

  Widget _buildDailyLeaderboardTab(BuildContext context, bool isDark) {
    return Consumer<DailyPuzzleProvider>(
      builder: (context, dailyProvider, child) {
        if (dailyProvider.isLoadingLeaderboard &&
            dailyProvider.dailyLeaderboard == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final lb = dailyProvider.dailyLeaderboard;
        final currentUser = lb?.currentUser;
        final entries = lb?.entries ?? [];

        return RefreshIndicator(
          onRefresh: () => dailyProvider.loadTodayLeaderboard(),
          child: CustomScrollView(
            slivers: [
              // Pinned Current User Card
              if (currentUser != null)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF382312), const Color(0xFF1E1E1E)]
                            : [const Color(0xFFFFF7ED), const Color(0xFFFFFFFF)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.amber.shade400.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildRankMedal(currentUser.rank),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    currentUser.displayName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'YOU',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Rank #${currentUser.rank} on today\'s speed chart',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : const Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currentUser.formattedTime,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Subheading
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TODAY\'S RANKINGS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '${entries.length} solvers',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Entries List
              if (entries.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_off_outlined,
                            size: 56,
                            color: isDark ? const Color(0xFF555555) : const Color(0xFFCCCCCC),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No times recorded yet today',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Solve today\'s daily puzzle to claim Rank #1!',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];
                        final isYou = entry.playerId == dailyProvider.playerId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isYou
                                ? (isDark
                                    ? Colors.deepOrange.withValues(alpha: 0.12)
                                    : const Color(0xFFFFF7ED))
                                : (isDark
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isYou
                                  ? Colors.deepOrange.withValues(alpha: 0.5)
                                  : (isDark
                                      ? const Color(0xFF333333)
                                      : const Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildRankMedal(entry.rank),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          entry.displayName,
                                          style: TextStyle(
                                            fontWeight: isYou
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            fontSize: 15,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1F2937),
                                          ),
                                        ),
                                        if (isYou) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: Colors.deepOrange,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'YOU',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (entry.completedAt != null)
                                      Text(
                                        '${entry.completedAt!.hour.toString().padLeft(2, '0')}:${entry.completedAt!.minute.toString().padLeft(2, '0')} today',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isDark ? Colors.white54 : const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
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
                      childCount: entries.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPracticeLeaderboardTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Level Selector Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
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
                      _maxLevels,
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
                  onPressed: _selectedLevel < _maxLevels
                      ? () => _onLevelChanged(_selectedLevel + 1)
                      : null,
                ),
              ],
            ),
          ),
        ),

        // Device local info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android_rounded,
                size: 14,
                color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Local Records • Player: $_currentPlayerName',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 16),

        // Entries List
        Expanded(
          child: _isLoadingPractice
              ? const Center(child: CircularProgressIndicator())
              : _practiceEntries.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timer_off_outlined,
                            size: 56,
                            color: isDark ? const Color(0xFF555555) : const Color(0xFFCCCCCC),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No records yet for Level $_selectedLevel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Complete this level to set the first record!',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF888888) : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _practiceEntries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final entry = _practiceEntries[index];
                        final rank = index + 1;
                        final isCurrentPlayer = entry.playerName == _currentPlayerName;

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isCurrentPlayer
                                ? (isDark
                                    ? AppColorTokens.primaryRed.withValues(alpha: 0.12)
                                    : const Color(0xFFFFF0F0))
                                : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isCurrentPlayer
                                  ? AppColorTokens.primaryRed.withValues(alpha: 0.5)
                                  : (isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB)),
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildRankMedal(rank),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            color: isDark ? Colors.white : const Color(0xFF1F2937),
                                          ),
                                        ),
                                        if (isCurrentPlayer) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColorTokens.primaryRed,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'YOU',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
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
                                        color: isDark ? const Color(0xFF888888) : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
    );
  }

  Widget _buildRankMedal(int rank) {
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
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}
