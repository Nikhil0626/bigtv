import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'models/analytics_event.dart';
import 'models/analytics_event_name.dart';

class AnalyticsService {
  AnalyticsService._();
  static final AnalyticsService instance = AnalyticsService._();

  static const String _baseUrl   = 'https://api.pravasamedia.com/api/v1';
  static const String _endpoint  = '/app-analytics/events';
  static const int    _batchSize = 50;
  static const String _queueKey  = 'analytics_event_queue';
  static const String hiveBoxName = 'analytics_events';
  static const String lastSyncKey = 'analytics_last_sync_timestamp';

  late final Dio _dio;
  late String _appVersion;
  late String _deviceId;
  int? _userId;
  String _platform = 'android';

  final List<AnalyticsEvent> _queue = [];
  bool _initialized = false;
  bool _isFlushing  = false;

  String? _currentSessionId;
  DateTime? _sessionStartTime;

  bool get isInitialized => _initialized;
  String get appVersion => _appVersion;
  String get deviceId => _deviceId;
  int? get userId => _userId;
  String get platform => _platform;
  String? get currentSessionId => _currentSessionId;

  static Future<String> getStableDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString("deviceId");
    if (deviceId != null && deviceId.isNotEmpty && deviceId != "null") {
      return deviceId;
    }

    if (!kIsWeb) {
      try {
        final deviceInfo = DeviceInfoPlugin();
        if (Platform.isAndroid) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        } else if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor;
        }
      } catch (e) {
        debugPrint("[Analytics] Error getting hardware deviceId: $e");
      }
    }

    if (deviceId == null || deviceId.isEmpty || deviceId == "null") {
      deviceId = const Uuid().v4();
    }
    await prefs.setString("deviceId", deviceId);
    return deviceId;
  }

  Future<Box<dynamic>?> _getHiveBox() async {
    try {
      if (Hive.isBoxOpen(hiveBoxName)) {
        final b = Hive.box(hiveBoxName);
        if (b.isOpen) return b;
      }
      return await Hive.openBox(hiveBoxName);
    } catch (_) {
      return null;
    }
  }

  Future<void> init({
    required String deviceId,
    required String platform,
    dynamic userId,
  }) async {
    if (_initialized) return;

    final info  = await PackageInfo.fromPlatform();
    _appVersion = '${info.version}+${info.buildNumber}';
    _deviceId   = deviceId;
    _platform   = platform;
    setUser(userId);

    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    await _loadQueue();
    _initialized = true;
    debugPrint('[Analytics] Initialized — version=$_appVersion, deviceId=$_deviceId, platform=$_platform, userId=$_userId');

    // On app open: check if >= 1 hour has elapsed since last sync
    await checkAndSendOnAppOpen();
  }

  void setUser(dynamic userId) {
    if (userId == null) {
      _userId = null;
    } else if (userId is int) {
      _userId = userId;
    } else if (userId is String) {
      _userId = int.tryParse(userId.trim());
    } else if (userId is num) {
      _userId = userId.toInt();
    }
    debugPrint('[Analytics] User updated: $_userId');
  }

  Future<void> startSession() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSessionId = const Uuid().v4();
    _sessionStartTime = DateTime.now();

    int sessionNumber = (prefs.getInt('analytics_session_number') ?? 0) + 1;
    await prefs.setInt('analytics_session_number', sessionNumber);

    await track(AnalyticsEventName.appSessionStart, properties: {
      'session_id': _currentSessionId,
      'session_number': sessionNumber,
    });
  }

  Future<void> endSession() async {
    if (_currentSessionId == null) return;

    final durationSec = _sessionStartTime != null
        ? DateTime.now().difference(_sessionStartTime!).inSeconds
        : 0;

    await track(AnalyticsEventName.appSessionEnd, properties: {
      'session_id': _currentSessionId,
      'duration_seconds': durationSec,
    });

    await track(AnalyticsEventName.userEngagement, properties: {
      'session_id': _currentSessionId,
      'engagement_time_seconds': durationSec,
    });

    _currentSessionId = null;
    _sessionStartTime = null;
  }

  Future<void> trackScreen(String screenName, {String? previousScreen}) async {
    await track(AnalyticsEventName.screenView, properties: {
      'screen_name': screenName,
      'previous_screen': previousScreen,
    });
  }

  Future<void> track(String eventName, {Map<String, dynamic>? properties}) async {
    final event = AnalyticsEvent(
      eventName:  eventName,
      appVersion: _initialized ? _appVersion : 'unknown',
      properties: properties ?? {},
    );

    // Maintain queue & SharedPreferences persistence
    _queue.add(event);
    await _persistQueue();

    // Store in local Hive box in the meanwhile
    final box = await _getHiveBox();
    if (box != null && box.isOpen) {
      await box.add(event.toJsonString());
      debugPrint('[Analytics] Event stored in local Hive: $eventName (Hive total: ${box.length})');
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(lastSyncKey);
    return str != null ? DateTime.tryParse(str) : null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(lastSyncKey, time.toIso8601String());
  }

  Future<void> checkAndSendOnAppOpen() async {
    final lastSync = await getLastSyncTime();
    final now = DateTime.now();

    if (lastSync == null || now.difference(lastSync) >= const Duration(hours: 1)) {
      debugPrint('[Analytics] App open: >= 1 hour since last sync (last: $lastSync). Sending stored events from Hive...');
      await sendStoredEvents(force: true);
    } else {
      final elapsed = now.difference(lastSync);
      final remaining = const Duration(hours: 1) - elapsed;
      debugPrint('[Analytics] App open: < 1 hour since last sync ($remaining remaining). Storing events in local Hive.');
    }
  }

  Future<void> sendStoredEvents({bool force = false}) async {
    if (_isFlushing) return;

    if (!force) {
      final lastSync = await getLastSyncTime();
      if (lastSync != null && DateTime.now().difference(lastSync) < const Duration(hours: 1)) {
        debugPrint('[Analytics] 1 hour has not elapsed yet since last sync. Skipping send.');
        return;
      }
    }

    _isFlushing = true;
    try {
      final box = await _getHiveBox();
      final List<dynamic> hiveKeys = [];
      final List<AnalyticsEvent> eventsToSend = [];

      if (box != null && box.isNotEmpty) {
        hiveKeys.addAll(box.keys);
        for (final key in hiveKeys) {
          final val = box.get(key);
          if (val != null) {
            try {
              if (val is String) {
                eventsToSend.add(AnalyticsEvent.fromJson(jsonDecode(val) as Map<String, dynamic>));
              } else if (val is Map) {
                eventsToSend.add(AnalyticsEvent.fromJson(Map<String, dynamic>.from(val)));
              }
            } catch (e) {
              debugPrint('[Analytics] Error parsing stored event: $e');
            }
          }
        }
      }

      // Also include any events in fallback _queue
      if (_queue.isNotEmpty) {
        eventsToSend.addAll(_queue);
      }

      if (eventsToSend.isEmpty) {
        debugPrint('[Analytics] No stored events to send.');
        return;
      }

      debugPrint('[Analytics] Sending ${eventsToSend.length} event(s) to API endpoint in batches...');

      int processedCount = 0;
      while (processedCount < eventsToSend.length) {
        final end = (processedCount + _batchSize < eventsToSend.length)
            ? processedCount + _batchSize
            : eventsToSend.length;
        final batch = eventsToSend.sublist(processedCount, end);

        final payload = {
          'userId':   _userId,
          'deviceId': _deviceId,
          'platform': _platform,
          'events':   batch.map((e) => e.toJson()).toList(),
        };

        final response = await _dio.post(_endpoint, data: payload);

        if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
          // Delete successfully sent keys from Hive
          if (box != null && hiveKeys.isNotEmpty) {
            final keysToDelete = hiveKeys.sublist(
              processedCount.clamp(0, hiveKeys.length),
              end.clamp(0, hiveKeys.length),
            );
            if (keysToDelete.isNotEmpty) {
              await box.deleteAll(keysToDelete);
            }
          }
          processedCount = end;
          debugPrint('[Analytics] Batch sent successfully (${batch.length} events).');
        } else {
          debugPrint('[Analytics] API returned non-200 status (${response.statusCode}). Aborting remaining batches.');
          break;
        }
      }

      // If all events were successfully sent, clear Hive data and update last sync time
      if (processedCount >= eventsToSend.length) {
        if (box != null) {
          await box.clear();
        }
        _queue.clear();
        await _persistQueue();

        final now = DateTime.now();
        await setLastSyncTime(now);
        debugPrint('[Analytics] All events pushed successfully. Local Hive data cleared at ${now.toIso8601String()}.');
      }
    } on DioException catch (e) {
      debugPrint('[Analytics] Send failed (DioException): ${e.message}. Events remain in Hive for next retry.');
    } catch (e) {
      debugPrint('[Analytics] Unexpected error sending events: $e');
    } finally {
      _isFlushing = false;
    }
  }

  Future<void> flush() async {
    await sendStoredEvents(force: true);
  }

  Future<int> getStoredEventsCount() async {
    final box = await _getHiveBox();
    return (box?.length ?? 0) + _queue.length;
  }

  Future<void> clearHiveData() async {
    final box = await _getHiveBox();
    await box?.clear();
    _queue.clear();
    await _persistQueue();
  }

  Future<void> _persistQueue() async {
    try {
      final prefs   = await SharedPreferences.getInstance();
      final encoded = _queue.map((e) => jsonEncode(e.toJson())).toList();
      await prefs.setStringList(_queueKey, encoded);
    } catch (e) {
      debugPrint('[Analytics] Error persisting queue: $e');
    }
  }

  Future<void> _loadQueue() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_queueKey) ?? [];
      _queue.clear();
      for (final s in stored) {
        try {
          _queue.add(AnalyticsEvent.fromJson(
              jsonDecode(s) as Map<String, dynamic>));
        } catch (_) {}
      }
      if (_queue.isNotEmpty) {
        debugPrint('[Analytics] Restored ${_queue.length} fallback queued event(s).');
      }
    } catch (e) {
      debugPrint('[Analytics] Error loading queue: $e');
    }
  }
}

