class SeriesModel {
  final String id;
  final String title;
  final String description;
  final String poster;
  final String banner;
  final List<String> genres;
  final List<String> languages;
  final String releaseDate;
  final double rating;
  final String ageRestriction;
  final bool featured;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<EpisodeModel> episodes;
  final List<dynamic> trailers;

  SeriesModel({
    required this.id,
    required this.title,
    required this.description,
    required this.poster,
    required this.banner,
    required this.genres,
    required this.languages,
    required this.releaseDate,
    required this.rating,
    required this.ageRestriction,
    required this.featured,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.episodes,
    required this.trailers,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      poster: json['poster'] ?? '',
      banner: json['banner'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      languages: List<String>.from(json['languages'] ?? []),
      releaseDate: json['releaseDate'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      ageRestriction: json['ageRestriction'] ?? '',
      featured: json['featured'] ?? false,
      status: json['status'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => EpisodeModel.fromJson(e))
              .toList() ??
          [],
      trailers: json['trailers'] ?? [],
    );
  }
}

class EpisodeModel {
  final String id;
  final String seriesId;
  final int episodeNumber;
  final String title;
  final String description;
  final String thumbnail;
  final String videoUrl;
  final int duration;
  final String createdAt;

  EpisodeModel({
    required this.id,
    required this.seriesId,
    required this.episodeNumber,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.videoUrl,
    required this.duration,
    required this.createdAt,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    return EpisodeModel(
      id: json['id']?.toString() ?? '',
      seriesId: json['seriesId']?.toString() ?? '',
      episodeNumber: json['episodeNumber'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      duration: json['duration'] ?? 0,
      createdAt: json['createdAt'] ?? '',
    );
  }
}
