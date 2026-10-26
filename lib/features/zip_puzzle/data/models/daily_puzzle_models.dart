import '../models/zip_level_api_model.dart';

/// Represents an active game returned from GET /api/v1/games
class ActiveGameItem {
  final String id;
  final String slug;
  final String name;
  final String gameId;
  final String title;
  final String gameType;
  final String timezone;
  final String description;
  final String? iconUrl;
  final bool isActive;
  final bool dailyPublishEnabled;
  final int schemaVersion;
  final Map<String, dynamic>? metadata;
  final String? createdAt;
  final String? updatedAt;

  const ActiveGameItem({
    required this.id,
    required this.slug,
    required this.name,
    required this.gameId,
    required this.title,
    required this.gameType,
    required this.timezone,
    required this.description,
    this.iconUrl,
    required this.isActive,
    this.dailyPublishEnabled = true,
    this.schemaVersion = 1,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory ActiveGameItem.fromJson(Map<String, dynamic> json) {
    final slug = json['slug']?.toString() ?? json['gameId']?.toString() ?? '';
    final name = json['name']?.toString() ?? json['title']?.toString() ?? '';
    final gameId = json['gameId']?.toString() ?? slug;
    final title = json['title']?.toString() ?? name;

    return ActiveGameItem(
      id: json['id']?.toString() ?? '',
      slug: slug,
      name: name,
      gameId: gameId,
      title: title,
      gameType: json['gameType']?.toString() ?? 'zip',
      timezone: json['timezone']?.toString() ?? 'Asia/Kolkata',
      description: json['description']?.toString() ?? '',
      iconUrl: json['iconUrl']?.toString(),
      isActive: json['isActive'] == true || json['isActive'] == 'true',
      dailyPublishEnabled:
          json['dailyPublishEnabled'] == true || json['dailyPublishEnabled'] == 'true',
      schemaVersion:
          json['schemaVersion'] is int ? json['schemaVersion'] as int : 1,
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

/// Represents today's single daily puzzle returned from GET /api/v1/games/{gameId}/today
class DailyGameData {
  final String gameId;
  final String gameName;
  final String gameType;
  final String puzzleDate;
  final String timezone;
  final String levelId;
  final int levelNumber;
  final String title;
  final String difficulty;
  final int schemaVersion;
  final int contentVersion;
  final Map<String, dynamic> content;
  final String? logoUrl;

  const DailyGameData({
    required this.gameId,
    required this.gameName,
    required this.gameType,
    required this.puzzleDate,
    required this.timezone,
    required this.levelId,
    required this.levelNumber,
    required this.title,
    required this.difficulty,
    required this.schemaVersion,
    required this.contentVersion,
    required this.content,
    this.logoUrl,
  });

  factory DailyGameData.fromJson(Map<String, dynamic> json) {
    final rawLogo = json['logoUrl'] ??
        json['completionImageUrl'] ??
        json['backgroundImageUrl'] ??
        (json['content'] is Map ? json['content']['backgroundImage'] : null);

    return DailyGameData(
      gameId: json['gameId']?.toString() ?? json['slug']?.toString() ?? 'zip',
      gameName: json['gameName']?.toString() ??
          json['name']?.toString() ??
          json['title']?.toString() ??
          'Zip',
      gameType: json['gameType']?.toString() ?? 'zip',
      puzzleDate: json['puzzleDate']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? 'Asia/Kolkata',
      levelId: json['levelId']?.toString() ?? 'zip_001',
      levelNumber: json['levelNumber'] is int
          ? json['levelNumber'] as int
          : int.tryParse(json['levelNumber']?.toString() ?? '1') ?? 1,
      title: json['title']?.toString() ?? 'Daily Puzzle',
      difficulty: json['difficulty']?.toString() ?? 'easy',
      schemaVersion: json['schemaVersion'] is int ? json['schemaVersion'] as int : 1,
      contentVersion: json['contentVersion'] is int ? json['contentVersion'] as int : 1,
      content: json['content'] is Map ? Map<String, dynamic>.from(json['content'] as Map) : {},
      logoUrl: rawLogo?.toString(),
    );
  }

  int get rows {
    final grid = content['grid'];
    if (grid is Map) {
      return (grid['rows'] as num?)?.toInt() ?? 4;
    }
    return 4;
  }

  int get columns {
    final grid = content['grid'];
    if (grid is Map) {
      return (grid['columns'] as num?)?.toInt() ?? 4;
    }
    return 4;
  }

  int get checkpointsCount {
    final cps = content['checkpoints'];
    if (cps is List) {
      return cps.length;
    }
    return 0;
  }

  ZipLevelApiModel toApiModel() {
    return ZipLevelApiModel(
      gameId: gameId,
      gameType: gameType,
      levelId: levelId,
      levelNumber: levelNumber,
      title: title,
      schemaVersion: schemaVersion,
      difficulty: difficulty,
      content: content,
      logoUrl: logoUrl,
    );
  }
}

/// Result returned after submitting a puzzle completion via POST /api/v1/games/{gameId}/submit
class DailySubmissionResult {
  final String gameId;
  final String levelId;
  final int levelNumber;
  final String playerId;
  final int durationMs;
  final int bestDurationMs;
  final int score;
  final bool isNewBest;
  final int rank;
  final DailyStreakInfo streak;

  const DailySubmissionResult({
    required this.gameId,
    required this.levelId,
    required this.levelNumber,
    required this.playerId,
    required this.durationMs,
    required this.bestDurationMs,
    required this.score,
    required this.isNewBest,
    required this.rank,
    required this.streak,
  });

  factory DailySubmissionResult.fromJson(Map<String, dynamic> json) {
    return DailySubmissionResult(
      gameId: json['gameId']?.toString() ?? '',
      levelId: json['levelId']?.toString() ?? '',
      levelNumber: json['levelNumber'] is int
          ? json['levelNumber'] as int
          : int.tryParse(json['levelNumber']?.toString() ?? '1') ?? 1,
      playerId: json['playerId']?.toString() ?? '',
      durationMs: json['durationMs'] is int
          ? json['durationMs'] as int
          : int.tryParse(json['durationMs']?.toString() ?? '0') ?? 0,
      bestDurationMs: json['bestDurationMs'] is int
          ? json['bestDurationMs'] as int
          : int.tryParse(json['bestDurationMs']?.toString() ?? '0') ?? 0,
      score: json['score'] is int
          ? json['score'] as int
          : int.tryParse(json['score']?.toString() ?? '100') ?? 100,
      isNewBest: json['isNewBest'] == true,
      rank: json['rank'] is int
          ? json['rank'] as int
          : int.tryParse(json['rank']?.toString() ?? '1') ?? 1,
      streak: DailyStreakInfo.fromJson(
        json['streak'] is Map ? Map<String, dynamic>.from(json['streak'] as Map) : {},
      ),
    );
  }
}

class DailyStreakInfo {
  final int currentStreak;
  final int longestStreak;
  final bool streakMaintained;
  final bool freeMonthlyReviveApplied;

  const DailyStreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.streakMaintained,
    required this.freeMonthlyReviveApplied,
  });

  factory DailyStreakInfo.fromJson(Map<String, dynamic> json) {
    return DailyStreakInfo(
      currentStreak: json['currentStreak'] is int
          ? json['currentStreak'] as int
          : int.tryParse(json['currentStreak']?.toString() ?? '0') ?? 0,
      longestStreak: json['longestStreak'] is int
          ? json['longestStreak'] as int
          : int.tryParse(json['longestStreak']?.toString() ?? '0') ?? 0,
      streakMaintained: json['streakMaintained'] == true,
      freeMonthlyReviveApplied: json['freeMonthlyReviveApplied'] == true,
    );
  }
}

/// Today's leaderboard response from GET /api/v1/games/{gameId}/today/leaderboard
class DailyLeaderboardResponse {
  final String gameId;
  final String levelId;
  final DailyLeaderboardUser? currentUser;
  final List<DailyLeaderboardUser> entries;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const DailyLeaderboardResponse({
    required this.gameId,
    required this.levelId,
    this.currentUser,
    required this.entries,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory DailyLeaderboardResponse.fromJson(Map<String, dynamic> json) {
    final rawEntries = json['entries'];
    final List<DailyLeaderboardUser> entries = [];
    if (rawEntries is List) {
      for (final e in rawEntries) {
        if (e is Map) {
          entries.add(DailyLeaderboardUser.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    DailyLeaderboardUser? currentUser;
    if (json['currentUser'] is Map) {
      currentUser = DailyLeaderboardUser.fromJson(
        Map<String, dynamic>.from(json['currentUser'] as Map),
      );
    }

    return DailyLeaderboardResponse(
      gameId: json['gameId']?.toString() ?? '',
      levelId: json['levelId']?.toString() ?? '',
      currentUser: currentUser,
      entries: entries,
      page: json['page'] is int ? json['page'] as int : 1,
      limit: json['limit'] is int ? json['limit'] as int : 50,
      total: json['total'] is int ? json['total'] as int : entries.length,
      totalPages: json['totalPages'] is int ? json['totalPages'] as int : 1,
    );
  }
}

class DailyLeaderboardUser {
  final int rank;
  final String playerId;
  final String displayName;
  final String? avatarUrl;
  final int bestDurationMs;
  final int score;
  final DateTime? completedAt;

  const DailyLeaderboardUser({
    required this.rank,
    required this.playerId,
    required this.displayName,
    this.avatarUrl,
    required this.bestDurationMs,
    required this.score,
    this.completedAt,
  });

  factory DailyLeaderboardUser.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['completedAt'] != null) {
      parsedDate = DateTime.tryParse(json['completedAt'].toString());
    }

    return DailyLeaderboardUser(
      rank: json['rank'] is int ? json['rank'] as int : int.tryParse(json['rank']?.toString() ?? '0') ?? 0,
      playerId: json['playerId']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? 'Player',
      avatarUrl: json['avatarUrl']?.toString(),
      bestDurationMs: json['bestDurationMs'] is int
          ? json['bestDurationMs'] as int
          : int.tryParse(json['bestDurationMs']?.toString() ?? '0') ?? 0,
      score: json['score'] is int
          ? json['score'] as int
          : int.tryParse(json['score']?.toString() ?? '100') ?? 100,
      completedAt: parsedDate,
    );
  }

  String get formattedTime {
    final totalSeconds = (bestDurationMs / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final msPart = ((bestDurationMs % 1000) / 100).floor();
    if (minutes > 0) {
      return '$minutes:${seconds.toString().padLeft(2, '0')}.${msPart}s';
    }
    return '$seconds.${msPart}s';
  }
}

/// 7-Day streak calendar response from GET /api/v1/users/{playerId}/games/{gameId}/streak
class StreakCalendarResponse {
  final String playerId;
  final String gameId;
  final int currentStreak;
  final int longestStreak;
  final String lastActivityDate;
  final bool monthlyFreeReviveAvailable;
  final int autoApproveRemaining;
  final int gapDays;
  final bool canRequestRecovery;
  final List<StreakDayItem> last7Days;

  const StreakCalendarResponse({
    required this.playerId,
    required this.gameId,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.monthlyFreeReviveAvailable,
    required this.autoApproveRemaining,
    required this.gapDays,
    required this.canRequestRecovery,
    required this.last7Days,
  });

  factory StreakCalendarResponse.fromJson(Map<String, dynamic> json) {
    final rawDays = json['last7Days'];
    final List<StreakDayItem> days = [];
    if (rawDays is List) {
      for (final d in rawDays) {
        if (d is Map) {
          days.add(StreakDayItem.fromJson(Map<String, dynamic>.from(d)));
        }
      }
    }

    return StreakCalendarResponse(
      playerId: json['playerId']?.toString() ?? '',
      gameId: json['gameId']?.toString() ?? '',
      currentStreak: json['currentStreak'] is int
          ? json['currentStreak'] as int
          : int.tryParse(json['currentStreak']?.toString() ?? '0') ?? 0,
      longestStreak: json['longestStreak'] is int
          ? json['longestStreak'] as int
          : int.tryParse(json['longestStreak']?.toString() ?? '0') ?? 0,
      lastActivityDate: json['lastActivityDate']?.toString() ?? '',
      monthlyFreeReviveAvailable: json['monthlyFreeReviveAvailable'] == true,
      autoApproveRemaining: json['autoApproveRemaining'] is int
          ? json['autoApproveRemaining'] as int
          : int.tryParse(json['autoApproveRemaining']?.toString() ?? '2') ?? 2,
      gapDays: json['gapDays'] is int
          ? json['gapDays'] as int
          : int.tryParse(json['gapDays']?.toString() ?? '0') ?? 0,
      canRequestRecovery: json['canRequestRecovery'] == true,
      last7Days: days,
    );
  }
}

class StreakDayItem {
  final String date;
  final String dayName;
  final bool completed;
  final bool isToday;

  const StreakDayItem({
    required this.date,
    required this.dayName,
    required this.completed,
    required this.isToday,
  });

  factory StreakDayItem.fromJson(Map<String, dynamic> json) {
    return StreakDayItem(
      date: json['date']?.toString() ?? '',
      dayName: json['dayName']?.toString() ?? '',
      completed: json['completed'] == true,
      isToday: json['isToday'] == true,
    );
  }
}

/// Streak recovery result from POST /api/v1/users/{playerId}/games/{gameId}/streak/recovery-request
class StreakRecoveryResponse {
  final bool success;
  final String status; // AUTO_APPROVED, PENDING
  final String message;
  final int? restoredStreak;
  final int? autoApproveRemaining;
  final List<String> missedDates;
  final String? requestId;

  const StreakRecoveryResponse({
    required this.success,
    required this.status,
    required this.message,
    this.restoredStreak,
    this.autoApproveRemaining,
    this.missedDates = const [],
    this.requestId,
  });

  bool get isAutoApproved => status == 'AUTO_APPROVED';
  bool get isPending => status == 'PENDING';

  factory StreakRecoveryResponse.fromJson(Map<String, dynamic> json) {
    final rawDates = json['missedDates'];
    final List<String> missedDates = [];
    if (rawDates is List) {
      for (final d in rawDates) {
        if (d != null) missedDates.add(d.toString());
      }
    }

    return StreakRecoveryResponse(
      success: json['success'] == true,
      status: json['status']?.toString() ?? 'UNKNOWN',
      message: json['message']?.toString() ?? '',
      restoredStreak: json['restoredStreak'] is int
          ? json['restoredStreak'] as int
          : (json['restoredStreak'] != null ? int.tryParse(json['restoredStreak'].toString()) : null),
      autoApproveRemaining: json['autoApproveRemaining'] is int
          ? json['autoApproveRemaining'] as int
          : (json['autoApproveRemaining'] != null ? int.tryParse(json['autoApproveRemaining'].toString()) : null),
      missedDates: missedDates,
      requestId: json['requestId']?.toString(),
    );
  }
}

/// User games profile overview item from GET /api/v1/users/{playerId}/games
class UserGameProfileItem {
  final String gameId;
  final String title;
  final int levelsCompleted;
  final int bestTimeMs;
  final int totalScore;
  final int currentStreak;
  final int longestStreak;
  final String lastActivityDate;
  final bool monthlyFreeReviveAvailable;

  const UserGameProfileItem({
    required this.gameId,
    required this.title,
    required this.levelsCompleted,
    required this.bestTimeMs,
    required this.totalScore,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActivityDate,
    required this.monthlyFreeReviveAvailable,
  });

  factory UserGameProfileItem.fromJson(Map<String, dynamic> json) {
    return UserGameProfileItem(
      gameId: json['gameId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      levelsCompleted: json['levelsCompleted'] is int
          ? json['levelsCompleted'] as int
          : int.tryParse(json['levelsCompleted']?.toString() ?? '0') ?? 0,
      bestTimeMs: json['bestTimeMs'] is int
          ? json['bestTimeMs'] as int
          : int.tryParse(json['bestTimeMs']?.toString() ?? '0') ?? 0,
      totalScore: json['totalScore'] is int
          ? json['totalScore'] as int
          : int.tryParse(json['totalScore']?.toString() ?? '0') ?? 0,
      currentStreak: json['currentStreak'] is int
          ? json['currentStreak'] as int
          : int.tryParse(json['currentStreak']?.toString() ?? '0') ?? 0,
      longestStreak: json['longestStreak'] is int
          ? json['longestStreak'] as int
          : int.tryParse(json['longestStreak']?.toString() ?? '0') ?? 0,
      lastActivityDate: json['lastActivityDate']?.toString() ?? '',
      monthlyFreeReviveAvailable: json['monthlyFreeReviveAvailable'] == true,
    );
  }
}
