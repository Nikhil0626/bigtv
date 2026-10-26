class ZipLevelApiModel {
  final String gameId;
  final String gameType;
  final String levelId;
  final int levelNumber;
  final String title;
  final int schemaVersion;
  final String difficulty;
  final Map<String, dynamic>? content;
  final String? logoUrl;

  const ZipLevelApiModel({
    required this.gameId,
    required this.gameType,
    required this.levelId,
    required this.levelNumber,
    required this.title,
    required this.schemaVersion,
    required this.difficulty,
    this.content,
    this.logoUrl,
  });

  factory ZipLevelApiModel.fromJson(Map<String, dynamic> json) {
    String readString(String key, {String fallback = ''}) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      if (value != null) {
        return value.toString().trim();
      }
      if (fallback.isNotEmpty) return fallback;
      throw FormatException('Missing or invalid "$key" on level.');
    }

    int readInt(String key) {
      final value = json[key];
      if (value is int) {
        return value;
      }
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
      throw FormatException('Missing or invalid "$key" on level.');
    }

    final rawContent = json['content'];
    Map<String, dynamic>? parsedContent;
    if (rawContent is Map) {
      parsedContent = Map<String, dynamic>.from(rawContent);
    }

    final lvlNum = readInt('levelNumber');

    final rawLogo = json['logoUrl'] ??
        json['completionImageUrl'] ??
        json['backgroundImageUrl'] ??
        (parsedContent != null ? parsedContent['backgroundImage'] : null);

    return ZipLevelApiModel(
      gameId: readString('gameId', fallback: 'zip_puzzle'),
      gameType: readString('gameType', fallback: 'zip'),
      levelId: readString('levelId',
          fallback: 'zip_${lvlNum.toString().padLeft(3, '0')}'),
      levelNumber: lvlNum,
      title: readString('title', fallback: 'Level $lvlNum'),
      schemaVersion:
          json['schemaVersion'] is int ? json['schemaVersion'] as int : 1,
      difficulty: readString('difficulty', fallback: 'easy'),
      content: parsedContent,
      logoUrl: rawLogo?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'gameId': gameId,
        'gameType': gameType,
        'levelId': levelId,
        'levelNumber': levelNumber,
        'title': title,
        'schemaVersion': schemaVersion,
        'difficulty': difficulty,
        if (content != null) 'content': content,
        if (logoUrl != null) 'logoUrl': logoUrl,
      };
}

class ZipLevelCatalogueResponse {
  final int schemaVersion;
  final List<ZipLevelApiModel> items;
  final int? total;
  final int? page;
  final int? pageSize;

  const ZipLevelCatalogueResponse({
    required this.schemaVersion,
    required this.items,
    this.total,
    this.page,
    this.pageSize,
  });

  factory ZipLevelCatalogueResponse.fromJson(Map<String, dynamic> json) {
    final schemaVersion = json['schemaVersion'];
    if (schemaVersion != null && (schemaVersion is! int || schemaVersion < 1)) {
      throw const FormatException('Invalid catalogue schemaVersion.');
    }

    // Support items, data, or levels keys in envelope
    final rawItems = json['items'] ?? json['data'] ?? json['levels'];
    if (rawItems is! List) {
      throw const FormatException(
          'Catalogue response must contain a list of items.');
    }

    final items = rawItems.map((item) {
      if (item is! Map) {
        throw const FormatException('Catalogue item must be an object.');
      }
      return ZipLevelApiModel.fromJson(Map<String, dynamic>.from(item));
    }).toList(growable: false);

    final rawTotal = json['total'] ?? json['totalCount'];
    final rawPage = json['page'];
    final rawPageSize = json['pageSize'];

    return ZipLevelCatalogueResponse(
      schemaVersion: schemaVersion is int ? schemaVersion : 1,
      items: items,
      total: rawTotal is int
          ? rawTotal
          : (rawTotal is String ? int.tryParse(rawTotal) : null),
      page: rawPage is int
          ? rawPage
          : (rawPage is String ? int.tryParse(rawPage) : null),
      pageSize: rawPageSize is int
          ? rawPageSize
          : (rawPageSize is String ? int.tryParse(rawPageSize) : null),
    );
  }
}
