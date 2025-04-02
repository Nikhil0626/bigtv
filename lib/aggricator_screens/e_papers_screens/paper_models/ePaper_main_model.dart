import 'dart:convert';

class EPaperMainModel {
  final int id;
  final String source;
  final String sourceUrl;
  final String editionName;
  final String imageUrl;
  final int pageNumber;
  final String publishedDate;

  EPaperMainModel({
    required this.id,
    required this.source,
    required this.sourceUrl,
    required this.editionName,
    required this.imageUrl,
    required this.pageNumber,
    required this.publishedDate,
  });

  // Factory constructor for creating an instance from JSON
  factory EPaperMainModel.fromJson(Map<String, dynamic> json) {
    return EPaperMainModel(
      id: json['id'] ?? 0,
      source: json['source'] ?? '',
      sourceUrl: json['source_url'] ?? '',
      editionName: json['edition_name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      pageNumber: json['page_number'] ?? 0,
      publishedDate: json['published_date'] ?? '',
    );
  }

  // Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'source_url': sourceUrl,
      'edition_name': editionName,
      'image_url': imageUrl,
      'page_number': pageNumber,
      'published_date': publishedDate,
    };
  }

  // Convert JSON string to HomeEPapersModel
  static EPaperMainModel fromJsonString(String jsonString) {
    return EPaperMainModel.fromJson(json.decode(jsonString));
  }

  // Convert HomeEPapersModel to JSON string
  String toJsonString() {
    return json.encode(toJson());
  }
}
