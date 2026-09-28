class LocationModel {
  final int stateId; // Or locationId
  final String stateName; // Or locationName
  final String? englishName;
  final String? value;
  final bool? isActive;
  final bool? status;
  final bool isFollowed;
  final String? imageUrl;

  LocationModel({
    required this.stateId,
    required this.stateName,
    this.englishName,
    this.value,
    this.isActive,
    this.status,
    this.isFollowed = false,
    this.imageUrl,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    String? extractedImage;
    if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      extractedImage = json['imageUrl'].toString();
    } else if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      extractedImage = json['image_url'].toString();
    } else if (json['state_image'] != null && json['state_image'].toString().isNotEmpty) {
      extractedImage = json['state_image'].toString();
    } else if (json['location_image'] != null && json['location_image'].toString().isNotEmpty) {
      extractedImage = json['location_image'].toString();
    } else if (json['locationImage'] != null && json['locationImage'].toString().isNotEmpty) {
      extractedImage = json['locationImage'].toString();
    } else if (json['icon'] != null && json['icon'].toString().isNotEmpty) {
      extractedImage = json['icon'].toString();
    } else if (json['icon_url'] != null && json['icon_url'].toString().isNotEmpty) {
      extractedImage = json['icon_url'].toString();
    } else if (json['thumbnail'] != null && json['thumbnail'].toString().isNotEmpty) {
      extractedImage = json['thumbnail'].toString();
    } else if (json['image'] != null) {
      if (json['image'] is String && json['image'].toString().isNotEmpty) {
        extractedImage = json['image'].toString();
      } else if (json['image'] is Map) {
        extractedImage = (json['image']['url'] ?? json['image']['src'] ?? json['image']['s3_url'] ?? json['image']['path'])?.toString();
      }
    } else if (json['logo'] != null && json['logo'].toString().isNotEmpty) {
      extractedImage = json['logo'].toString();
    }

    String? engName = json['englishName'] ??
        json['english_name'] ??
        json['name_en'] ??
        json['state_name_en'] ??
        (json['locationNameTranslations'] is Map ? json['locationNameTranslations']['en'] : null) ??
        (json['stateNameTranslations'] is Map ? json['stateNameTranslations']['en'] : null);

    return LocationModel(
      stateId: (json['locationId'] ?? json['stateId'] ?? json['id'] ?? 0) as int,
      stateName: (json['locationName'] ?? json['stateName'] ?? json['name'] ?? '').toString(),
      englishName: engName?.toString(),
      value: json['value']?.toString(),
      isActive: (json['isActive'] ?? json['is_active']) as bool?,
      status: (json['status'] ?? json['is_active']) as bool?,
      isFollowed: (json['isFollowed'] ?? json['is_followed'] ?? false) as bool,
      imageUrl: extractedImage,
    );
  }

  String getNativeName() {
    final lower = stateName.toLowerCase();
    if (lower.contains('telangana') || lower.contains('తెలంగాణ')) return 'తెలంగాణ';
    if (lower.contains('andhra') || lower.contains('ఆంధ్రప్రదేశ్')) return 'ఆంధ్రప్రదేశ్';
    if (lower.contains('kerala') || lower.contains('కేరళ')) return 'కేరళ';
    if (lower.contains('tamil') || lower.contains('తమిళనాడు')) return 'తమిళనాడు';
    if (lower.contains('karnataka') || lower.contains('కర్ణాటక')) return 'కర్ణాటక';
    return stateName;
  }

  String getEnglishName() {
    if (englishName != null && englishName!.trim().isNotEmpty) {
      return englishName!.trim();
    }
    final lower = stateName.toLowerCase();
    if (lower.contains('తెలంగాణ') || lower.contains('telangana')) return 'Telangana';
    if (lower.contains('ఆంధ్రప్రదేశ్') || lower.contains('andhra')) return 'Andhra Pradesh';
    if (lower.contains('కేరళ') || lower.contains('kerala')) return 'Kerala';
    if (lower.contains('తమిళనాడు') || lower.contains('tamil')) return 'Tamil Nadu';
    if (lower.contains('కర్ణాటక') || lower.contains('karnataka')) return 'Karnataka';
    return stateName;
  }

  Map<String, dynamic> toJson() {
    return {
      'stateId': stateId,
      'stateName': stateName,
      'englishName': englishName,
      'value': value,
      'isActive': isActive,
      'status': status,
      'isFollowed': isFollowed,
      'imageUrl': imageUrl,
    };
  }
}
