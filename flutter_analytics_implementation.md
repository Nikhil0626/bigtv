# Flutter Analytics Event Tracking — Implementation Guide

**API Endpoint:** `POST /app-analytics/events`  
**App version baseline:** `6.0.2+3030`  
**Platforms:** Android · iOS · Flutter Web

---

## Table of Contents

1. [Dependencies](#1-dependencies)
2. [Event Model](#2-event-model)
3. [Event Names Constants](#3-event-names-constants)
4. [Analytics Service](#4-analytics-service)
5. [Offline Queue with Retry](#5-offline-queue-with-retry)
6. [Usage — Emit Events](#6-usage--emit-events)
7. [Initialisation in main.dart](#7-initialisation-in-maindart)
8. [API Payload Reference](#8-api-payload-reference)

---

## 1. Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  dio: ^5.4.0                # HTTP client
  package_info_plus: ^8.0.0  # app version at runtime
  shared_preferences: ^2.2.2 # offline queue persistence
  uuid: ^4.3.3               # generate eventId
  connectivity_plus: ^6.0.0  # detect network state
```

---

## 2. Event Model

```dart
// lib/analytics/models/analytics_event.dart

import 'dart:convert';
import 'package:uuid/uuid.dart';

class AnalyticsEvent {
  final String eventId;
  final String eventName;
  final DateTime dateTime;
  final String appVersion;
  final Map<String, dynamic> properties;

  AnalyticsEvent({
    String? eventId,
    required this.eventName,
    DateTime? dateTime,
    required this.appVersion,
    Map<String, dynamic>? properties,
  })  : eventId = eventId ?? const Uuid().v4(),
        dateTime = dateTime ?? DateTime.now().toUtc(),
        properties = properties ?? {};

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'eventName': eventName,
        'dateTime': dateTime.toUtc().toIso8601String(),
        'appVersion': appVersion,
        'properties': properties,
      };

  String toJsonString() => jsonEncode(toJson());

  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      eventId: json['eventId'] as String,
      eventName: json['eventName'] as String,
      dateTime: DateTime.parse(json['dateTime'] as String),
      appVersion: json['appVersion'] as String,
      properties: Map<String, dynamic>.from(json['properties'] as Map),
    );
  }
}
```

---

## 3. Event Names Constants

```dart
// lib/analytics/models/analytics_event_name.dart

abstract class AnalyticsEventName {
  // 2.1 App Lifecycle
  static const String appOpen           = 'app_open';
  static const String appFirstOpen      = 'app_first_open';
  static const String appSessionStart   = 'app_session_start';
  static const String appSessionEnd     = 'app_session_end';
  static const String appForeground     = 'app_foreground';
  static const String appBackground     = 'app_background';
  static const String appResume         = 'app_resume';
  static const String appDailyActivity  = 'app_daily_activity';

  // 2.2 Retention & Engagement
  static const String userFirstOpen       = 'user_first_open';
  static const String userReturn          = 'user_return';
  static const String userEngagement      = 'user_engagement';
  static const String userActivitySummary = 'user_activity_summary';

  // 2.3 Navigation & Screens
  static const String screenView      = 'screen_view';
  static const String navigationClick = 'navigation_click';
  static const String bottomNavClick  = 'bottom_navigation_click';
  static const String backNavigation  = 'back_navigation';

  // 2.4 Articles & News
  static const String articleOpen         = 'article_open';
  static const String articleReadStart    = 'article_read_start';
  static const String articleReadProgress = 'article_read_progress';
  static const String articleReadComplete = 'article_read_complete';
  static const String articleLike         = 'article_like';
  static const String articleUnlike       = 'article_unlike';
  static const String articleShare        = 'article_share';
  static const String articleFavorite     = 'article_favorite';
  static const String articleUnfavorite   = 'article_unfavorite';

  // 2.5 Notifications, Deep Links & Campaigns
  static const String notificationReceived  = 'notification_received';
  static const String notificationOpen      = 'notification_open';
  static const String notificationDismissed = 'notification_dismissed';
  static const String deepLinkOpen          = 'deep_link_open';
  static const String campaignEntry         = 'campaign_entry';

  // 2.6 Account & Profile
  static const String login                = 'login';
  static const String logout               = 'logout';
  static const String registrationComplete = 'registration_complete';
  static const String userProfileUpdate    = 'user_profile_update';
  static const String userLocationCaptured = 'user_location_captured';

  // 2.7 Language & Content Preferences
  static const String languageSelected          = 'language_selected';
  static const String languageChanged           = 'language_changed';
  static const String categorySelected          = 'category_selected';
  static const String categoryDeselected        = 'category_deselected';
  static const String categoryPreferenceUpdated = 'category_preference_updated';

  // 2.8 Live TV
  static const String liveTvOpen   = 'live_tv_open';
  static const String liveTvPlay   = 'live_tv_play';
  static const String liveTvPause  = 'live_tv_pause';
  static const String liveTvResume = 'live_tv_resume';
  static const String liveTvStop   = 'live_tv_stop';
  static const String liveTvShare  = 'live_tv_share';
  static const String liveTvError  = 'live_tv_error';

  // 2.9 Reels / Short Videos
  static const String reelOpen     = 'reel_open';
  static const String reelPlay     = 'reel_play';
  static const String reelPause    = 'reel_pause';
  static const String reelComplete = 'reel_complete';
  static const String reelRewatch  = 'reel_rewatch';
  static const String reelLike     = 'reel_like';
  static const String reelShare    = 'reel_share';
  static const String reelSkip     = 'reel_skip';

  // 2.10 ePaper
  static const String epaperOpen         = 'epaper_open';
  static const String epaperPageOpen     = 'epaper_page_open';
  static const String epaperPageChange   = 'epaper_page_change';
  static const String epaperReadComplete = 'epaper_read_complete';
  static const String epaperShare        = 'epaper_share';
  static const String epaperDownload     = 'epaper_download';

  // 2.11 Videos
  static const String videoOpen     = 'video_open';
  static const String videoPlay     = 'video_play';
  static const String videoPause    = 'video_pause';
  static const String videoResume   = 'video_resume';
  static const String videoProgress = 'video_progress';
  static const String videoComplete = 'video_complete';
  static const String videoReplay   = 'video_replay';
  static const String videoShare    = 'video_share';
  static const String videoError    = 'video_error';

  // 2.12 Games
  static const String gameListOpen      = 'game_list_open';
  static const String gameOpen          = 'game_open';
  static const String gameStart         = 'game_start';
  static const String gamePause         = 'game_pause';
  static const String gameResume        = 'game_resume';
  static const String gameComplete      = 'game_complete';
  static const String gameIncomplete    = 'game_incomplete';
  static const String gameExit          = 'game_exit';
  static const String gameScoreRecorded = 'game_score_recorded';

  // 2.13 Reporters & Creator Engagement
  static const String reporterListOpen    = 'reporter_list_open';
  static const String reporterProfileOpen = 'reporter_profile_open';
  static const String reporterContentOpen = 'reporter_content_open';
  static const String reporterFollow      = 'reporter_follow';
  static const String reporterUnfollow    = 'reporter_unfollow';
  static const String reporterShare       = 'reporter_share';

  // 2.14 Advertising
  static const String adRequest    = 'ad_request';
  static const String adLoaded     = 'ad_loaded';
  static const String adImpression = 'ad_impression';
  static const String adClicked    = 'ad_clicked';
  static const String adLoadFailed = 'ad_load_failed';
  static const String adDismissed  = 'ad_dismissed';
}
```

---

## 4. Analytics Service

```dart
// lib/analytics/analytics_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/analytics_event.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  static const String _baseUrl   = 'https://api.pravasamedia.com/api/v1';
  static const String _endpoint  = '/app-analytics/events';
  static const int    _batchSize = 50;
  static const String _queueKey  = 'analytics_event_queue';

  late final Dio _dio;
  late String _appVersion;
  late String _deviceId;
  int? _userId;
  String _platform = 'android';

  final List<AnalyticsEvent> _queue = [];
  bool _initialized = false;
  bool _isFlushing  = false;

  Future<void> init({
    required String deviceId,
    required String platform,
    int? userId,
  }) async {
    if (_initialized) return;

    final info  = await PackageInfo.fromPlatform();
    _appVersion = '${info.version}+${info.buildNumber}';
    _deviceId   = deviceId;
    _platform   = platform;
    _userId     = userId;

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    await _loadQueue();
    _initialized = true;
    debugPrint('[Analytics] Initialized — version=$_appVersion');
  }

  void setUser(int? userId) => _userId = userId;

  Future<void> track(String eventName, {Map<String, dynamic>? properties}) async {
    assert(_initialized, 'Call AnalyticsService.instance.init() first.');

    final event = AnalyticsEvent(
      eventName:  eventName,
      appVersion: _appVersion,
      properties: properties ?? {},
    );

    _queue.add(event);
    await _persistQueue();

    if (_queue.length >= _batchSize) await flush();
  }

  Future<void> flush() async {
    if (_isFlushing || _queue.isEmpty) return;
    _isFlushing = true;

    final batch = List<AnalyticsEvent>.from(_queue);

    try {
      final response = await _dio.post(_endpoint, data: {
        'userId':   _userId,
        'deviceId': _deviceId,
        'platform': _platform,
        'events':   batch.map((e) => e.toJson()).toList(),
      });

      if (response.statusCode == 200) {
        _queue.removeRange(0, batch.length);
        await _persistQueue();
        debugPrint('[Analytics] Flushed ${batch.length} event(s).');
      }
    } on DioException catch (e) {
      debugPrint('[Analytics] Flush failed (will retry): ${e.message}');
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> _persistQueue() async {
    final prefs   = await SharedPreferences.getInstance();
    final encoded = _queue.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_queueKey, encoded);
  }

  Future<void> _loadQueue() async {
    final prefs  = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_queueKey) ?? [];
    _queue.clear();
    for (final s in stored) {
      try {
        _queue.add(AnalyticsEvent.fromJson(
            jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    debugPrint('[Analytics] Restored ${_queue.length} queued event(s).');
  }
}
```

---

## 5. Offline Queue with Retry

Events are persisted to `SharedPreferences` on every `track()` call and removed **only after a successful `200` response**.

**Retry flow:**

```
App open
  ├─ _loadQueue()   ← restores un-sent events from disk
  └─ flush()        ← retries immediately if network is available

App background / session end
  └─ flush()        ← drain the queue before the OS suspends the app

Batch full (>= 50 events)
  └─ flush()        ← automatic mid-session flush
```

**Connectivity watcher** — retries automatically when network is restored:

```dart
// lib/analytics/analytics_connectivity_watcher.dart

import 'package:connectivity_plus/connectivity_plus.dart';
import 'analytics_service.dart';

class AnalyticsConnectivityWatcher {
  static void start() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        AnalyticsService.instance.flush();
      }
    });
  }
}
```

**App lifecycle observer** — auto-tracks foreground/background/resume:

```dart
// lib/app_lifecycle_observer.dart

import 'package:flutter/material.dart';
import 'analytics/analytics_service.dart';
import 'analytics/models/analytics_event_name.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  DateTime? _backgroundedAt;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final a = AnalyticsService.instance;
    switch (state) {
      case AppLifecycleState.paused:
        _backgroundedAt = DateTime.now();
        a.track(AnalyticsEventName.appBackground);
        a.flush(); // drain before OS suspends
        break;
      case AppLifecycleState.resumed:
        final seconds = _backgroundedAt == null
            ? 0
            : DateTime.now().difference(_backgroundedAt!).inSeconds;
        a.track(AnalyticsEventName.appResume,
            properties: {'time_in_background_seconds': seconds});
        _backgroundedAt = null;
        break;
      default:
        break;
    }
  }
}
```

**Navigator observer** — auto-tracks `screen_view`:

```dart
// lib/analytics/analytics_navigator_observer.dart

import 'package:flutter/material.dart';
import 'analytics_service.dart';
import 'models/analytics_event_name.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  String? _previousRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    _track(route.settings.name, _previousRoute);
    _previousRoute = route.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _track(previousRoute?.settings.name, route.settings.name);
    _previousRoute = previousRoute?.settings.name;
  }

  void _track(String? screen, String? previous) {
    if (screen == null) return;
    AnalyticsService.instance.track(AnalyticsEventName.screenView,
        properties: {'screen_name': screen, 'previous_screen': previous});
  }
}
```

---

## 6. Usage — Emit Events

Add this import at the top of any file that emits events:

```dart
import 'package:your_app/analytics/analytics_service.dart';
import 'package:your_app/analytics/models/analytics_event_name.dart';

final _a = AnalyticsService.instance;
```

### 6.1 App Lifecycle

```dart
await _a.track(AnalyticsEventName.appOpen,
    properties: {'launch_type': 'cold'});

await _a.track(AnalyticsEventName.appFirstOpen,
    properties: {'install_source': 'organic'});

await _a.track(AnalyticsEventName.appSessionStart,
    properties: {'session_id': sessionId, 'session_number': sessionNumber});

await _a.track(AnalyticsEventName.appSessionEnd,
    properties: {'session_id': sessionId, 'duration_seconds': durationSec});
```

### 6.2 Navigation & Screens

```dart
await _a.track(AnalyticsEventName.screenView,
    properties: {'screen_name': 'home', 'previous_screen': 'splash'});

await _a.track(AnalyticsEventName.bottomNavClick,
    properties: {'item_name': 'videos', 'destination': 'videos'});

await _a.track(AnalyticsEventName.backNavigation,
    properties: {'from_screen': 'article_detail', 'to_screen': 'home'});
```

### 6.3 Articles & News

```dart
await _a.track(AnalyticsEventName.articleOpen, properties: {
  'article_id': article.id,
  'article_category': article.category,
  'language': article.language,
  'source_screen': 'home',
  'position': listIndex,
});

// Emit at 25%, 50%, 75%
await _a.track(AnalyticsEventName.articleReadProgress,
    properties: {'article_id': article.id, 'progress_percent': 50});

await _a.track(AnalyticsEventName.articleReadComplete,
    properties: {'article_id': article.id, 'read_duration_seconds': secs});

await _a.track(AnalyticsEventName.articleLike,
    properties: {'article_id': article.id});

await _a.track(AnalyticsEventName.articleShare,
    properties: {'article_id': article.id, 'share_target': 'whatsapp'});

await _a.track(AnalyticsEventName.articleFavorite,
    properties: {'article_id': article.id});
```

### 6.4 Notifications & Deep Links

```dart
// FCM onMessage
await _a.track(AnalyticsEventName.notificationReceived, properties: {
  'notification_id': message.messageId,
  'campaign_id': message.data['campaign_id'],
  'notification_type': message.data['type'] ?? 'general',
});

// FCM onMessageOpenedApp
await _a.track(AnalyticsEventName.notificationOpen, properties: {
  'notification_id': message.messageId,
  'campaign_id': message.data['campaign_id'],
  'destination': message.data['destination'] ?? 'home',
});

await _a.track(AnalyticsEventName.deepLinkOpen, properties: {
  'destination': 'article_detail',
  'source': 'push_notification',
  'content_id': contentId,
});
```

### 6.5 Account & Profile

```dart
await _a.track(AnalyticsEventName.login,
    properties: {'method': 'otp'});
_a.setUser(userId);

await _a.track(AnalyticsEventName.logout);
_a.setUser(null);

await _a.track(AnalyticsEventName.registrationComplete,
    properties: {'method': 'otp'});

await _a.track(AnalyticsEventName.userProfileUpdate,
    properties: {'updated_fields': ['display_name', 'language']});
```

### 6.6 Language & Preferences

```dart
await _a.track(AnalyticsEventName.languageChanged,
    properties: {'previous_language': 'en', 'new_language': 'te'});

await _a.track(AnalyticsEventName.categorySelected,
    properties: {'category_id': 'politics', 'category_name': 'Politics'});

await _a.track(AnalyticsEventName.categoryPreferenceUpdated,
    properties: {'selected_category_ids': ['politics', 'sports', 'cinema']});
```

### 6.7 Live TV

```dart
await _a.track(AnalyticsEventName.liveTvOpen,
    properties: {'channel_id': 'bigtv_telugu', 'source_screen': 'home'});

await _a.track(AnalyticsEventName.liveTvPlay,
    properties: {'channel_id': 'bigtv_telugu', 'stream_type': 'hls'});

await _a.track(AnalyticsEventName.liveTvPause, properties: {
  'channel_id': 'bigtv_telugu',
  'playback_position_seconds': positionSeconds,
});

await _a.track(AnalyticsEventName.liveTvStop, properties: {
  'channel_id': 'bigtv_telugu',
  'watch_duration_seconds': watchSeconds,
});

await _a.track(AnalyticsEventName.liveTvError, properties: {
  'channel_id': 'bigtv_telugu',
  'error_code': 'stream_timeout',
});
```

### 6.8 Reels / Short Videos

```dart
await _a.track(AnalyticsEventName.reelOpen,
    properties: {'reel_id': reel.id, 'position': feedIndex});

await _a.track(AnalyticsEventName.reelPlay,
    properties: {'reel_id': reel.id});

await _a.track(AnalyticsEventName.reelComplete, properties: {
  'reel_id': reel.id,
  'watch_duration_seconds': watchSeconds,
});

await _a.track(AnalyticsEventName.reelSkip, properties: {
  'reel_id': reel.id,
  'watch_duration_seconds': watchSeconds,
});

await _a.track(AnalyticsEventName.reelLike,
    properties: {'reel_id': reel.id});

await _a.track(AnalyticsEventName.reelShare,
    properties: {'reel_id': reel.id, 'share_target': 'whatsapp'});
```

### 6.9 ePaper

```dart
await _a.track(AnalyticsEventName.epaperOpen, properties: {
  'edition_id': edition.id,
  'edition_name': edition.name,
  'language': edition.language,
});

await _a.track(AnalyticsEventName.epaperPageChange, properties: {
  'edition_id': edition.id,
  'from_page': fromPage,
  'to_page': toPage,
});

await _a.track(AnalyticsEventName.epaperReadComplete, properties: {
  'edition_id': edition.id,
  'pages_viewed': pagesViewed,
  'duration_seconds': durationSeconds,
});

await _a.track(AnalyticsEventName.epaperDownload, properties: {
  'edition_id': edition.id,
  'download_format': 'pdf',
});
```

### 6.10 Videos

```dart
await _a.track(AnalyticsEventName.videoPlay, properties: {
  'video_id': video.id,
  'video_duration_seconds': video.durationSeconds,
});

// Emit at 25%, 50%, 75%
await _a.track(AnalyticsEventName.videoProgress, properties: {
  'video_id': video.id,
  'progress_percent': progressPercent,
  'playback_position_seconds': positionSeconds,
});

await _a.track(AnalyticsEventName.videoComplete, properties: {
  'video_id': video.id,
  'watch_duration_seconds': watchSeconds,
});

await _a.track(AnalyticsEventName.videoError,
    properties: {'video_id': video.id, 'error_code': 'network_timeout'});
```

### 6.11 Games

```dart
await _a.track(AnalyticsEventName.gameStart,
    properties: {'game_id': game.id, 'round_id': roundId});

await _a.track(AnalyticsEventName.gameComplete, properties: {
  'game_id': game.id,
  'round_id': roundId,
  'score': score,
});

await _a.track(AnalyticsEventName.gameIncomplete, properties: {
  'game_id': game.id,
  'round_id': roundId,
  'reason': 'user_exit',
});

await _a.track(AnalyticsEventName.gameScoreRecorded,
    properties: {'game_id': game.id, 'score': score, 'rank': rank});
```

### 6.12 Reporters

```dart
await _a.track(AnalyticsEventName.reporterProfileOpen,
    properties: {'reporter_id': reporter.id});

await _a.track(AnalyticsEventName.reporterFollow,
    properties: {'reporter_id': reporter.id});

await _a.track(AnalyticsEventName.reporterContentOpen, properties: {
  'reporter_id': reporter.id,
  'content_id': contentId,
  'content_type': 'article',
});
```

### 6.13 Advertising

```dart
await _a.track(AnalyticsEventName.adLoaded, properties: {
  'ad_unit_id': 'banner_home',
  'ad_format': 'banner',
  'placement': 'home_bottom',
  'load_duration_ms': loadMs,
});

// Only emit after SDK confirms impression — NOT on load
await _a.track(AnalyticsEventName.adImpression, properties: {
  'ad_unit_id': 'banner_home',
  'ad_format': 'banner',
  'placement': 'home_bottom',
});

await _a.track(AnalyticsEventName.adLoadFailed,
    properties: {'ad_unit_id': 'banner_home', 'error_code': 'no_fill'});
```

---

## 7. Initialisation in main.dart

```dart
// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'analytics/analytics_service.dart';
import 'analytics/analytics_navigator_observer.dart';
import 'analytics/analytics_connectivity_watcher.dart';
import 'analytics/models/analytics_event_name.dart';
import 'app_lifecycle_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final platform = Platform.isAndroid
      ? 'android'
      : Platform.isIOS
          ? 'ios'
          : 'web';

  await AnalyticsService.instance.init(
    deviceId: 'YOUR_STABLE_DEVICE_ID', // use device_info_plus + secure_storage
    platform: platform,
    userId: null, // set via setUser() after login
  );

  AnalyticsConnectivityWatcher.start();

  await AnalyticsService.instance.track(
    AnalyticsEventName.appOpen,
    properties: {'launch_type': 'cold'},
  );

  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [AnalyticsNavigatorObserver()],
      // ...
    );
  }
}
```

---

## 8. API Payload Reference

**Endpoint:** `POST /app-analytics/events`  
**Content-Type:** `application/json`

### Request

```json
{
  "userId": 123,
  "deviceId": "device_abc123",
  "platform": "android",
  "events": [
    {
      "eventId": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "eventName": "app_open",
      "dateTime": "2026-10-13T09:00:00Z",
      "appVersion": "6.0.2+3030",
      "properties": { "launch_type": "cold" }
    },
    {
      "eventId": "7cb9fc34-1a2b-4d81-9f22-abcdef123456",
      "eventName": "screen_view",
      "dateTime": "2026-10-13T09:00:03Z",
      "appVersion": "6.0.2+3030",
      "properties": { "screen_name": "home", "previous_screen": null }
    }
  ]
}
```

### Response

```json
{
  "accepted": 2,
  "skipped": 0,
  "message": "All events stored successfully."
}
```

### Field Reference

| Field | Type | Required | Notes |
|---|---|---|---|
| `userId` | `integer or null` | No | `null` for anonymous users |
| `deviceId` | `string` | **Yes** | Stable installation ID |
| `platform` | `android / ios / web` | **Yes** | |
| `events[].eventId` | `string` | **Yes** | UUID v4 — reuse on retry |
| `events[].eventName` | `string` | **Yes** | Use `AnalyticsEventName` constants |
| `events[].dateTime` | ISO-8601 UTC string | **Yes** | e.g. `2026-10-13T09:00:00Z` |
| `events[].appVersion` | `string` | **Yes** | From `package_info_plus` at runtime |
| `events[].properties` | `object` | No | Free-style event payload |

### Implementation Rules

| Rule | Detail |
|---|---|
| Batch size | Max **50 events** per request |
| Dequeue | Remove from queue **only after `200`** |
| Retry | Reuse the same `eventId` — server deduplicates |
| App version | Always read from `package_info_plus`, never hard-code |
| Flush triggers | `app_background`, `app_session_end`, batch full |
| Progress events | Emit only at milestones (25%, 50%, 75%, 100%) |
| Ad impressions | Only emit after SDK callback, not on ad load |
| Privacy | Never send OTPs, tokens, or raw GPS coordinates |

---

*Generated for BIGTV / ChotaNews Flutter app — spec version 1.0*
