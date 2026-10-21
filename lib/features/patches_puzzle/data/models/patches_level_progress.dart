class PatchesLevelProgress {
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final int? bestTimeMs;
  final int attemptsCount;
  final DateTime? lastCompletedAt;

  const PatchesLevelProgress({
    required this.levelNumber,
    required this.isUnlocked,
    this.isCompleted = false,
    this.bestTimeMs,
    this.attemptsCount = 0,
    this.lastCompletedAt,
  });

  String? get formattedBestTime {
    if (bestTimeMs == null) return null;
    final totalSeconds = (bestTimeMs! / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  PatchesLevelProgress copyWith({
    int? levelNumber,
    bool? isUnlocked,
    bool? isCompleted,
    int? bestTimeMs,
    int? attemptsCount,
    DateTime? lastCompletedAt,
  }) {
    return PatchesLevelProgress(
      levelNumber: levelNumber ?? this.levelNumber,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'bestTimeMs': bestTimeMs,
        'attemptsCount': attemptsCount,
        'lastCompletedAt': lastCompletedAt?.toIso8601String(),
      };

  factory PatchesLevelProgress.fromJson(Map<String, dynamic> json) =>
      PatchesLevelProgress(
        levelNumber: json['levelNumber'] as int,
        isUnlocked: json['isUnlocked'] as bool? ?? false,
        isCompleted: json['isCompleted'] as bool? ?? false,
        bestTimeMs: json['bestTimeMs'] as int?,
        attemptsCount: json['attemptsCount'] as int? ?? 0,
        lastCompletedAt: json['lastCompletedAt'] != null
            ? DateTime.tryParse(json['lastCompletedAt'] as String)
            : null,
      );
}
