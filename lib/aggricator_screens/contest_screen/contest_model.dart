class ContestModel {
  final String status;
  final String message;
  final List<AvailableDataModel> availableDataModel;
  final List<WinnerDataModel> winnerDataModel;
  final List<JoinDataModel> joinDataModel;

  ContestModel({
    required this.status,
    required this.message,
    required this.availableDataModel,
    required this.winnerDataModel,
    required this.joinDataModel,
  });

  factory ContestModel.fromJson(Map<String, dynamic> json) {
    return ContestModel(
      status: json['status'],
      message: json['message'],
      joinDataModel: (json['data'] as List)
          .map((item) => JoinDataModel.fromJson(item))
          .toList(),
      availableDataModel: (json['data'] as List)
          .map((item) => AvailableDataModel.fromJson(item))
          .toList(),
      winnerDataModel: (json['data'] as List)
          .map((item) => WinnerDataModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'contest_winners': winnerDataModel.map((e) => e.toJson()).toList(),
    'available_contests': availableDataModel.map((e) => e.toJson()).toList(),
    'joined_contests': joinDataModel.map((e) => e.toJson()).toList(),
  };
}

class JoinDataModel {
  final dynamic postId;
  final dynamic userId;
  final bool isParticipated;
  final dynamic userName;
  final dynamic postUrl;
  final dynamic userPic;
  final DateTime dateOfContest;
  final String contestName;
  final String statusOfContest;
  final dynamic contestImageUrl;

  JoinDataModel({
    required this.postId,
    required this.userId,
    required this.userName,
    required this.postUrl,
    required this.isParticipated,
    this.userPic,
    required this.dateOfContest,
    required this.contestName,
    required this.statusOfContest,
    required this.contestImageUrl,
  });

  factory JoinDataModel.fromJson(Map<String, dynamic> json) {
    return JoinDataModel(
      postId: json['postId'],
      userId: json['userId'],
      isParticipated: json['isParticipated'],
      userName: json['userName'],
      postUrl: json['postUrl'],
      userPic: json['userPic'],
      dateOfContest: DateTime.parse(json['dateOfContest']),
      contestName: json['contestName'],
      statusOfContest: json['statusOfContest'],
      contestImageUrl: json['contestImageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'postId': postId,
    'userId': userId,
    'isParticipated': isParticipated,
    'userName': userName,
    'postUrl': postUrl,
    'userPic': userPic,
    'dateOfContest': dateOfContest.toIso8601String(),
    'contestName': contestName,
    'statusOfContest': statusOfContest,
    'contestImageUrl': contestImageUrl,
  };
}

class WinnerDataModel {
  final int userId;
  final bool isParticipated;
  final String userName;
  final String postUrl;
  final String? userPic;
  final DateTime dateOfContest;
  final String contestName;
  final String statusOfContest;
  final String contestImageUrl;

  WinnerDataModel({
    required this.userId,
    required this.isParticipated,
    required this.userName,
    required this.postUrl,
    this.userPic,
    required this.dateOfContest,
    required this.contestName,
    required this.statusOfContest,
    required this.contestImageUrl,
  });

  factory WinnerDataModel.fromJson(Map<String, dynamic> json) {
    return WinnerDataModel(
      userId: json['userId'],
      isParticipated: json['isParticipated'],
      userName: json['userName'],
      postUrl: json['postUrl'],
      userPic: json['userPic'],
      dateOfContest: DateTime.parse(json['dateOfContest']),
      contestName: json['contestName'],
      statusOfContest: json['statusOfContest'],
      contestImageUrl: json['contestImageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'isParticipated': isParticipated,
    'userName': userName,
    'postUrl': postUrl,
    'userPic': userPic,
    'dateOfContest': dateOfContest.toIso8601String(),
    'contestName': contestName,
    'statusOfContest': statusOfContest,
    'contestImageUrl': contestImageUrl,
  };
}
class AvailableDataModel {
  final dynamic userId;
  final bool isParticipated;
  final dynamic userName;
  final dynamic postUrl;
  final dynamic userPic;
  final DateTime dateOfContest;
  final dynamic contestName;
  final dynamic statusOfContest;
  final dynamic contestImageUrl;

  AvailableDataModel({
    required this.userId,
    required this.isParticipated,
    required this.userName,
    required this.postUrl,
    this.userPic,
    required this.dateOfContest,
    required this.contestName,
    required this.statusOfContest,
    required this.contestImageUrl,
  });

  factory AvailableDataModel.fromJson(Map<String, dynamic> json) {
    return AvailableDataModel(
      userId: json['userId'],
      postUrl: json['postUrl'],
      isParticipated: json['isParticipated'],
      userName: json['userName'],
      userPic: json['userPic'],
      dateOfContest: DateTime.parse(json['dateOfContest']),
      contestName: json['contestName'],
      statusOfContest: json['statusOfContest'],
      contestImageUrl: json['contestImageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'postUrl': postUrl,
    'userName': userName,
    'userPic': userPic,
    'dateOfContest': dateOfContest.toIso8601String(),
    'contestName': contestName,
    'statusOfContest': statusOfContest,
    'contestImageUrl': contestImageUrl,
  };
}