class DistrictModel {
  final int id;
  final String name;
  final String value;
  bool isFollowed;

  DistrictModel({
    required this.id,
    required this.name,
    required this.value,
    this.isFollowed = false,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'],
      name: json['name'],
      value: json['value'],
      isFollowed: json['isFollowed'] ?? false,
    );
  }

  // Method to convert District object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'isFollowed': isFollowed,
    };
  }
}
