class GetMenuItemModel {
  final int id;
  final String name;
  final String value;
  final String imageUrl;

  GetMenuItemModel({
    required this.id,
    required this.name,
    required this.value,
    required this.imageUrl,
  });


  factory GetMenuItemModel.fromJson(Map<String, dynamic> json) {
    return GetMenuItemModel(
      id: json['id'],
      name: json['name'],
      value: json['value'],
      imageUrl: json['imageUrl'],
    );
  }

  // Method to convert an object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'imageUrl': imageUrl,
    };
  }
}
