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

  CategoryModel({
    this.categoryId,
    this.categoryName,
    this.isFollowed,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['categoryid'] as int?,
      categoryName: json['categoryname'] as String?,
      isFollowed: json['isFollowed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
    'categoryid': categoryId,
    'categoryname': categoryName,
    'isFollowed': isFollowed,
  };
}
