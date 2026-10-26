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
    String language = 'te',
  }) async {
    final targetLang = (language.toLowerCase() == 'ml') ? 'ml' : 'te';
    try {
      final Response response = await _service.makeRequest(
        baseUrl: BaseUrls.newServerBaseUrl,
        url: BaseUrls.sendNotificationApi,
        method: RequestType.get,
        headers: {
          'accept': '*/*',
        },
        queryParameters: {
          "skip": skip.toString(),
          "take": take.toString(),
          "language": targetLang,
          "lan": targetLang,
          "lang": targetLang,
          "segregated": "false",
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic dataMap = response.data;
        if (dataMap is String) {
          dataMap = jsonDecode(dataMap);
        }
        if (dataMap is Map) {
          dynamic rawData = dataMap['data'];

          // If segregated map (te, ml, en) is returned, select target language data map
          dynamic langData;
          if (rawData is Map) {
            if (rawData[targetLang] is Map) {
              langData = rawData[targetLang];
            } else if (rawData['items'] != null) {
              langData = rawData;
            } else if (rawData['te'] is Map && targetLang == 'te') {
              langData = rawData['te'];
            } else if (rawData['ml'] is Map && targetLang == 'ml') {
              langData = rawData['ml'];
            }
          }

          if (langData != null && langData is Map && langData['items'] is List) {
            final rawItems = langData['items'] as List;
            final items = rawItems
                .map((e) => AppNotificationModel.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .where((item) {
                  // If language is ml, only show ml notifications
                  if (targetLang == 'ml') {
                    final itemLan = (item.lan ?? '').toLowerCase();
                    return itemLan.isEmpty || itemLan == 'ml';
                  } else {
                    final itemLan = (item.lan ?? '').toLowerCase();
                    return itemLan != 'ml';
                  }
                })
                .toList();

            final total =
                int.tryParse(langData['total']?.toString() ?? '') ?? items.length;
            final retSkip =
                int.tryParse(langData['skip']?.toString() ?? '') ?? skip;
            final retTake =
                int.tryParse(langData['take']?.toString() ?? '') ?? take;

            return NotificationListResponse(
              items: items,
              total: (total > 0 && items.isEmpty && targetLang == 'ml') ? 0 : total,
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
