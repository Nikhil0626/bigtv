import 'dart:convert';

class AllPostCommentModel {
  final int id;
  final int postId;
  final String text;
  final int status;
  final String displayText;
  final int userId;
  final DateTime createdAt;
  final User user;
  final String redisId;

  AllPostCommentModel({
    required this.id,
    required this.postId,
    required this.text,
    required this.status,
    required this.displayText,
    required this.userId,
    required this.createdAt,
    required this.user,
    required this.redisId,
  });

  factory AllPostCommentModel.fromJson(Map<String, dynamic> json) {
    return AllPostCommentModel(
      id: json['_id'],
      postId: json['postId'],
      text: json['text'],
      status: json['status'],
      displayText: json['displayText'] ?? '',
      userId: json['userId'],
      createdAt: DateTime.parse(json['createdAt']),
      user: User.fromJson(json['user']),
      redisId: json['redisId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'postId': postId,
      'text': text,
      'status': status,
      'displayText': displayText,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
      'redisId': redisId,
    };
  }
}

class User {
  final int id;
  final String name;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      name: json['name'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}
