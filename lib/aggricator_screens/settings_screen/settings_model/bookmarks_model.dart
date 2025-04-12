class BookmarksModel {
  final String postId;
  final bool isBookmarked;
  final String created;
  final String title;
  final String type;
  final String time;
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
      postId: json['postId'].toString() ?? "",
      isBookmarked: json['isBookmarked'] ?? false,
      created:json['created']??"" ,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      time:json['time']??"",
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'isBookmarked': isBookmarked,
      'created': created,
      'title': title,
      'type': type,
      'time': time,
      'imageUrl': imageUrl,
    };
  }
}
