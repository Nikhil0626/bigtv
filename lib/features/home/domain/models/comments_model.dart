class CommentsModel {
  final dynamic id;
  final int postId;
  final String text;
  final DateTime createdAt;
  final ChatUser user;

  CommentsModel({
    required this.id,
    required this.postId,
    required this.text,
    required this.createdAt,
    required this.user,
  });

  factory CommentsModel.fromJson(Map<String, dynamic> json) {
    return CommentsModel(
      id: json['id'],
      postId: json['postId'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      user: ChatUser.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'user': user.toJson(),
    };
  }
}

class ChatUser {
  final int id;
  final String name;
  final dynamic avatar;

  ChatUser({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}
