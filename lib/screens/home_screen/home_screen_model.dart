class HomeScreenModel {
  final int id;
  final String author;
  final String title;
  final String content;
  final String type;
  final String subType;
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
  final dynamic gallery;
  final ImageUrl? imageUrl;

  HomeScreenModel({
    required this.id,
    required this.author,
    required this.title,
    required this.content,
    required this.type,
    required this.subType,
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
    this.imageUrl,
  });

  factory HomeScreenModel.fromJson(Map<String, dynamic> json) {
    return HomeScreenModel(
      id: json['id'],
      author: json['author'],
      title: json['title'],
      content: json['content'],
      type: json['type'],
      subType: json['subType'],
      isSensitive: json['isSensitive'],
      isAd: json['isAd'],
      isBlurGallery: json['isBlurGallery'],
      isBigBlackStandard: json['isBigBlackStandard'],
      isTitleOnTop: json['isTitleOnTop'],
      isLengthyPost: json['isLengthyPost'],
      isChotaBytes: json['isChotaBytes'],
      isStandardVideo: json['isStandardVideo'],
      isStandardFullVideo: json['isStandardFullVideo'],
      isBulletPost: json['isBulletPost'],
      isStandardLink: json['isStandardLink'],
      isBigStandardFullVideo: json['isBigStandardFullVideo'],
      isReporter: json['isReporter'],
      isHomePage: json['isHomePage'],
      gallery: json['gallery'],
      imageUrl: json['imageUrl'] != null
          ? ImageUrl.fromJson(json['imageUrl'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'title': title,
      'content': content,
      'type': type,
      'subType': subType,
      'isSensitive': isSensitive,
      'isAd': isAd,
      'isBlurGallery': isBlurGallery,
      'isBigBlackStandard': isBigBlackStandard,
      'isTitleOnTop': isTitleOnTop,
      'isLengthyPost': isLengthyPost,
      'isChotaBytes': isChotaBytes,
      'isStandardVideo': isStandardVideo,
      'isStandardFullVideo': isStandardFullVideo,
      'isBulletPost': isBulletPost,
      'isStandardLink': isStandardLink,
      'isBigStandardFullVideo': isBigStandardFullVideo,
      'isReporter': isReporter,
      'isHomePage': isHomePage,
      'gallery': gallery,
      'imageUrl': imageUrl?.toJson(),
    };
  }
}

class ImageUrl {
  final String url;
  final String link;
  final dynamic otherUrl;
  final dynamic buttonText;

  ImageUrl({
    required this.url,
    required this.link,
    this.otherUrl,
    this.buttonText,
  });

  factory ImageUrl.fromJson(Map<String, dynamic> json) {
    return ImageUrl(
      url: json['url'],
      link: json['link'],
      otherUrl: json['otherUrl'],
      buttonText: json['buttonText'],
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
