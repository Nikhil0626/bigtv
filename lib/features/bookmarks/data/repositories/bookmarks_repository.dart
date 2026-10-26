import 'dart:developer';
import 'package:dio/dio.dart';
import '../../../../services/base_service.dart';
import '../../../../services/base_urls.dart';
import '../../../../utils/app_enums.dart';
import '../models/bookmark_post_model.dart';

class BookmarksRepository {
  final BaseService _service = BaseService();

  /// POST /bookmark
  /// Input:
  /// {
  ///   "postId": 12,
  ///   "userId": 12,
  ///   "deviceId": "string",
  ///   "isBookmarked": true
  /// }
  Future<Map<String, dynamic>> toggleBookmark({
    required int postId,
    required int userId,
    required String deviceId,
    required bool isBookmarked,
  }) async {
    final Map<String, dynamic> body = {
      "postId": postId,
      "userId": userId,
      "deviceId": deviceId,
      "isBookmarked": isBookmarked,
    };

    try {
      log("BookmarksRepository.toggleBookmark payload: $body");
      final Response response = await _service.makeRequest(
        baseUrl: BaseUrls.devBaseUrl,
        url: BaseUrls.bookmarkApi,
        method: RequestType.post,
        body: body,
      );

      if (response.data is Map<String, dynamic>) {
        return Map<String, dynamic>.from(response.data);
      }
      return {"status": "success", "isBookmarked": isBookmarked};
    } catch (e, st) {
      log("BookmarksRepository.toggleBookmark error: $e", stackTrace: st);
      rethrow;
    }
  }

  /// GET /bookmarks?userId=12&page=1&limit=20&isBigTv=false
  Future<Map<String, dynamic>> getBookmarks({
    required int userId,
    int page = 1,
    int limit = 20,
    bool isBigTv = false,
  }) async {
    final Map<String, dynamic> query = {
      "userId": userId,
      "page": page,
      "limit": limit,
      "isBigTv": isBigTv,
    };

    try {
      log("BookmarksRepository.getBookmarks query: $query");
      final Response response = await _service.makeRequest(
        baseUrl: BaseUrls.devBaseUrl,
        url: BaseUrls.bookmarksListApi,
        method: RequestType.get,
        queryParameters: query,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final List postsRaw = (data['posts'] as List?) ?? [];
        final posts = postsRaw
            .whereType<Map<String, dynamic>>()
            .map((e) => BookmarkPostModel.fromJson(e))
            .toList();

        return {
          "status": data['status']?.toString() ?? "success",
          "total": int.tryParse(data['total']?.toString() ?? '0') ?? posts.length,
          "page": int.tryParse(data['page']?.toString() ?? '$page') ?? page,
          "limit": int.tryParse(data['limit']?.toString() ?? '$limit') ?? limit,
          "posts": posts,
        };
      }
      return {"status": "error", "posts": <BookmarkPostModel>[]};
    } catch (e, st) {
      log("BookmarksRepository.getBookmarks error: $e", stackTrace: st);
      rethrow;
    }
  }
}
