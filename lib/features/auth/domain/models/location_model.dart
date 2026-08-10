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
      stateId: json['locationId'] ?? json['stateId'] ?? 0,
      stateName: json['locationName'] ?? json['stateName'] ?? '',
      value: json['value'],
      isActive: json['isActive'],
      status: json['status'],
      isFollowed: json['isFollowed'] ?? false,
      imageUrl: json['imageUrl'],
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
