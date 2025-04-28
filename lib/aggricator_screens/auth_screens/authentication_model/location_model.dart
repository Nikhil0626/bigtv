class LocationModel {
  final int districtId;
  final String districtName;
  final int stateId;
  final String stateName;
  final String value;
  final bool isFollowed;

  LocationModel({
    required this.districtId,
    required this.districtName,
    required this.stateId,
    required this.stateName,
    required this.value,
    required this.isFollowed,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      districtId: json['districtId'] ?? 0,
      districtName: json['districtName'] ?? '',
      stateId: json['stateId'] ?? 0,
      stateName: json['stateName'] ?? '',
      value: json['value'] ?? '',
      isFollowed: json['isFollowed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'districtId': districtId,
      'districtName': districtName,
      'stateId': stateId,
      'stateName': stateName,
      'value': value,
      'isFollowed': isFollowed,
    };
  }
}
