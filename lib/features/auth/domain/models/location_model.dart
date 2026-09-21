class LocationModel {
  final int stateId; // Or locationId
  final String stateName; // Or locationName
  final String? value;
  final bool? isActive;
  final bool? status;
  final bool isFollowed;
  final String? imageUrl;

  LocationModel({
    required this.stateId,
    required this.stateName,
    this.value,
    this.isActive,
    this.status,
    this.isFollowed = false,
    this.imageUrl,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      stateId: (json['locationId'] ?? json['stateId'] ?? json['id'] ?? 0) as int,
      stateName: (json['locationName'] ?? json['stateName'] ?? json['name'] ?? '').toString(),
      value: json['value']?.toString(),
      isActive: (json['isActive'] ?? json['is_active']) as bool?,
      status: (json['status'] ?? json['is_active']) as bool?,
      isFollowed: (json['isFollowed'] ?? json['is_followed'] ?? false) as bool,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? json['image'] ?? json['icon'] ?? json['logo'] ?? json['state_image'] ?? json['location_image'] ?? json['locationImage']) as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stateId': stateId,
      'stateName': stateName,
      'value': value,
      'isActive': isActive,
      'status': status,
      'isFollowed': isFollowed,
      'imageUrl': imageUrl,
    };
  }
}
