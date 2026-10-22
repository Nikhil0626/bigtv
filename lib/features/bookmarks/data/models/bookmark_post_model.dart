class BookmarkPostModel {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final String created;
  final String postUrl;
  final String linkUrlAndroid;
  final String linkUrlIos;
  final String type;
  final String subType;
  final List<String> categoryName;
  final bool isBookmarked;
  final int totalLikes;
  final int totalViews;
  final int totalComments;
  final int totalShares;
  final Map<String, dynamic> rawJson;

  BookmarkPostModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.created,
    required this.postUrl,
    required this.linkUrlAndroid,
    required this.linkUrlIos,
    required this.type,
    required this.subType,
    required this.categoryName,
    required this.isBookmarked,
    required this.totalLikes,
    required this.totalViews,
    required this.totalComments,
    required this.totalShares,
    required this.rawJson,
  });

  factory BookmarkPostModel.fromJson(Map<String, dynamic> json) {
    List<String> categories = [];
    if (json['categoryName'] is List) {
      categories = (json['categoryName'] as List)
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return BookmarkPostModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ??
          json['imageUrl']?.toString() ??
          json['image']?.toString() ??
          '',
      created: json['created']?.toString() ??
          json['createdAt']?.toString() ??
          '',
      postUrl: json['postUrl']?.toString() ?? '',
      linkUrlAndroid: json['linkURLAndroid']?.toString() ?? '',
      linkUrlIos: json['linkURLIos']?.toString() ?? '',
      type: json['type']?.toString() ?? 'Standard',
      subType: json['subType']?.toString() ?? '',
      categoryName: categories,
      isBookmarked: json['isBookmarked'] == true ||
          json['isBookmarked'] == 1 ||
          json['isBookmarked'] == 'true',
      totalLikes: int.tryParse(json['totalLikes']?.toString() ?? '0') ?? 0,
      totalViews: int.tryParse(json['totalViews']?.toString() ?? '0') ?? 0,
      totalComments: int.tryParse(json['totalComments']?.toString() ?? '0') ?? 0,
      totalShares: int.tryParse(json['totalShares']?.toString() ?? '0') ?? 0,
      rawJson: json,
    );
  }

  Map<String, dynamic> toMap() => rawJson;
}
