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
    return CategoryModel(
      categoryId: (json['categoryId'] ?? json['categoryid'] ?? json['id'] ?? json['category_id']) as int?,
      categoryName: (json['categoryName'] ?? json['categoryname'] ?? json['category_name'] ?? json['name']) as String?,
      isFollowed: (json['isFollowed'] ?? json['isfollowed'] ?? json['is_followed']) as bool?,
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? json['cat_image'] ?? json['category_image'] ?? json['icon'] ?? json['image']) as String?,
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
