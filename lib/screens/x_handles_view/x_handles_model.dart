class XHandlesTweetsModel {
  final int id;
  final String? profileName;
  final String? username;
  final String? status;
  final String? createdAt;
  final String? url;
  final String? updatedAt;
  final String? profilePic;
  final int? userId;
  final int? deletedBy;
  final bool? isVerified;
  final String? backgroundProfilePic;

  XHandlesTweetsModel({
    required this.id,
    this.profileName,
    this.username,
    required this.status,
    required this.createdAt,
    required this.url,
    required this.updatedAt,
    required this.profilePic,
    this.userId,
    required this.deletedBy,
    required this.isVerified,
    required this.backgroundProfilePic,
  });

  factory XHandlesTweetsModel.fromJson(Map<String, dynamic> json) {
    return XHandlesTweetsModel(
      id: json['id'],
      profileName: json['profile_name'],
      username: json['username'],
      status: json['status'],
      createdAt: json['created_at'],
      url: json['url'],
      updatedAt: json['updated_at'],
      profilePic: json['profile_pic'],
      userId: json['user_id'],
      deletedBy: json['deleted_by'],
      isVerified: json['is_verified'] == "1", // Convert "1"/"0" to boolean
      backgroundProfilePic: json['background_profile_pic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_name': profileName,
      'username': username,
      'status': status,
      'created_at': createdAt,
      'url': url,
      'updated_at': updatedAt,
      'profile_pic': profilePic,
      'user_id': userId,
      'deleted_by': deletedBy,
      'is_verified': isVerified! ? "1" : "0", // Convert boolean to "1"/"0"
      'background_profile_pic': backgroundProfilePic,
    };
  }
}
