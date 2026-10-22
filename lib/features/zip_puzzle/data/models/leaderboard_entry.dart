class LeaderboardEntry {
  final String id;
  final int levelNumber;
  final String playerName;
  final int elapsedMs;
  final DateTime timestamp;

  const LeaderboardEntry({
    required this.id,
    required this.levelNumber,
    required this.playerName,
    required this.elapsedMs,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'levelNumber': levelNumber,
        'playerName': playerName,
        'elapsedMs': elapsedMs,
        'timestamp': timestamp.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      id: json['id'] as String? ?? '',
      levelNumber: json['levelNumber'] as int,
      playerName: json['playerName'] as String? ?? 'You',
      elapsedMs: json['elapsedMs'] as int,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String get formattedTime {
    final totalSeconds = (elapsedMs / 1000).floor();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final tenths = ((elapsedMs % 1000) / 100).floor();
    final hours = minutes ~/ 60;
    if (hours > 0) {
      final remMinutes = minutes % 60;
      return '${hours.toString().padLeft(2, '0')}:${remMinutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.$tenths';
  }
}
