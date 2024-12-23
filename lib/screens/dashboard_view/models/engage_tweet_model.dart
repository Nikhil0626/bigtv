
class EngageTweetModel {
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
  final String? profilePic;
  final String? isDisplay;
  final int? deletedUserId;
  final String? generatedTextTimestamp;
  final int? engagementCount;
  final int? publishedBy;
  final String? provider;
  // final DateTime updatedAt;
  // final DateTime createdAt;
  final int? userId;
  final String? tweetCreatedAt;
  final String? location;
  final String? generatedTitle;
  final String? tweetUrl;
  final String? uploadedMedia;

  EngageTweetModel({
    required this.id,
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
    required this.profileName,
    required this.profilePic,
    required this.isDisplay,
    required this.deletedUserId,
    this.generatedTextTimestamp,
    required this.engagementCount,
    required this.publishedBy,
    required this.provider,
    // required this.updatedAt,
    // required this.createdAt,
    required this.userId,
    required this.tweetCreatedAt,
    this.location,
    this.generatedTitle,
    required this.tweetUrl,
    this.uploadedMedia,
  });

  factory EngageTweetModel.fromJson(Map<String, dynamic> json) {
    return EngageTweetModel(
      id: json['id'],
      tweetId: json['tweet_id'],
      text: json['text'],
      retweetCount: json['retweet_count'],
      replyCount: json['reply_count'],
      likeCount: json['like_count'],
      quoteCount: json['quote_count'],
      bookmarkCount: json['bookmark_count'],
      impressionCount: json['impression_count'],
      userName: json['username'],
      viewCount: json['view_count'],
      imageUrl: json['image_url'],
      generatedData: json['generated_data'],
      teluguText: json['telugu_text'],
      profileName: json['user_name'],
      profilePic: json['profile_pic'],
      isDisplay: json['is_display'],
      deletedUserId: json['deleted_user_id'],
      generatedTextTimestamp: json['generated_text_timestamp'],
      engagementCount: json['engagement_count'],
      publishedBy: json['published_by'],
      provider: json['provider'],
      // updatedAt: DateTime.parse(json['updated_at']),
      // createdAt: DateTime.parse(json['created_at']),
      userId: json['user_id'],
      tweetCreatedAt: json['tweet_created_at'],
      location: json['localtion'],
      generatedTitle: json['generated_title'],
      tweetUrl: json['tweet_url'],
      uploadedMedia: json['uploaded_media'],
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
      'profile_pic': profilePic,
      'is_display': isDisplay,
      'deleted_user_id': deletedUserId,
      'generated_text_timestamp': generatedTextTimestamp,
      'engagement_count': engagementCount,
      'published_by': publishedBy,
      'provider': provider,
      // 'updated_at': updatedAt.toIso8601String(),
      // 'created_at': createdAt.toIso8601String(),
      'user_id': userId,
      'tweet_created_at': tweetCreatedAt,
      'localtion': location,
      'generated_title': generatedTitle,
      'tweet_url': tweetUrl,
      'uploaded_media': uploadedMedia,
    };
  }
}



class ZonesModel {
  final int id;
  final String toneName;
  final String tonePrompt;
  final String toneTelugu;
  final String? toneTeluguPrompt;

  ZonesModel({
    required this.id,
    required this.toneName,
    required this.tonePrompt,
    required this.toneTelugu,
    this.toneTeluguPrompt,
  });

  factory ZonesModel.fromJson(Map<String, dynamic> json) {
    return ZonesModel(
      id: json['id'] ?? 0,
      toneName: json['tone_name'] ?? '',
      tonePrompt: json['tone_prompt'] ?? '',
      toneTelugu: json['tone_telugu'] ?? '',
      toneTeluguPrompt: json['tone_telugu_prompt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tone_name': toneName,
      'tone_prompt': tonePrompt,
      'tone_telugu': toneTelugu,
      'tone_telugu_prompt': toneTeluguPrompt,
    };
  }
}


class PublishedTweetsModel {
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
  final String? isDisplay;
  final int? deletedUserId;
  final String? generatedTextTimestamp;
  final int? engagementCount;
  final String? publishedBy;
  final String? provider;
  final String? updatedAt;
  final String? createdAt;
  final String? tweetCreatedAt;
  final String? location;
  final String? generatedTitle;
  final String? tweetUrl;
  // final List<String>? uploadedMedia;
  final String? pythonStatus;
  final int? titleWordCount;
  final int? titleCharacterCount;
  final int? bodyCharacterCount;
  final int? bodyWordCount;
  final int? responseTime;
  final int? teluguTextCount;
  final String? publishedAt;
  final String? gptEnglishText;
  final dynamic scheduledBy;
  final String? scheduledAt;
  final dynamic draftBy;
  final String? draftAt;

  PublishedTweetsModel({
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
    this.isDisplay,
    this.deletedUserId,
    this.generatedTextTimestamp,
    this.engagementCount,
    this.publishedBy,
    this.provider,
    this.updatedAt,
    this.createdAt,
    this.tweetCreatedAt,
    this.location,
    this.generatedTitle,
    this.tweetUrl,
    // this.uploadedMedia,
    this.pythonStatus,
    this.titleWordCount,
    this.titleCharacterCount,
    this.bodyCharacterCount,
    this.bodyWordCount,
    this.responseTime,
    this.teluguTextCount,
    this.publishedAt,
    this.gptEnglishText,
    this.scheduledBy,
    this.scheduledAt,
    this.draftBy,
    this.draftAt,
  });

  factory PublishedTweetsModel.fromJson(Map<String, dynamic> json) {
    return PublishedTweetsModel(
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
      imageUrl: json['image_url'] as String?,
      generatedData: json['generated_data'] as String?,
      teluguText: json['telugu_text'] as String?,
      profileName: json['profile_name'] as String?,
      isDisplay: json['is_display'] as String?,
      deletedUserId: json['deleted_user_id'] as int?,
      generatedTextTimestamp: json['generated_text_timestamp'] as String?,
      engagementCount: json['engagement_count'] as int?,
      publishedBy: json['published_by'] as String?,
      provider: json['provider'] as String?,
      updatedAt: json['updated_at'] as String?,
      createdAt: json['created_at'] as String?,
      tweetCreatedAt: json['tweet_created_at'] as String?,
      location: json['localtion'] as String?, // corrected field name
      generatedTitle: json['generated_title'] as String?,
      tweetUrl: json['tweet_url'] as String?,
      // uploadedMedia: (json['uploaded_media'].tose)
      //     ?.map((e) => e as String)
      //     .toList(),
      pythonStatus: json['python_status'] as String?,
      titleWordCount: json['title_word_count'] as int?,
      titleCharacterCount: json['title_character_count'] as int?,
      bodyCharacterCount: json['body_character_count'] as int?,
      bodyWordCount: json['body_word_count'] as int?,
      responseTime: json['response_time'] as int?,
      teluguTextCount: json['telugu_text_count'] as int?,
      publishedAt: json['published_at'] as String?,
      gptEnglishText: json['GPT_English_text'] as String?,
      scheduledBy: json['scheduled_by'],
      scheduledAt: json['scheduled_at'] as String?,
      draftBy: json['draft_by'],
      draftAt: json['draft_at'] as String?,
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
      'is_display': isDisplay,
      'deleted_user_id': deletedUserId,
      'generated_text_timestamp': generatedTextTimestamp,
      'engagement_count': engagementCount,
      'published_by': publishedBy,
      'provider': provider,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'tweet_created_at': tweetCreatedAt,
      'localtion': location, // corrected field name
      'generated_title': generatedTitle,
      'tweet_url': tweetUrl,
      // 'uploaded_media': uploadedMedia,
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


class ReadyToPublishModel {
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
  final String? isDisplay;
  final int? deletedUserId;
  final String? generatedTextTimestamp;
  final int? engagementCount;
  final dynamic publishedBy;
  final String? provider;
  final String? updatedAt;
  final String? createdAt;
  final int? userId;
  final String? tweetCreatedAt;
  final String? location;
  final String? generatedTitle;
  final String? tweetUrl;
  final String? uploadedMedia;
  final String? pythonStatus;
  final int? titleWordCount;
  final int? titleCharacterCount;
  final int? bodyCharacterCount;
  final int? bodyWordCount;
  final int? responseTime;
  final int? teluguTextCount;
  final String? publishedAt;
  final String? gptEnglishText;
  final String? scheduledBy;
  final String? scheduledAt;
  final dynamic draftBy;
  final String? draftAt;

  ReadyToPublishModel({
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
    this.isDisplay,
    this.deletedUserId,
    this.generatedTextTimestamp,
    this.engagementCount,
    this.publishedBy,
    this.provider,
    this.updatedAt,
    this.createdAt,
    this.userId,
    this.tweetCreatedAt,
    this.location,
    this.generatedTitle,
    this.tweetUrl,
    this.uploadedMedia,
    this.pythonStatus,
    this.titleWordCount,
    this.titleCharacterCount,
    this.bodyCharacterCount,
    this.bodyWordCount,
    this.responseTime,
    this.teluguTextCount,
    this.publishedAt,
    this.gptEnglishText,
    this.scheduledBy,
    this.scheduledAt,
    this.draftBy,
    this.draftAt,
  });

  // Factory method to create an instance from JSON
  factory ReadyToPublishModel.fromJson(Map<String, dynamic> json) {
    return ReadyToPublishModel(
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
      imageUrl: json['image_url'] as String?,
      generatedData: json['generated_data'] as String?,
      teluguText: json['telugu_text'] as String?,
      profileName: json['profile_name'] as String?,
      isDisplay: json['is_display'] as String?,
      deletedUserId: json['deleted_user_id'] as int?,
      generatedTextTimestamp: json['generated_text_timestamp'] as String?,
      engagementCount: json['engagement_count'] as int?,
      publishedBy: json['published_by'] ??null,
      provider: json['provider'] as String?,
      updatedAt: json['updated_at'] as String?,
      createdAt: json['created_at'] as String?,
      userId: json['user_id'] as int?,
      tweetCreatedAt: json['tweet_created_at'] as String?,
      location: json['localtion'] as String?,
      generatedTitle: json['generated_title'] as String?,
      tweetUrl: json['tweet_url'] as String?,
      uploadedMedia: json['uploaded_media'] as String?,
      pythonStatus: json['python_status'] as String?,
      titleWordCount: json['title_word_count'] as int?,
      titleCharacterCount: json['title_character_count'] as int?,
      bodyCharacterCount: json['body_character_count'] as int?,
      bodyWordCount: json['body_word_count'] as int?,
      responseTime: json['response_time'] as int?,
      teluguTextCount: json['telugu_text_count'] as int?,
      publishedAt: json['published_at'] as String?,
      gptEnglishText: json['GPT_English_text'] as String?,
      scheduledBy: json['scheduled_by'] as String?,
      scheduledAt: json['scheduled_at'] as String?,
      draftBy: json['draft_by'],
      draftAt: json['draft_at'] as String?,
    );
  }

  // Method to convert instance to JSON
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
      'is_display': isDisplay,
      'deleted_user_id': deletedUserId,
      'generated_text_timestamp': generatedTextTimestamp,
      'engagement_count': engagementCount,
      'published_by': publishedBy,
      'provider': provider,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'user_id': userId,
      'tweet_created_at': tweetCreatedAt,
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




class UsersModel {
  final int? id;
  final String? name;
  final String? email;
  final DateTime? emailVerifiedAt;
  final String? twoFactorSecret;
  final String? twoFactorRecoveryCodes;
  final String? role;
  final String? firstName;
  final String? lastName;
  late final String? status;
  final int? isDeletedBy;
  final int? updatedBy;
  final String? phoneNumber;
  final String? profilePic;

  UsersModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.twoFactorSecret,
    this.twoFactorRecoveryCodes,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.status,
    this.isDeletedBy,
    this.updatedBy,
    required this.phoneNumber,
    this.profilePic,
  });

  factory UsersModel.fromJson(Map<String, dynamic> json) {
    return UsersModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'] ?? '')
          : null,
      twoFactorSecret: json['two_factor_secret'] ?? '',
      twoFactorRecoveryCodes: json['two_factor_recovery_codes'] ?? '',
      role: json['role'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      status: json['status'] ?? '',
      isDeletedBy: json['is_deleted_by'] ?? 0,
      updatedBy: json['updated_by'] ?? 0,
      phoneNumber: json['phonenumber'] ?? '',
      profilePic: json['profilepic'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'two_factor_secret': twoFactorSecret,
      'two_factor_recovery_codes': twoFactorRecoveryCodes,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'status': status,
      'is_deleted_by': isDeletedBy,
      'updated_by': updatedBy,
      'phonenumber': phoneNumber,
      'profilepic': profilePic,
    };
  }
}


class TimePeriodModel {
  final int id;
  final String name;
  final String value;

  TimePeriodModel({
    required this.id,
    required this.name,
    required this.value,
  });

  factory TimePeriodModel.fromJson(Map<String, dynamic> json) {
    return TimePeriodModel(
      id: json['id'],
      name: json['name'],
      value: json['value'],
    );
  }

  // Method to convert a TimePeriod to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
    };
  }
}


class ToneModel {
  final int id;
  final String toneName;
  final String tonePrompt;
  final String? toneTelugu;
  final String? toneTeluguPrompt;
  final String? icons;

  ToneModel({
    required this.id,
    required this.toneName,
    required this.tonePrompt,
    this.toneTelugu,
    this.toneTeluguPrompt,
    this.icons,
  });

  factory ToneModel.fromJson(Map<String, dynamic> json) {
    return ToneModel(
      id: json['id'],
      toneName: json['tone_name'],
      tonePrompt: json['tone_prompt'],
      toneTelugu: json['tone_telugu'],
      toneTeluguPrompt: json['tone_telugu_prompt'],
      icons: json['icons'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tone_name': toneName,
      'tone_prompt': tonePrompt,
      'tone_telugu': toneTelugu,
      'tone_telugu_prompt': toneTeluguPrompt,
      'icons': icons,
    };
  }
}

