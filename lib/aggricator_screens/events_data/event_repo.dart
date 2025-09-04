import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../services/base_service.dart';
import '../../../../services/base_urls.dart';
import '../../../../utils/app_enums.dart';

class EventRepo extends BaseService {


  Future sendEvent(body) async {
    log("event body --- ${body}");
    Response response = await makeRequest(url: BaseUrls.eventUrl, baseUrl: BaseUrls.baseUrlAwsDev, method: RequestType.post, body: body);
    log(response.data.toString());
    return response;
  }

  Future<void> addEvent(Map<String, dynamic> eventData, String eventName) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final String userId = sharedPreferences.getString("userId") ?? "guest";
    final String deviceId = sharedPreferences.getString("deviceId") ?? "12345";

    final Map<String, dynamic> newEvent = {
      'key': eventName,
      'eventData': eventData,
      'userId': userId,
      'deviceId': deviceId,
      'platform': Platform.isIOS ? "iOS" : "Android",
      'timestamp': DateTime.now().toIso8601String(),
    };

    log("Event Body: $newEvent");

    final box = Hive.box('events');
    await box.add(newEvent);

    // ✅ Fix: No null values in Firebase params
    final firebaseParams = <String, Object>{
      'userId': userId,
      'deviceId': deviceId,
      'platform': Platform.isIOS ? "iOS" : "Android",
      ...eventData.map((k, v) => MapEntry(k, (v ?? '').toString())),
    };

    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: firebaseParams,
    );
  }


  // Future<void> addEvent(Map<String, dynamic> eventData, eventName) async {
  //
  //   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  //
  //   String? userId = sharedPreferences.getString("userId");
  //   String? deviceId = sharedPreferences.getString("deviceId");
  //
  //   Map<String, dynamic> newEvent = {
  //     'key': eventName,
  //     'eventData': eventData,
  //     'userId': userId ?? "guest",
  //     'deviceId': deviceId ?? "12345",
  //     "platform": Platform.isIOS?"iOS":"Android"
  //   };
  //   log("event body --- $newEvent");
  //
  //
  //   final box = Hive.box('events');
  //   await box.add(newEvent);
  //
  //   await FirebaseAnalytics.instance.logEvent(name: eventName, parameters: newEvent as Map<String, dynamic>);
  // }

  Future<void> processAndPushEvents() async {
    final box = Hive.box('events');
    // await box.clear();
    final events = box.values.map((e) => _convertEventToJson(e)).toList();
    log("Event Data Push ${events}");
    if (events.isEmpty) return;

    Response response = await makeRequest(
      url: BaseUrls.eventUrl,
      baseUrl: BaseUrls.baseUrlAwsDev,
      method: RequestType.post,
      body: events,
    );

    if (response.statusCode == 200) {
      await box.clear();
      print("Events pushed and cleared successfully.");
    } else {
      print("Failed to push events: ${response.statusCode}");
    }
  }

  Map<String, dynamic> _convertEventToJson(dynamic event) {
    final eventMap = Map<String, dynamic>.from(event);
    eventMap.updateAll((key, value) {
      if (value is DateTime) {
        return value.toIso8601String();
      }
      return value;
    });
    return eventMap;
  }
}
