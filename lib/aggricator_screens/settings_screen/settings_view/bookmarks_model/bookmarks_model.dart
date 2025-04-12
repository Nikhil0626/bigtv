class BookmarksModel {
  final int postId;
  final bool isBookmarked;
  final DateTime created;
  final String title;
  final String type;
  final DateTime time;
  final String imageUrl;

  BookmarksModel({
    required this.postId,
    required this.isBookmarked,
    required this.created,
    required this.title,
    required this.type,
    required this.time,
    required this.imageUrl,
  });

  factory BookmarksModel.fromJson(Map<String, dynamic> json) {
    return BookmarksModel(
      postId: json['postid'] ?? 0,
      isBookmarked: json['isbookmarked'] ?? false,
      created: DateTime.tryParse(json['created'] ?? '') ?? DateTime.now(),
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      time: DateTime.tryParse(json['time'] ?? '') ?? DateTime.now(),
      imageUrl: json['image_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postid': postId,
      'isbookmarked': isBookmarked,
      'created': created.toIso8601String(),
      'title': title,
      'type': type,
      'time': time.toIso8601String(),
      'image_url': imageUrl,
    };
  }
}
