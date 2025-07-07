import 'dart:developer';

import 'package:chotanews/aggricator_screens/event_repo.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static DateTime? _sessionStartTime;

  static Future<void> logEvent2(String name) async {
    try {
      await _analytics.logEvent(
        name: name,
      );
      // KochavaMeasurement.instance.sendEvent(name,);
      await FacebookAppEvents().logEvent(name: name);

      log("Event sent successfully.  $name");
    } catch (e) {
      log("Error sending event: $e");
    }
  }

  Future<void> trackArticlesRead() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().substring(0, 10);
    int count = prefs.getInt("articles_read_$today") ?? 0;
    count++;
    prefs.setInt("articles_read_$today", count);
    log("send event $count");
    if (count == 10) {
      log("send event 10 stored");
      logEvent2(
        "user_red_10_article_on_day_0",
      );
      // EventRepo().addEvent({
      //   "user_read_article": "user_red_10_article_on_day_0",
      //   "createAt": DateTime.now().toString(),
      // }, "perDay_read_article");
    }
    if (count == 20) {
      log("send event 20 stored");
      logEvent2("user_red_20_article_on_day_0");
      // EventRepo().addEvent({
      //   "user_read_article": "user_red_20_article_on_day_0",
      //   "createAt": DateTime.now().toString(),
      // }, "perDay_read_article");
    }
    if (count == 30) {
      log("send event 30 stored");
      logEvent2(
        "user_red_30_article_on_day_0",
      );
      // EventRepo().addEvent({
      //   "user_read_article": "user_red_30_article_on_day_0",
      //   "createAt": DateTime.now().toString(),
      // }, "perDay_read_article");
    }
  }

  Future<void> trackArticleReadingTime(Duration duration, allPostList) async {
    final seconds = duration.inSeconds;

    if (seconds < 5) {
      EventRepo().addEvent({
        "user_read_time": "flipped_under_5_sec",
        "postId": "$allPostList",
        "seconds": seconds.toString(),
        "createAt": DateTime.now().toString(),
      }, "perDay_read_time");
      logEvent2("flipped_under_5_sec");
    } else if (seconds < 30) {
      EventRepo().addEvent({
        "user_read_time": "flipped_under_30_sec",
        "postId": "$allPostList",
        "seconds": seconds.toString(),
        "createAt": DateTime.now().toString(),
      }, "perDay_read_time");
      logEvent2("flipped_under_30_sec");
    } else if (seconds < 60) {
      EventRepo().addEvent({
        "user_read_time": "flipped_under_60_sec",
        "postId": "$allPostList",
        "seconds": seconds.toString(),
        "createAt": DateTime.now().toString(),
      }, "perDay_read_time");
      logEvent2("flipped_under_60_sec");
    } else {
      EventRepo().addEvent({
        "user_read_time": "flipped_over_60_sec",
        "postId": "$allPostList",
        "seconds": seconds.toString(),
        "createAt": DateTime.now().toString(),
      }, "perDay_read_time");
      logEvent2("flipped_over_60_sec");
    }
    // final prefs = await SharedPreferences.getInstance();
    //
    // List<String> triggered =
    //     prefs.getStringList("reading_time_triggered_$today") ?? [];
    //
    // for (int threshold in thresholds) {
    //   String key = "read_${threshold}_sec";
    //   if (secondsSpent >= threshold && !triggered.contains(key)) {
    //     // Mark as triggered
    //     triggered.add(key);
    //     log("send time event $key stored");
    //
    //     // Log event
    //     logEvent2(key);

    //   }
    // }
    //
    // // Save updated triggered list
    // prefs.setStringList("reading_time_triggered_$today", triggered);
  }


  static Future<void> checkRetention() async {
    final prefs = await SharedPreferences.getInstance();

    String? firstOpenDate = prefs.getString("first_open_date");
    if (firstOpenDate == null) {
      String today = DateTime.now().toString().substring(0, 10);
      await prefs.setString("first_open_date", today);
      return; // No retention event to log yet
    }

    DateTime firstOpen = DateTime.parse(firstOpenDate);
    int daysSinceFirstOpen = DateTime.now().difference(firstOpen).inDays;

    if (daysSinceFirstOpen == 1) {
      logEvent2("D1_retention");
      EventRepo().addEvent({
        "retention": "D1_retention",
        "createAt": DateTime.now().toString(),
      }, "day_retention");
    } else if (daysSinceFirstOpen == 7) {
      logEvent2("D7_retention");
      EventRepo().addEvent({
        "retention": "D7_retention",
        "createAt": DateTime.now().toString(),
      }, "day_retention");
    } else if (daysSinceFirstOpen == 15) {
      logEvent2("D15_retention");
      EventRepo().addEvent({
        "retention": "D15_retention",
        "createAt": DateTime.now().toString(),
      }, "day_retention");
    } else if (daysSinceFirstOpen == 30) {
      logEvent2("D30_retention");
      EventRepo().addEvent({
        "retention": "D30_retention",
        "createAt": DateTime.now().toString(),
      }, "day_retention");
    }
  }

  static void startSession() {
    _sessionStartTime = DateTime.now();
  }

  static Future<void> endSession() async {
    if (_sessionStartTime == null) return;

    final DateTime sessionEndTime = DateTime.now();
    final int sessionDuration = sessionEndTime.difference(_sessionStartTime!).inSeconds;

    final prefs = await SharedPreferences.getInstance();
    final int currentTime = DateTime.now().millisecondsSinceEpoch;

    List<String> sessionData = prefs.getStringList("session_times") ?? [];
    sessionData.add("$currentTime:$sessionDuration");
    prefs.setStringList("session_times", sessionData);

    checkAndLogEvents(prefs);
  }

  static Future<void> checkAndLogEvents(SharedPreferences prefs) async {
    final List<String> sessionData = prefs.getStringList("session_times") ?? [];
    final int now = DateTime.now().millisecondsSinceEpoch;

    int totalTime24h = 0;
    int totalTime48h = 0;

    for (String data in sessionData) {
      List<String> parts = data.split(":");
      int timestamp = int.parse(parts[0]);
      int duration = int.parse(parts[1]);

      if (now - timestamp <= 24 * 60 * 60 * 1000) {
        totalTime24h += duration;
      }
      if (now - timestamp <= 48 * 60 * 60 * 1000) {
        totalTime48h += duration;
      }
    }

    if (totalTime24h >= 5 * 60) {
      logEvent2("user_spent_5_minutes_in_24_hours");
      EventRepo().addEvent({
        "sessions":"user_spent_5_minutes_in_24_hours",
        "createAt": DateTime.now().toString(),
      }, "user_sessions");
    }
    if (totalTime48h >= 20 * 60) {
      logEvent2("user_spent_20_minutes_in_48_hours");
      EventRepo().addEvent({
        "sessions":"user_spent_20_minutes_in_48_hours",
        "createAt": DateTime.now().toString(),
      }, "user_sessions");
    }
  }

  Future<void> trackAppOpen() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().substring(0, 10);

    List<String> openDays = prefs.getStringList("open_days") ?? [];
    if (!openDays.contains(today)) {
      openDays.add(today);
      prefs.setStringList("open_days", openDays);
    }

    if (openDays.length >= 3) {
      logEvent2("user_consecutive_app_open_3_days");
      EventRepo().addEvent({
        "sessions":" user_consecutive_app_open_3_days",
        "createAt": DateTime.now().toString(),
      }, "user_sessions");
    }
    if (openDays.length >= 7) {
      logEvent2("user_consecutive_app_open_7_days");
      EventRepo().addEvent({
        "sessions":"user_consecutive_app_open_7_days",
        "createAt": DateTime.now().toString(),
      }, "user_sessions");
    }
  }

  static Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }
}
