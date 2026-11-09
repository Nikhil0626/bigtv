class PlatformRating {
  final String platformName;
  final String platformRating;

  PlatformRating({
    required this.platformName,
    required this.platformRating,
  });

  factory PlatformRating.fromJson(Map<String, dynamic> json) {
    return PlatformRating(
      platformName: json['platform_name'] ?? json['platformName'] ?? json['name'] ?? '',
      platformRating:
          json['platform_rating'] ?? json['platformRating'] ?? json['rating'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'platform_name': platformName,
      'platform_rating': platformRating,
    };
  }
}

class MovieReviewDetails {
  final double overallRating;
  final double? criticRating;
  final List<PlatformRating> platformRatings;
  final int totalReviews;

  MovieReviewDetails({
    required this.overallRating,
    this.criticRating,
    required this.platformRatings,
    required this.totalReviews,
  });

  factory MovieReviewDetails.fromJson(Map<String, dynamic> json) {
    var rawRatings = (json['movie_platform_ratings'] ?? json['externalRatings']) as List? ?? [];
    return MovieReviewDetails(
      overallRating: (json['overall_rating'] as num?)?.toDouble() ??
          (json['overallRating'] as num?)?.toDouble() ??
          0.0,
      criticRating: (json['critic_rating'] as num?)?.toDouble() ??
          (json['criticRating'] as num?)?.toDouble() ??
          (json['chotaMeter'] != null
              ? double.tryParse(json['chotaMeter'].toString().split('/').first.trim())
              : null) ??
          (json['chotarating'] != null
              ? double.tryParse(json['chotarating'].toString().split('/').first.trim())
              : null),
      platformRatings: rawRatings
          .map((r) => PlatformRating.fromJson(Map<String, dynamic>.from(r as Map)))
          .toList(),
      totalReviews: (json['total_reviews'] as num?)?.toInt() ??
          (json['reviewCount'] as num?)?.toInt() ??
          0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_rating': overallRating,
      'critic_rating': criticRating,
      'movie_platform_ratings': platformRatings.map((r) => r.toJson()).toList(),
      'total_reviews': totalReviews,
    };
  }
}

