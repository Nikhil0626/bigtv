class CommentsModel {
  final dynamic id;
  final dynamic postId;
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
    DateTime parsedDate;
    try {
      final raw = json['createdAt']?.toString().trim() ?? '';
      if (raw.endsWith('Z') || raw.contains('+') || RegExp(r'-\d{2}:\d{2}$').hasMatch(raw)) {
        parsedDate = DateTime.parse(raw).toUtc();
      } else {
        final iso = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
        parsedDate = DateTime.parse('${iso}Z').toUtc();
      }
    } catch (_) {
      parsedDate = DateTime.now().toUtc();
    }

    return CommentsModel(
      id: json['id'] ?? 0,
      postId: json['postId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      createdAt: parsedDate,
      user: json['user'] is Map<String, dynamic>
          ? ChatUser.fromJson(json['user'] as Map<String, dynamic>)
          : (json['user'] is Map
              ? ChatUser.fromJson(Map<String, dynamic>.from(json['user'] as Map))
              : ChatUser(id: 0, name: 'Anonymous', avatar: '')),
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
  final dynamic id;
  final String name;
  final dynamic avatar;

  ChatUser({
    required this.id,
    required this.name,
    required this.avatar,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? 'Anonymous',
      avatar: json['avatar']?.toString() ?? '',
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

