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
  final int isBookmarked;
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
    required this.isBookmarked,
    this.gallery,
  });

  factory ReelsModel.fromJson(Map<String, dynamic> json) {
    // Parse nested brand map if present
    final brandMap = json['brand'] is Map<String, dynamic>
        ? json['brand'] as Map<String, dynamic>
        : null;
    final brandName = brandMap?['name']?.toString();
    final brandLogo = brandMap?['logoUrl']?.toString();

    // Parse nested analytics map if present
    final analyticsMap = json['analytics'] is Map<String, dynamic>
        ? json['analytics'] as Map<String, dynamic>
        : null;
    final likeCount = analyticsMap?['likeCount'] is int
        ? analyticsMap!['likeCount'] as int
        : (json['likes'] is int ? json['likes'] as int : 0);
    final commentCount = analyticsMap?['commentCount'] is int
        ? analyticsMap!['commentCount'] as int
        : (json['comments'] is int ? json['comments'] as int : null);
    final shareCount = analyticsMap?['shareCount'] is int
        ? analyticsMap!['shareCount'] as int
        : (json['shares'] is int ? json['shares'] as int : 0);

    // Duration formatting
    final durationSec = json['durationSeconds'];
    final durationStr = durationSec != null
        ? "${durationSec}s"
        : (json['duration']?.toString() ?? '');

    return ReelsModel(
      id: json['id']?.toString() ?? '',
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      publisher: brandName ?? json['publisher']?.toString() ?? '',
      publisherImage: brandLogo ?? json['publisherImage']?.toString() ?? '',
      likes: likeCount,
      comments: commentCount,
      shares: shareCount,
      duration: durationStr,
      createdAt: json['createdAt']?.toString() ?? '',
      postName: json['post_name']?.toString() ?? '',
      reportedBy: json['reportedBy']?.toString() ?? '',
      links: (json['links'] as List?)?.map((e) => e.toString()).toList() ?? [],
      content: json['description']?.toString() ?? json['content']?.toString() ?? '',
      isBookmarked: json['isBookmarked'] as int? ?? 0,
      gallery: (json['gallery'] as List?)?.map((e) => e.toString()).toList(),
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
      'isBookmarked': isBookmarked,
      'gallery': gallery,
    };
  }
}
