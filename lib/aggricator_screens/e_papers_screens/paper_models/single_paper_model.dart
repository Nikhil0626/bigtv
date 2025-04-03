class SinglePaperModel {
  final int id;
  final String source;
  final String editionName;
  final String imageUrl;
  final int pageNumber;
  final String publishedDate;
  final List<PageData> data;

  SinglePaperModel({
    required this.id,
    required this.source,
    required this.editionName,
    required this.imageUrl,
    required this.pageNumber,
    required this.publishedDate,
    required this.data,
  });

  factory SinglePaperModel.fromJson(Map<String, dynamic> json) {
    return SinglePaperModel(
      id: json['id'] as int,
      source: json['source'] as String,
      editionName: json['edition_name'] as String,
      imageUrl: json['image_url'] as String,
      pageNumber: json['page_number'] as int,
      publishedDate: json['published_date'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => PageData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source,
      'edition_name': editionName,
      'image_url': imageUrl,
      'page_number': pageNumber,
      'published_date': publishedDate,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class PageData {
  final String imageUrl;
  final int pageNumber;

  PageData({
    required this.imageUrl,
    required this.pageNumber,
  });

  factory PageData.fromJson(Map<String, dynamic> json) {
    return PageData(
      imageUrl: json['image_url'] as String,
      pageNumber: json['page_number'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'page_number': pageNumber,
    };
  }
}
