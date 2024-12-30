class SendModel {
  final int? id;
  final String? profileName;
  final String? username;
  final DateTime? createdAt;
  final String? url;
  final DateTime? updatedAt;
  final String? profilePic;
  final String? tweetId;
  final String? text;
  final String? userName;
  final String? imageUrl;
  final String? generatedData;
  final String? teluguText;
  final DateTime? tweetCreatedAt;
  final String? generatedTitle;
  final String? tweetUrl;
  final String? draftBy;
  final String? draftAt;

  SendModel({
    this.id,
    this.profileName,
    this.username,
    this.createdAt,
    this.url,
    this.updatedAt,
    this.profilePic,
    this.tweetId,
    this.text,
    this.userName,
    this.imageUrl,
    this.generatedData,
    this.teluguText,
    this.tweetCreatedAt,
    this.generatedTitle,
    this.tweetUrl,
    this.draftBy,
    this.draftAt,
  });

  factory SendModel.fromJson(Map<String, dynamic> json) {
    return SendModel(
      id: json['id'] as int?,
      profileName: json['profile_name'] as String?,
      username: json['username'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      url: json['url'] as String?,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      profilePic: json['profile_pic'] as String?,
      tweetId: json['tweet_id'] as String?,
      text: json['text'] as String?,
      userName: json['user_name'] as String?,
      imageUrl: json['image_url'] as String?,
      generatedData: json['generated_data'] as String?,
      teluguText: json['telugu_text'] as String?,
      tweetCreatedAt: json['tweet_created_at'] != null ? DateTime.parse(json['tweet_created_at']) : null,
      generatedTitle: json['generated_title'] as String?,
      tweetUrl: json['tweet_url'] as String?,
      draftBy: json['published_by'] as String?,
      draftAt: json['published_at'] as String?,
    );
  }

  // Method to convert an instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_name': profileName,
      'username': username,
      'created_at': createdAt?.toIso8601String(),
      'url': url,
      'updated_at': updatedAt?.toIso8601String(),
      'profile_pic': profilePic,
      'tweet_id': tweetId,
      'text': text,
      'user_name': userName,
      'image_url': imageUrl,
      'generated_data': generatedData,
      'telugu_text': teluguText,
      'tweet_created_at': tweetCreatedAt?.toIso8601String(),
      'generated_title': generatedTitle,
      'tweet_url': tweetUrl,
      'draft_by': draftBy,
      'draft_at': draftAt,
    };
  }
}
