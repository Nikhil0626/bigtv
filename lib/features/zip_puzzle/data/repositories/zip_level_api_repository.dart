import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/zip_level_api_model.dart';
import '../sources/zip_dummy_levels_json.dart';

class ZipLevelApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? code;

  const ZipLevelApiException(
    this.message, {
    this.statusCode,
    this.code,
  });

  @override
  String toString() => message;
}

class ZipLevelApiRepository {
  ZipLevelApiRepository({
    String? baseUrl,
    String gameId = 'zip_puzzle',
    http.Client? client,
    Map<String, String> Function()? headersProvider,
    this.useDummyData =
        const bool.fromEnvironment('USE_DUMMY_ZIP_LEVELS', defaultValue: false),
  })  : _baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'GAMES_API_BASE_URL',
                  defaultValue: 'https://api.pravasamedia.com',
                ))
            .replaceFirst(RegExp(r'/+$'), '')
            .replaceFirst(RegExp(r'/api/v1$'), ''),
        _gameId = gameId,
        _client = client ?? http.Client(),
        _isInternalClient = client == null,
        _headersProvider = headersProvider ?? _defaultHeaders;

  final String _baseUrl;
  final String _gameId;
  final http.Client _client;
  final bool _isInternalClient;
  final Map<String, String> Function() _headersProvider;
  final bool useDummyData;

  static Map<String, String> _defaultHeaders() => const {
        'Accept': 'application/json',
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    if (_baseUrl.isEmpty) {
      throw const ZipLevelApiException(
        'The puzzle API URL is not configured.',
      );
    }
    return Uri.parse('$_baseUrl$path').replace(queryParameters: query);
  }

  Future<ZipLevelCatalogueResponse> getCatalogue({
    int page = 1,
    int pageSize = 100,
  }) async {
    if (useDummyData) {
      await Future.delayed(const Duration(milliseconds: 50));
      return ZipLevelCatalogueResponse.fromJson(zipDummyCatalogueJson);
    }

    final uri = _uri(
      '/api/v1/games/$_gameId/levels',
      {
        'page': '$page',
        'pageSize': '$pageSize',
      },
    );

    final response = await _get(uri);
    final json = _decodeObject(response.body);
    return ZipLevelCatalogueResponse.fromJson(json);
  }

  Future<ZipLevelApiModel> getLevelById(String levelId) async {
    if (levelId.trim().isEmpty) {
      throw const ZipLevelApiException('A level ID is required.');
    }

    if (useDummyData) {
      await Future.delayed(const Duration(milliseconds: 50));
      final rawItems = zipDummyCatalogueJson['items'] as List;
      final cleanId = levelId.trim();
      Map<String, dynamic>? match;
      for (final it in rawItems) {
        if (it is Map) {
          final itId = it['levelId']?.toString();
          final itNum = it['levelNumber']?.toString();
          if (itId == cleanId ||
              itNum == cleanId ||
              'zip_$itNum' == cleanId ||
              'zip_${itNum?.padLeft(3, '0')}' == cleanId) {
            match = Map<String, dynamic>.from(it);
            break;
          }
        }
      }
      if (match == null) {
        throw const ZipLevelApiException(
          'The requested puzzle level was not found.',
          statusCode: 404,
          code: 'LEVEL_NOT_FOUND',
        );
      }
      return ZipLevelApiModel.fromJson(match);
    }

    final encodedId = Uri.encodeComponent(levelId.trim());
    final uri = _uri('/api/v1/games/zip_puzzle/levels/$encodedId');
    final response = await _get(uri);
    final json = _decodeObject(response.body);

    // Accept either a direct level object or { "item": { ... } } or { "data": { ... } }.
    final rawLevel = json['item'] ?? json['data'] ?? json;
    if (rawLevel is! Map) {
      throw const ZipLevelApiException(
        'The API returned an invalid level object.',
      );
    }
    return ZipLevelApiModel.fromJson(
      Map<String, dynamic>.from(rawLevel),
    );
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      final headers = <String, String>{
        ..._headersProvider(),
      };
      final response = await _client
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      }

      String message = 'Could not load puzzle levels.';
      String? code;
      try {
        final body = _decodeObject(response.body);
        final error = body['error'];
        if (error is Map) {
          if (error['message'] is String) message = error['message'] as String;
          if (error['code'] is String) code = error['code'] as String;
        } else if (body['message'] is String) {
          message = body['message'] as String;
        }
      } catch (_) {
        // Do not expose raw HTML or server traces to player
      }

      if (response.statusCode == 404) {
        message = 'The requested puzzle level was not found.';
        code ??= 'LEVEL_NOT_FOUND';
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        message = 'Authentication required to access puzzle levels.';
        code ??= 'UNAUTHORIZED';
      } else if (response.statusCode == 429) {
        message = 'Too many requests. Please wait a moment and try again.';
        code ??= 'RATE_LIMITED';
      } else if (response.statusCode >= 500) {
        message = 'Puzzle server is temporarily unavailable. Please retry.';
        code ??= 'SERVER_ERROR';
      }

      throw ZipLevelApiException(
        message,
        statusCode: response.statusCode,
        code: code,
      );
    } on TimeoutException {
      throw const ZipLevelApiException(
        'The puzzle server took too long to respond. Please retry.',
      );
    } on http.ClientException {
      throw const ZipLevelApiException(
        'Could not connect to the puzzle server. Check your connection and retry.',
      );
    }
  }

  Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map) {
      throw const ZipLevelApiException(
        'The puzzle server returned an invalid response.',
      );
    }
    return Map<String, dynamic>.from(decoded);
  }

  void close() {
    if (_isInternalClient) {
      _client.close();
    }
  }
}
