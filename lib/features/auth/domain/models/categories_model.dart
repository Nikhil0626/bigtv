class CategoriesModel {
  final double? responseTimeSec;
  final CategoriesListModel? categories;

  CategoriesModel({
    this.responseTimeSec,
    this.categories,
  });

  factory CategoriesModel.fromJson(Map<String, dynamic> json) {
    return CategoriesModel(
      responseTimeSec: (json['response_time_sec'] as num?)?.toDouble(),
      categories: json['categories'] != null
          ? CategoriesListModel.fromJson(json['categories'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'response_time_sec': responseTimeSec,
    'categories': categories?.toJson(),
  };
}

class CategoriesListModel {
  final List<CategoryModel>? categories;

  CategoriesListModel({this.categories});

  factory CategoriesListModel.fromJson(Map<String, dynamic> json) {
    return CategoriesListModel(
      categories: (json['categories'] as List<dynamic>?)
          ?.map((item) => CategoryModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'categories': categories?.map((e) => e.toJson()).toList(),
  };
}

class CategoryModel {
  final int? categoryId;
  final String? categoryName;
  final bool? isFollowed;
  final String? imageUrl;
  final bool? isActive;

  CategoryModel({
    this.categoryId,
    this.categoryName,
    this.isFollowed,
    this.imageUrl,
    this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    String? extractedImage;
    if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      extractedImage = json['imageUrl'].toString();
    } else if (json['image_url'] != null && json['image_url'].toString().isNotEmpty) {
      extractedImage = json['image_url'].toString();
    } else if (json['category_image'] != null && json['category_image'].toString().isNotEmpty) {
      extractedImage = json['category_image'].toString();
    } else if (json['categoryImage'] != null && json['categoryImage'].toString().isNotEmpty) {
      extractedImage = json['categoryImage'].toString();
    } else if (json['cat_image'] != null && json['cat_image'].toString().isNotEmpty) {
      extractedImage = json['cat_image'].toString();
    } else if (json['catImage'] != null && json['catImage'].toString().isNotEmpty) {
      extractedImage = json['catImage'].toString();
    } else if (json['icon'] != null && json['icon'].toString().isNotEmpty) {
      extractedImage = json['icon'].toString();
    } else if (json['icon_url'] != null && json['icon_url'].toString().isNotEmpty) {
      extractedImage = json['icon_url'].toString();
    } else if (json['iconUrl'] != null && json['iconUrl'].toString().isNotEmpty) {
      extractedImage = json['iconUrl'].toString();
    } else if (json['category_icon'] != null && json['category_icon'].toString().isNotEmpty) {
      extractedImage = json['category_icon'].toString();
    } else if (json['categoryIcon'] != null && json['categoryIcon'].toString().isNotEmpty) {
      extractedImage = json['categoryIcon'].toString();
    } else if (json['category_icon_url'] != null && json['category_icon_url'].toString().isNotEmpty) {
      extractedImage = json['category_icon_url'].toString();
    } else if (json['categoryIconUrl'] != null && json['categoryIconUrl'].toString().isNotEmpty) {
      extractedImage = json['categoryIconUrl'].toString();
    } else if (json['thumbnail'] != null && json['thumbnail'].toString().isNotEmpty) {
      extractedImage = json['thumbnail'].toString();
    } else if (json['thumbnail_url'] != null && json['thumbnail_url'].toString().isNotEmpty) {
      extractedImage = json['thumbnail_url'].toString();
    } else if (json['thumbnailUrl'] != null && json['thumbnailUrl'].toString().isNotEmpty) {
      extractedImage = json['thumbnailUrl'].toString();
    } else if (json['image'] != null) {
      if (json['image'] is String && json['image'].toString().isNotEmpty) {
        extractedImage = json['image'].toString();
      } else if (json['image'] is Map) {
        extractedImage = (json['image']['url'] ?? json['image']['src'] ?? json['image']['s3_url'] ?? json['image']['path'] ?? json['image']['original'] ?? json['image']['file'])?.toString();
      }
    } else if (json['icon_path'] != null && json['icon_path'].toString().isNotEmpty) {
      extractedImage = json['icon_path'].toString();
    } else if (json['image_path'] != null && json['image_path'].toString().isNotEmpty) {
      extractedImage = json['image_path'].toString();
    } else if (json['logo'] != null && json['logo'].toString().isNotEmpty) {
      extractedImage = json['logo'].toString();
    }

    return CategoryModel(
      categoryId: (json['categoryId'] ?? json['categoryid'] ?? json['id'] ?? json['category_id']) as int?,
      categoryName: (json['categoryName'] ?? json['categoryname'] ?? json['category_name'] ?? json['name']) as String?,
      isFollowed: (json['isFollowed'] ?? json['isfollowed'] ?? json['is_followed']) as bool?,
      imageUrl: extractedImage,
      isActive: (json['isActive'] ?? json['isactive'] ?? json['is_active']) as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'categoryName': categoryName,
    'isFollowed': isFollowed,
    'imageUrl': imageUrl,
    'isActive': isActive,
  };
}
