class EPaperMainModel {
  final String id;
  final String source;
  final String sourceUrl;
  final String logo;
  final String editionName;
  final String imageUrl;
  final int pageNumber;
  final String publishedDate;
  final int isBookmarked;
  final bool isTodays;

  EPaperMainModel({
    required this.id,
    required this.source,
    required this.sourceUrl,
    required this.logo,
    required this.editionName,
    required this.imageUrl,
    required this.pageNumber,
    required this.publishedDate,
    required this.isBookmarked,
    required this.isTodays,
  });

  factory EPaperMainModel.fromJson(Map<String, dynamic> json) {
    return EPaperMainModel(
      id: json['id'] as String,
      source: json['source'] as String,
      sourceUrl: json['source_url'] as String,
      logo: json['logo'] as String,
      editionName: json['edition_name'] as String,
      imageUrl: json['image_url'] as String,
      pageNumber: json['page_number'] as int,
      publishedDate: json['published_date'] as String,
      isBookmarked: json['isBookmarked'] as int,
      isTodays: json['is_todays'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'source_url': sourceUrl,
      'logo': logo,
      'edition_name': editionName,
      'image_url': imageUrl,
      'page_number': pageNumber,
      'published_date': publishedDate,
      'isBookmarked': isBookmarked,
      'is_todays': isTodays,
    };
  }
}