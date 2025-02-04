import '../../home_screen/home_screen_model.dart';

class GetAllVideosModel {
  int? id;
  String? author;
  String? title;
  String? content;
  String? type;
  String? subType;
  bool? isSensitive;
  bool? isAd;
  bool? isBlurGallery;
  bool? isBigBlackStandard;
  bool? isTitleOnTop;
  bool? isLengthyPost;
  bool? isChotaBytes;
  bool? isStandardVideo;
  bool? isStandardFullVideo;
  bool? isBulletPost;
  bool? isStandardLink;
  bool? isBigStandardFullVideo;
  bool? isReporter;
  bool? isHomePage;
  final List<GalleryImage>? gallery;
  MediaUrl? imageUrl;
  MediaUrl? videoUrl;
  String? vdoUrl;
  String? status;
  String? created;
  int? totalLikes;
  bool? isLiked;
  int? totalComments;
  int? totalShares;
  String? categoryName;
  List<String>? bulletPoints;
  List<String>? links;
  String? reportedBy;
  String? postOrder;
  bool? isStickyPost;
  String? homepage;
  String? downloadUrl;
  int? totalViews;
  List<String>? choices;
  String? adPosition;
  String? linkURLAndroid;
  String? linkURLIos;

  GetAllVideosModel({
    this.id,
    this.author,
    this.title,
    this.content,
    this.type,
    this.subType,
    this.isSensitive,
    this.isAd,
    this.isBlurGallery,
    this.isBigBlackStandard,
    this.isTitleOnTop,
    this.isLengthyPost,
    this.isChotaBytes,
    this.isStandardVideo,
    this.isStandardFullVideo,
    this.isBulletPost,
    this.isStandardLink,
    this.isBigStandardFullVideo,
    this.isReporter,
    this.isHomePage,
    this.gallery,
    this.imageUrl,
    this.videoUrl,
    this.vdoUrl,
    this.status,
    this.created,
    this.totalLikes,
    this.isLiked,
    this.totalComments,
    this.totalShares,
    this.categoryName,
    this.bulletPoints,
    this.links,
    this.reportedBy,
    this.postOrder,
    this.isStickyPost,
    this.homepage,
    this.downloadUrl,
    this.totalViews,
    this.choices,
    this.adPosition,
    this.linkURLAndroid,
    this.linkURLIos,
  });

  factory GetAllVideosModel.fromJson(Map<String, dynamic> json) {
    return GetAllVideosModel(
      id: json['id'] as int?,
      author: json['author'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      type: json['type'] as String?,
      subType: json['subType'] as String?,
      isSensitive: json['isSensitive'] as bool?,
      isAd: json['isAd'] as bool?,
      isBlurGallery: json['isBlurGallery'] as bool?,
      isBigBlackStandard: json['isBigBlackStandard'] as bool?,
      isTitleOnTop: json['isTitleOnTop'] as bool?,
      isLengthyPost: json['isLengthyPost'] as bool?,
      isChotaBytes: json['isChotaBytes'] as bool?,
      isStandardVideo: json['isStandardVideo'] as bool?,
      isStandardFullVideo: json['isStandardFullVideo'] as bool?,
      isBulletPost: json['isBulletPost'] as bool?,
      isStandardLink: json['isStandardLink'] as bool?,
      isBigStandardFullVideo: json['isBigStandardFullVideo'] as bool?,
      isReporter: json['isReporter'] as bool?,
      isHomePage: json['isHomePage'] as bool?,
      gallery: json['gallery'] != null
          ? (json['gallery'] as List)
          .map((item) => GalleryImage.fromJson(item))
          .toList()
          : null,
      imageUrl: json['imageUrl'] != null ? MediaUrl.fromJson(json['imageUrl']) : null,
      videoUrl: json['videoUrl'] != null ? MediaUrl.fromJson(json['videoUrl']) : null,
      vdoUrl: json['vdoUrl'] as String?,
      status: json['status'] as String?,
      created: json['created'] as String?,
      totalLikes: json['totalLikes'] as int?,
      isLiked: json['isLiked'] as bool?,
      totalComments: json['totalComments'] as int?,
      totalShares: json['totalShares'] as int?,
      categoryName: json['categoryName'] as String?,
      bulletPoints: (json['bulletPoints'] as List<dynamic>?)?.cast<String>(),
      links: (json['links'] as List<dynamic>?)?.cast<String>(),
      reportedBy: json['reportedBy'] as String?,
      postOrder: json['postOrder'] as String?,
      isStickyPost: json['isStickyPost'] as bool?,
      homepage: json['homepage'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      totalViews: json['totalViews'] as int?,
      choices: (json['choices'] as List<dynamic>?)?.cast<String>(),
      adPosition: json['adPosition'] as String?,
      linkURLAndroid: json['linkURLAndroid'] as String?,
      linkURLIos: json['linkURLIos'] as String?,
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
      'videoUrl': videoUrl?.toJson(),
      'vdoUrl': vdoUrl,
      'status': status,
      'created': created,
      'totalLikes': totalLikes,
      'isLiked': isLiked,
      'totalComments': totalComments,
      'totalShares': totalShares,
      'categoryName': categoryName,
      'bulletPoints': bulletPoints,
      'links': links,
      'reportedBy': reportedBy,
      'postOrder': postOrder,
      'isStickyPost': isStickyPost,
      'homepage': homepage,
      'downloadUrl': downloadUrl,
      'totalViews': totalViews,
      'choices': choices,
      'adPosition': adPosition,
      'linkURLAndroid': linkURLAndroid,
      'linkURLIos': linkURLIos,
    };
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
