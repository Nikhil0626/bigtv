import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import '../../../../services/base_service.dart';
import '../../../../services/base_urls.dart';
import '../../../../utils/app_enums.dart';
import '../models/app_notification_model.dart';

class NotificationsRepository {
  final BaseService _service = BaseService();

  Future<NotificationListResponse> getNotifications({
    int skip = 0,
    int take = 20,
  }) async {
    try {
      final Response response = await _service.makeRequest(
        baseUrl: BaseUrls.newServerBaseUrl,
        url: BaseUrls.sendNotificationApi,
        method: RequestType.get,
        queryParameters: {
          "skip": skip.toString(),
          "take": take.toString(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic dataMap = response.data;
        if (dataMap is String) {
          dataMap = jsonDecode(dataMap);
        }
        if (dataMap is Map) {
          final data = dataMap['data'];
          if (data != null && data['items'] is List) {
            final items = (data['items'] as List)
                .map((e) => AppNotificationModel.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList();
            final total =
                int.tryParse(data['total']?.toString() ?? '') ?? items.length;
            final retSkip =
                int.tryParse(data['skip']?.toString() ?? '') ?? skip;
            final retTake =
                int.tryParse(data['take']?.toString() ?? '') ?? take;

            return NotificationListResponse(
              items: items,
              total: total,
              skip: retSkip,
              take: retTake,
            );
          }
        }
      }
      return NotificationListResponse(
        items: [],
        total: 0,
        skip: skip,
        take: take,
      );
    } catch (e, st) {
      log("NotificationsRepository.getNotifications error: $e",
          stackTrace: st);
      rethrow;
    }
  }
}
