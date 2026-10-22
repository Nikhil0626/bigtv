class LevelProgress {
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final int? bestTimeMs;
  final int attemptsCount;
  final DateTime? firstCompletedAt;

  const LevelProgress({
    required this.levelNumber,
    this.isUnlocked = false,
    this.isCompleted = false,
    this.bestTimeMs,
    this.attemptsCount = 0,
    this.firstCompletedAt,
  });

  LevelProgress copyWith({
    int? levelNumber,
    bool? isUnlocked,
    bool? isCompleted,
    int? bestTimeMs,
    int? attemptsCount,
    DateTime? firstCompletedAt,
  }) {
    return LevelProgress(
      levelNumber: levelNumber ?? this.levelNumber,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      firstCompletedAt: firstCompletedAt ?? this.firstCompletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'bestTimeMs': bestTimeMs,
        'attemptsCount': attemptsCount,
        'firstCompletedAt': firstCompletedAt?.toIso8601String(),
      };

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      levelNumber: json['levelNumber'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      bestTimeMs: json['bestTimeMs'] as int?,
      attemptsCount: json['attemptsCount'] as int? ?? 0,
      firstCompletedAt: json['firstCompletedAt'] != null
          ? DateTime.tryParse(json['firstCompletedAt'] as String)
          : null,
    );
  }

  String get formattedBestTime {
    if (bestTimeMs == null) return '--:--';
    final totalSeconds = (bestTimeMs! / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final hours = minutes ~/ 60;
    if (hours > 0) {
      final remMinutes = minutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${remMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
