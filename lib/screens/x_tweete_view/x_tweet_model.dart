class XTwitterModel {
  final int? id;
  final String? tweetId;
  final String? text;
  final int? retweetCount;
  final int? replyCount;
  final int? likeCount;
  final int? quoteCount;
  final int? bookmarkCount;
  final int? impressionCount;
  final String? userName;
  final int? viewCount;
  final String? imageUrl;
  final String? generatedData;
  final String? teluguText;
  final String? profileName;
  // final bool? isDisplay;
  final int? deletedUserId;
  // final DateTime? generatedTextTimestamp;
  final int? engagementCount;
  // final String? publishedBy;
  final String? provider;
  // final DateTime? updatedAt;
  // final DateTime? createdAt;
  final int? userId;
  final String? tweetCreatedAt;
  final String? location;
  final String? generatedTitle;
  final String? tweetUrl;
  final String? uploadedMedia;
  final String? pythonStatus;

  XTwitterModel({
    this.id,
    this.tweetId,
    this.text,
    this.retweetCount,
    this.replyCount,
    this.likeCount,
    this.quoteCount,
    this.bookmarkCount,
    this.impressionCount,
    this.userName,
    this.viewCount,
    this.imageUrl,
    this.generatedData,
    this.teluguText,
    this.profileName,
    // this.isDisplay,
    this.deletedUserId,
    // this.generatedTextTimestamp,
    this.engagementCount,
    // this.publishedBy,
    this.provider,
    // this.updatedAt,
    // this.createdAt,
    this.userId,
    this.tweetCreatedAt,
    this.location,
    this.generatedTitle,
    this.tweetUrl,
    this.uploadedMedia,
    this.pythonStatus,
  });

  factory XTwitterModel.fromJson(Map<String, dynamic> json) {
    return XTwitterModel(
      id: json['id'] as int?,
      tweetId: json['tweet_id'] as String?,
      text: json['text'] as String?,
      retweetCount: json['retweet_count'] as int?,
      replyCount: json['reply_count'] as int?,
      likeCount: json['like_count'] as int?,
      quoteCount: json['quote_count'] as int?,
      bookmarkCount: json['bookmark_count'] as int?,
      impressionCount: json['impression_count'] as int?,
      userName: json['user_name'] as String?,
      viewCount: json['view_count'] as int?,
      imageUrl: json['profile_pic'] as String?,
      generatedData: json['generated_data'] as String?,
      teluguText: json['telugu_text'] as String?,
      profileName: json['profile_name'] as String?,
      // isDisplay: json['is_display']?? false,
      deletedUserId: json['deleted_user_id'] as int?,
      // generatedTextTimestamp: json['generated_text_timestamp'] != null
      //     ? DateTime.parse(json['generated_text_timestamp'] as String)
      //     : null,
      engagementCount: json['engagement_count'] as int?,
      // publishedBy: json['published_by'] as String?,
      provider: json['provider'] as String?,
      // updatedAt: json['updated_at'] != null
      //     ? DateTime.parse(json['updated_at'] as String)
      //     : null,
      // createdAt: json['created_at'] != null
      //     ? DateTime.parse(json['created_at'] as String)
      //     : null,
      userId: json['user_id'] as int?,
      tweetCreatedAt: json['created_at']??"",
      location: json['localtion'] as String?,
      generatedTitle: json['generated_title'] as String?,
      tweetUrl: json['tweet_url'] as String?,
      uploadedMedia: json['uploaded_media'] as String?,
      pythonStatus: json['python_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tweet_id': tweetId,
      'text': text,
      'retweet_count': retweetCount,
      'reply_count': replyCount,
      'like_count': likeCount,
      'quote_count': quoteCount,
      'bookmark_count': bookmarkCount,
      'impression_count': impressionCount,
      'user_name': userName,
      'view_count': viewCount,
      'image_url': imageUrl,
      'generated_data': generatedData,
      'telugu_text': teluguText,
      'profile_name': profileName,
      // 'is_display': isDisplay,
      'deleted_user_id': deletedUserId,
      // 'generated_text_timestamp': generatedTextTimestamp?.toIso8601String(),
      'engagement_count': engagementCount,
      // 'published_by': publishedBy,
      'provider': provider,
      // 'updated_at': updatedAt?.toIso8601String(),
      // 'created_at': createdAt?.toIso8601String(),
      'user_id': userId,
      'tweet_created_at': tweetCreatedAt,
      'localtion': location,
      'generated_title': generatedTitle,
      'tweet_url': tweetUrl,
      'uploaded_media': uploadedMedia,
      'python_status': pythonStatus,
    };
  }
}
