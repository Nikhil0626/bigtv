class SinglePaperModel {
  final int? id;
  final String? source;
  final String? sourceUrl;
  final String? logo;
  final String? editionName;
  final String? imageUrl;
  final int? pageNumber;
  final String? publishedDate;
  final String? isBookmarked;
  final List<PageData>? data;
  final bool? isTodays;

  SinglePaperModel({
    this.id,
    this.source,
    this.sourceUrl,
    this.logo,
    this.editionName,
    this.imageUrl,
    this.pageNumber,
    this.publishedDate,
    this.isBookmarked,
    this.data,
    this.isTodays,
  });

  factory SinglePaperModel.fromJson(Map<String, dynamic> json) {
    return SinglePaperModel(
      id: json['_id'] as int?,
      source: json['source'] as String?,
      sourceUrl: json['source_url'] as String?,
      logo: json['logo'] as String?,
      editionName: json['edition_name'] as String?,
      imageUrl: json['image_url'] as String?,
      pageNumber: json['page_number'] as int?,
      publishedDate: json['published_date'] as String?,
      isBookmarked: json['isBookmarked'] as String?,
      isTodays: json['is_todays'] as bool?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => PageData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'source': source,
      'sourceUrl': sourceUrl,
      'logo': logo,
      'edition_name': editionName,
      'image_url': imageUrl,
      'page_number': pageNumber,
      'published_date': publishedDate,
      'isBookmarked': isBookmarked,
      'is_todays': isTodays,
      'data': data?.map((e) => e.toJson()).toList(),
    };
  }
}

class PageData {
  final String? imageUrl;
  final int? pageNumber;
  final String? id;

  PageData({
    this.imageUrl,
    this.pageNumber,
    this.id,
  });

  factory PageData.fromJson(Map<String, dynamic> json) {
    return PageData(
      imageUrl: json['image_url'] as String?,
      pageNumber: json['page_number'] as int?,
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'page_number': pageNumber,
      'id': id,
    };
  }
}
