class SudokuLevelProgress {
  final int levelNumber;
  final bool isUnlocked;
  final bool isCompleted;
  final int? bestTimeMs;
  final int stars;

  const SudokuLevelProgress({
    required this.levelNumber,
    required this.isUnlocked,
    required this.isCompleted,
    this.bestTimeMs,
    this.stars = 0,
  });

  SudokuLevelProgress copyWith({
    int? levelNumber,
    bool? isUnlocked,
    bool? isCompleted,
    int? bestTimeMs,
    int? stars,
  }) {
    return SudokuLevelProgress(
      levelNumber: levelNumber ?? this.levelNumber,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      bestTimeMs: bestTimeMs ?? this.bestTimeMs,
      stars: stars ?? this.stars,
    );
  }

  Map<String, dynamic> toJson() => {
        'levelNumber': levelNumber,
        'isUnlocked': isUnlocked,
        'isCompleted': isCompleted,
        'bestTimeMs': bestTimeMs,
        'stars': stars,
      };

  factory SudokuLevelProgress.fromJson(Map<String, dynamic> json) {
    return SudokuLevelProgress(
      levelNumber: json['levelNumber'] as int,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      isCompleted: json['isCompleted'] as bool? ?? false,
      bestTimeMs: json['bestTimeMs'] as int?,
      stars: json['stars'] as int? ?? 0,
    );
  }

  String get formattedBestTime {
    if (bestTimeMs == null) return '--:--';
    final totalSec = (bestTimeMs! / 1000).floor();
    final mins = totalSec ~/ 60;
    final secs = totalSec % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }
}
