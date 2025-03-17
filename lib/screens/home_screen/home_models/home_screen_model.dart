
class HomeScreenModel {
  final int id;
  final String author;
  final String title;
  final String content;
  final String type;
  final String? subType;
  final bool isSensitive;
  final bool isAd;
  final bool isBlurGallery;
  final bool isBigBlackStandard;
  final bool isTitleOnTop;
  final bool isLengthyPost;
  final bool isChotaBytes;
  final bool isStandardVideo;
  final bool isStandardFullVideo;
  final bool isBulletPost;
  final bool isStandardLink;
  final bool isBigStandardFullVideo;
  final bool isReporter;
  final bool isHomePage;
  final List<GalleryImage>? gallery;
  final ImageUrl imageUrl;
  final MediaUrl? videoUrl;
  final String? vdoUrl;
  final String? status;
  final String created;
  final int totalLikes;
  final bool isLiked;
  final int totalComments;
  final int totalViews;
  final int totalShares;
  final int categoryId;
  final String categoryName;
  final List<String>? bulletPoints;
  final List<LinkModel>? links;
  final String? reportedBy;
  final int postOrder;
  final bool isStickyPost;
  final List<HomeScreenModel>? homepage;
  final String? downloadUrl;
  // final String? choices;
  final String? adPosition;
  final String linkURLAndroid;
  final String linkURLIos;

  const HomeScreenModel({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.type,
    this.subType,
    required this.isSensitive,
    required this.isAd,
    required this.isBlurGallery,
    required this.isBigBlackStandard,
    required this.isTitleOnTop,
    required this.isLengthyPost,
    required this.isChotaBytes,
    required this.isStandardVideo,
    required this.isStandardFullVideo,
    required this.isBulletPost,
    required this.isStandardLink,
    required this.isBigStandardFullVideo,
    required this.isReporter,
    required this.isHomePage,
    this.gallery,
    required this.imageUrl,
    required this.videoUrl,
    this.vdoUrl,
    this.status,
    required this.created,
    required this.totalLikes,
    required this.isLiked,
    required this.totalComments,
    required this.totalViews,
    required this.totalShares,
    required this.categoryId,
    required this.categoryName,
    this.bulletPoints,
    this.links,
    this.reportedBy,
    required this.postOrder,
    required this.isStickyPost,
    this.homepage,
    this.downloadUrl,
    // this.choices,
    this.adPosition,
    required this.linkURLAndroid,
    required this.linkURLIos,
  });

  factory HomeScreenModel.fromJson(Map<String, dynamic> json) {
    return HomeScreenModel(
      id: json['id'] ?? 0,
      author: json['author'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      type: json['type'] ?? '',
      subType: json['subType'],
      isSensitive: json['isSensitive'] ?? false,
      isAd: json['isAd'] ?? false,
      isBlurGallery: json['isBlurGallery'] ?? false,
      isBigBlackStandard: json['isBigBlackStandard'] ?? false,
      isTitleOnTop: json['isTitleOnTop'] ?? false,
      isLengthyPost: json['isLengthyPost'] ?? false,
      isChotaBytes: json['isChotaBytes'] ?? false,
      isStandardVideo: json['isStandardVideo'] ?? false,
      isStandardFullVideo: json['isStandardFullVideo'] ?? false,
      isBulletPost: json['isBulletPost'] ?? false,
      isStandardLink: json['isStandardLink'] ?? false,
      isBigStandardFullVideo: json['isBigStandardFullVideo'] ?? false,
      isReporter: json['isReporter'] ?? false,
      isHomePage: json['isHomePage'] ?? false,
      gallery: json['gallery'] != null
          ? (json['gallery'] as List)
          .map((item) => GalleryImage.fromJson(item))
          .toList()
          : null,
      imageUrl: ImageUrl.fromJson(json['imageUrl'] ?? {}),
      videoUrl: MediaUrl.fromJson(json['videoUrl'] ?? {}),
      vdoUrl: json['vdoUrl'],
      status: json['status'],
      created: json['created'] ?? '',
      totalLikes: json['totalLikes'] ?? 0,
      isLiked: json['isLiked'] ?? false,
      totalComments: json['totalComments'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      categoryId: json['categoryId'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      bulletPoints: json['bulletPoints'] != null
          ? List<String>.from(json['bulletPoints'])
          : null,
      links: json['links'] != null
          ? (json['links'] as List)
          .map((item) => LinkModel.fromJson(item))
          .toList()
          : null,
      reportedBy: json['reportedBy'],
      postOrder: json['postOrder'] ?? 0,
      isStickyPost: json['isStickyPost'] ?? false,
      homepage:json['homepage'] != null
          ? (json['homepage'] as List)
          .map((item) => HomeScreenModel.fromJson(item)).toList()
          : null,
      downloadUrl: json['downloadUrl'],
      // choices: json['choices']??"",
      adPosition: json['adPosition'],
      linkURLAndroid: json['linkURLAndroid'] ?? '',
      linkURLIos: json['linkURLIos'] ?? '',
    );
  }
}

class Article {
  final int id;
  final String author;
  final String title;
  final String content;
  final String type;
  final String subType;
  final List<String> links;
  final String? reportedBy;
  final List<String>? gallery;
  final ImageUrl? imageUrl;
  final dynamic videoUrl;
  final int totalComments;
  final int totalShares;
  final DateTime created;
  final int totalLikes;
  final int totalViews;
  final String? linkURLAndroid;
  final String? linkURLIos;

  Article({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.type,
    required this.subType,
    required this.links,
    this.reportedBy,
    this.gallery,
    required this.imageUrl,
    this.videoUrl,
    required this.totalComments,
    required this.totalShares,
    required this.created,
    required this.totalLikes,
    required this.totalViews,
    this.linkURLAndroid,
    this.linkURLIos,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      author: json['author'],
      title: json['title'],
      subType: json['subType'],
      content: json['content'],
      type: json['type'],
      links: List<String>.from(json['links']),
      reportedBy: json['reportedBy'],
      gallery: json['gallery'] != null ? List<String>.from(json['gallery']) : null,
      imageUrl: json['imageUrl'] != null ? ImageUrl.fromJson(json['imageUrl']) : null,
      videoUrl: json['videoUrl']??null,
      totalComments: json['totalComments'],
      totalShares: json['totalShares'],
      created: DateTime.parse(json['created']),
      totalLikes: json['totalLikes'],
      totalViews: json['totalViews'],
      linkURLAndroid: json['linkURLAndroid'],
      linkURLIos: json['linkURLIos'],
    );
  }

}

class GalleryImage {
  final String url;
  final String? link;
  final String? otherUrl;
  final String? buttonText;

  const GalleryImage({
    required this.url,
    this.link,
    this.otherUrl,
    this.buttonText,
  });

  factory GalleryImage.fromJson(Map<String, dynamic> json) {
    return GalleryImage(
      url: json['url'] ?? '',
      link: json['link'],
      otherUrl: json['otherUrl'],
      buttonText: json['buttonText'],
    );
  }
}

class ImageUrl {
  final String url;
  final String? link;
  final String? otherUrl;
  final String? buttonText;

  const ImageUrl({
    required this.url,
    this.link,
    this.otherUrl,
    this.buttonText,
  });

  factory ImageUrl.fromJson(Map<String, dynamic> json) {
    return ImageUrl(
      url: json['url'] ?? '',
      link: json['link'],
      otherUrl: json['otherUrl'],
      buttonText: json['buttonText'],
    );
  }
}
class MediaUrl {
  String? url;
  String? link;
  String? otherUrl;
  String? buttonText;

  MediaUrl({this.url, this.link, this.otherUrl, this.buttonText});

  factory MediaUrl.fromJson(Map<String, dynamic> json) {
    return MediaUrl(
      url: json['url'] as String?,
      link: json['link'] as String?,
      otherUrl: json['otherUrl'] as String?,
      buttonText: json['buttonText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'link': link,
      'otherUrl': otherUrl,
      'buttonText': buttonText,
    };
  }
}


class LinkModel {
  final String id;
  final String value;

  LinkModel({required this.id, required this.value});

  // Convert JSON to LinkModel
  factory LinkModel.fromJson(Map<String, dynamic> json) {
    return LinkModel(
      id: json['id'],
      value: json['value'],
    );
  }

  // Convert LinkModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
    };
  }
}
