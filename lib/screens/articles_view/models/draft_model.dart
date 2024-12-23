class DraftModel {
  final int id;
  final String profileName;
  final String username;
  final String status;
  final DateTime createdAt;
  final String url;
  final DateTime? updatedAt;
  final String? profilePic;
  final int userId;
  final int? deletedBy;
  final bool isVerified;
  final String? backgroundProfilePic;
  final dynamic isUpdatedBy;
  final dynamic timeInterval;
  final String type;
  final String tweetId;
  final String text;
  final int retweetCount;
  final int replyCount;
  final int likeCount;
  final int quoteCount;
  final int bookmarkCount;
  final int impressionCount;
  final String userName;
  final int viewCount;
  final String? imageUrl;
  final String? generatedData;
  final String teluguText;
  final bool isDisplay;
  final int deletedUserId;
  final String? generatedTextTimestamp;
  final int engagementCount;
  final dynamic publishedBy;
  final String provider;
  final DateTime tweetCreatedAt;
  final dynamic location;
  final String generatedTitle;
  final String tweetUrl;
  final dynamic uploadedMedia;
  final String pythonStatus;
  final int titleWordCount;
  final int? titleCharacterCount;
  final int? bodyCharacterCount;
  final int bodyWordCount;
  final int responseTime;
  final int teluguTextCount;
  final dynamic publishedAt;
  final String? gptEnglishText;
  final dynamic scheduledBy;
  final dynamic scheduledAt;
  final String draftBy;
  final dynamic draftAt;

  DraftModel({
    required this.id,
    required this.profileName,
    required this.username,
    required this.status,
    required this.createdAt,
    required this.url,
    this.updatedAt,
    this.profilePic,
    required this.userId,
    this.deletedBy,
    required this.isVerified,
    this.backgroundProfilePic,
    this.isUpdatedBy,
    this.timeInterval,
    required this.type,
    required this.tweetId,
    required this.text,
    required this.retweetCount,
    required this.replyCount,
    required this.likeCount,
    required this.quoteCount,
    required this.bookmarkCount,
    required this.impressionCount,
    required this.userName,
    required this.viewCount,
    this.imageUrl,
    this.generatedData,
    required this.teluguText,
    required this.isDisplay,
    required this.deletedUserId,
    this.generatedTextTimestamp,
    required this.engagementCount,
    required this.publishedBy,
    required this.provider,
    required this.tweetCreatedAt,
    this.location,
    required this.generatedTitle,
    required this.tweetUrl,
    this.uploadedMedia,
    required this.pythonStatus,
    required this.titleWordCount,
    this.titleCharacterCount,
    this.bodyCharacterCount,
    required this.bodyWordCount,
    required this.responseTime,
    required this.teluguTextCount,
    this.publishedAt,
    this.gptEnglishText,
    this.scheduledBy,
    this.scheduledAt,
    required this.draftBy,
    this.draftAt,
  });

  factory DraftModel.fromJson(Map<String, dynamic> json) {
    return DraftModel(
      id: json['id'],
      profileName: json['profile_name'],
      username: json['username'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      url: json['url'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      profilePic: json['profile_pic'],
      userId: json['user_id'],
      deletedBy: json['deleted_by'],
      isVerified: json['is_verified'] == "1",
      backgroundProfilePic: json['background_profile_pic'],
      isUpdatedBy: json['is_updated_by'],
      timeInterval: json['time_interval'],
      type: json['type'],
      tweetId: json['tweet_id'],
      text: json['text'],
      retweetCount: json['retweet_count'],
      replyCount: json['reply_count'],
      likeCount: json['like_count'],
      quoteCount: json['quote_count'],
      bookmarkCount: json['bookmark_count'],
      impressionCount: json['impression_count'],
      userName: json['user_name'],
      viewCount: json['view_count'],
      imageUrl: json['image_url'],
      generatedData: json['generated_data'],
      teluguText: json['telugu_text'],
      isDisplay: json['is_display'] == "1",
      deletedUserId: json['deleted_user_id'],
      generatedTextTimestamp: json['generated_text_timestamp'],
      engagementCount: json['engagement_count'],
      publishedBy: json['published_by'],
      provider: json['provider'],
      tweetCreatedAt: DateTime.parse(json['tweet_created_at']),
      location: json['localtion'],
      generatedTitle: json['generated_title'],
      tweetUrl: json['tweet_url'],
      uploadedMedia: json['uploaded_media'],
      pythonStatus: json['python_status'],
      titleWordCount: json['title_word_count'],
      titleCharacterCount: json['title_character_count'],
      bodyCharacterCount: json['body_character_count'],
      bodyWordCount: json['body_word_count'],
      responseTime: json['response_time'],
      teluguTextCount: json['telugu_text_count'],
      publishedAt: json['published_at'],
      gptEnglishText: json['GPT_English_text'],
      scheduledBy: json['scheduled_by'],
      scheduledAt: json['scheduled_at'],
      draftBy: json['draft_by'],
      draftAt: json['draft_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_name': profileName,
      'username': username,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'url': url,
      'updated_at': updatedAt?.toIso8601String(),
      'profile_pic': profilePic,
      'user_id': userId,
      'deleted_by': deletedBy,
      'is_verified': isVerified ? "1" : "0",
      'background_profile_pic': backgroundProfilePic,
      'is_updated_by': isUpdatedBy,
      'time_interval': timeInterval,
      'type': type,
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
      'is_display': isDisplay ? "1" : "0",
      'deleted_user_id': deletedUserId,
      'generated_text_timestamp': generatedTextTimestamp,
      'engagement_count': engagementCount,
      'published_by': publishedBy,
      'provider': provider,
      'tweet_created_at': tweetCreatedAt.toIso8601String(),
      'localtion': location,
      'generated_title': generatedTitle,
      'tweet_url': tweetUrl,
      'uploaded_media': uploadedMedia,
      'python_status': pythonStatus,
      'title_word_count': titleWordCount,
      'title_character_count': titleCharacterCount,
      'body_character_count': bodyCharacterCount,
      'body_word_count': bodyWordCount,
      'response_time': responseTime,
      'telugu_text_count': teluguTextCount,
      'published_at': publishedAt,
      'GPT_English_text': gptEnglishText,
      'scheduled_by': scheduledBy,
      'scheduled_at': scheduledAt,
      'draft_by': draftBy,
      'draft_at': draftAt,
    };
  }
}


