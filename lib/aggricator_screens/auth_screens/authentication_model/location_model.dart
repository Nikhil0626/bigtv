class  LocationModel{
  final int id;
  final String name;
  final String value;
  final int stateId;
  final bool isFollowed;

  const LocationModel({
    required this.id,
    required this.name,
    required this.value,
    required this.stateId,
    required this.isFollowed,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as int,
      name: json['name'] as String,
      value: json['value'] as String,
      stateId: json['stateid'] as int,
      isFollowed: json['isFollowed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'stateid': stateId,
      'isFollowed': isFollowed,
    };
  }

  LocationModel copyWith({
    int? id,
    String? name,
    String? value,
    int? stateId,
    bool? isFollowed,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      value: value ?? this.value,
      stateId: stateId ?? this.stateId,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }
}
