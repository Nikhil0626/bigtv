class PollOption {
  final int id;
  final String text;
  final int votes;
  final double percentage;
  final bool selected;

  PollOption({
    required this.id,
    required this.text,
    required this.votes,
    required this.percentage,
    this.selected = false,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : (int.tryParse(json['id']?.toString() ?? '') ??
              (json['option'] is num
                  ? (json['option'] as num).toInt()
                  : int.tryParse(json['option']?.toString() ?? '') ?? 0)),
      text: json['text'] ?? json['option_name'] ?? json['option']?.toString() ?? '',
      votes: json['votes'] is num
          ? (json['votes'] as num).toInt()
          : int.tryParse(json['votes']?.toString() ?? '') ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ??
          double.tryParse(json['percentage']?.toString() ?? '') ??
          0.0,
      selected: json['selected'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
      'percentage': percentage,
      'selected': selected,
    };
  }
}

class PollData {
  final int totalVotes;
  final bool userHasVoted;
  final int? userVotedOption;
  final List<PollOption> options;

  PollData({
    required this.totalVotes,
    required this.userHasVoted,
    this.userVotedOption,
    required this.options,
  });

  factory PollData.fromJson(Map<String, dynamic> json) {
    var rawOpts = json['options'] as List? ?? json['poll_options'] as List? ?? [];
    return PollData(
      totalVotes: json['totalVotes'] is num
          ? (json['totalVotes'] as num).toInt()
          : int.tryParse(json['totalVotes']?.toString() ?? '') ??
              (json['total_votes'] is num
                  ? (json['total_votes'] as num).toInt()
                  : int.tryParse(json['total_votes']?.toString() ?? '') ?? 0),
      userHasVoted: json['userHasVoted'] == true || json['user_has_voted'] == true,
      userVotedOption: json['userVotedOption'] is num
          ? (json['userVotedOption'] as num).toInt()
          : int.tryParse(json['userVotedOption']?.toString() ?? '') ??
              (json['user_voted_option'] is num
                  ? (json['user_voted_option'] as num).toInt()
                  : int.tryParse(json['user_voted_option']?.toString() ?? '')),
      options: rawOpts
          .map((o) => PollOption.fromJson(Map<String, dynamic>.from(o as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalVotes': totalVotes,
      'userHasVoted': userHasVoted,
      'userVotedOption': userVotedOption,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

