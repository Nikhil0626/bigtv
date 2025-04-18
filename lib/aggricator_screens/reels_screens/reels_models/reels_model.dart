class ReelsModel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String publisher;
  final String publisherImage;
  final int likes;
  final int? comments;
  final int shares;
  final String duration;
  final String createdAt;
  final String postName;
  final String reportedBy;
  final List<String> links;
  final String content;
  final List<String>? gallery;

  ReelsModel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.publisher,
    required this.publisherImage,
    required this.likes,
    this.comments,
    required this.shares,
    required this.duration,
    required this.createdAt,
    required this.postName,
    required this.reportedBy,
    required this.links,
    required this.content,
    this.gallery,
  });

  factory ReelsModel.fromJson(Map<String, dynamic> json) {
    return ReelsModel(
      id: json['id'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      title: json['title'] as String,
      publisher: json['publisher'] as String,
      publisherImage: json['publisherImage'] as String,
      likes: json['likes'] as int,
      comments: json['comments'] as int?,
      shares: json['shares'] as int,
      duration: json['duration'] as String,
      createdAt: json['createdAt'] as String,
      postName: json['post_name'] as String? ?? '',
      reportedBy: json['reportedBy'] as String? ?? '',
      links: (json['links'] as List?)?.map((e) => e as String).toList() ?? [],
      content: json['content'] as String? ?? '',
      gallery: (json['gallery'] as List?)?.map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'publisher': publisher,
      'publisherImage': publisherImage,
      'likes': likes,
      'comments': comments,
      'shares': shares,
      'duration': duration,
      'createdAt': createdAt,
      'post_name': postName,
      'reportedBy': reportedBy,
      'links': links,
      'content': content,
      'gallery': gallery,
    };
  }
}
