import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:chotanews/analytics/models/analytics_event.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/ad_analytics.dart';
import 'package:chotanews/services/event_cron.dart';
import 'package:chotanews/app_lifecycle_observer.dart';
import 'package:chotanews/features/home/presentation/screens/tag_video_player_screen.dart';
import 'package:chotanews/features/home/presentation/screens/live_tv_screen.dart';
import 'package:chotanews/features/reels/presentation/widgets/reels_screen_preview.dart';
import 'package:chotanews/features/home/presentation/screens/epaper_detail_screen.dart';
import 'package:chotanews/features/reporters/presentation/screens/reporters_screen.dart';
import 'package:chotanews/features/reporters/presentation/screens/reporter_details_screen.dart';
import 'package:chotanews/features/zip_puzzle/presentation/screens/zip_gameplay_screen.dart';
import 'package:chotanews/features/zip_puzzle/presentation/providers/zip_game_provider.dart';
import 'package:chotanews/features/sudoku_puzzle/presentation/screens/sudoku_game_screen.dart';
import 'package:chotanews/features/patches_puzzle/presentation/screens/patch_game_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_analytics_suite');
    Hive.init(tempDir.path);
    await Hive.openBox(AnalyticsService.hiveBoxName);
  });

  tearDownAll(() async {
    if (Hive.isBoxOpen(AnalyticsService.hiveBoxName)) {
      await Hive.box(AnalyticsService.hiveBoxName).close();
    }
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  group('AnalyticsEvent Model Tests', () {
    test('creates event with default UUID and current UTC time', () {
      final event = AnalyticsEvent(
        eventName: AnalyticsEventName.appOpen,
        appVersion: '6.0.2+3030',
        properties: {'launch_type': 'cold'},
      );

      expect(event.eventId, isNotEmpty);
      expect(event.eventName, equals('app_open'));
      expect(event.appVersion, equals('6.0.2+3030'));
      expect(event.properties['launch_type'], equals('cold'));
      expect(event.dateTime.isUtc, isTrue);

      final json = event.toJson();
      expect(json['eventId'], equals(event.eventId));
      expect(json['eventName'], equals('app_open'));
      expect(json['appVersion'], equals('6.0.2+3030'));
      expect(json['dateTime'], equals(event.dateTime.toIso8601String()));
      expect(json['properties'], equals({'launch_type': 'cold'}));
    });

    test('serializes to and from JSON correctly', () {
      final jsonMap = {
        'eventId': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
        'eventName': 'screen_view',
        'dateTime': '2026-10-13T09:00:00.000Z',
        'appVersion': '6.0.2+3030',
        'properties': {'screen_name': 'home', 'previous_screen': null},
      };

      final event = AnalyticsEvent.fromJson(jsonMap);
      expect(event.eventId, equals('3fa85f64-5717-4562-b3fc-2c963f66afa6'));
      expect(event.eventName, equals('screen_view'));
      expect(event.appVersion, equals('6.0.2+3030'));
      expect(event.properties['screen_name'], equals('home'));
      expect(event.properties['previous_screen'], isNull);

      final outJson = event.toJson();
      expect(outJson['eventId'], equals(jsonMap['eventId']));
      expect(outJson['eventName'], equals(jsonMap['eventName']));
    });
  });

  group('AnalyticsEventName Constants Tests', () {
    test('all event name constants match specification', () {
      expect(AnalyticsEventName.appOpen, equals('app_open'));
      expect(AnalyticsEventName.appFirstOpen, equals('app_first_open'));
      expect(AnalyticsEventName.appSessionStart, equals('app_session_start'));
      expect(AnalyticsEventName.appSessionEnd, equals('app_session_end'));
      expect(AnalyticsEventName.appBackground, equals('app_background'));
      expect(AnalyticsEventName.appResume, equals('app_resume'));
      expect(AnalyticsEventName.screenView, equals('screen_view'));
      expect(AnalyticsEventName.bottomNavClick, equals('bottom_navigation_click'));
      expect(AnalyticsEventName.articleOpen, equals('article_open'));
      expect(AnalyticsEventName.articleReadComplete, equals('article_read_complete'));
      expect(AnalyticsEventName.articleFavorite, equals('article_favorite'));
      expect(AnalyticsEventName.articleShare, equals('article_share'));
      expect(AnalyticsEventName.notificationReceived, equals('notification_received'));
      expect(AnalyticsEventName.notificationOpen, equals('notification_open'));
      expect(AnalyticsEventName.deepLinkOpen, equals('deep_link_open'));
      expect(AnalyticsEventName.login, equals('login'));
      expect(AnalyticsEventName.logout, equals('logout'));
      expect(AnalyticsEventName.registrationComplete, equals('registration_complete'));
      expect(AnalyticsEventName.liveTvOpen, equals('live_tv_open'));
      expect(AnalyticsEventName.liveTvPlay, equals('live_tv_play'));
      expect(AnalyticsEventName.liveTvPause, equals('live_tv_pause'));
      expect(AnalyticsEventName.liveTvStop, equals('live_tv_stop'));
      expect(AnalyticsEventName.liveTvError, equals('live_tv_error'));
      expect(AnalyticsEventName.reelOpen, equals('reel_open'));
      expect(AnalyticsEventName.reelPlay, equals('reel_play'));
      expect(AnalyticsEventName.reelComplete, equals('reel_complete'));
      expect(AnalyticsEventName.reelSkip, equals('reel_skip'));
      expect(AnalyticsEventName.reelLike, equals('reel_like'));
      expect(AnalyticsEventName.reelShare, equals('reel_share'));
      expect(AnalyticsEventName.epaperOpen, equals('epaper_open'));
      expect(AnalyticsEventName.epaperPageChange, equals('epaper_page_change'));
      expect(AnalyticsEventName.epaperReadComplete, equals('epaper_read_complete'));
      expect(AnalyticsEventName.epaperShare, equals('epaper_share'));
      expect(AnalyticsEventName.epaperDownload, equals('epaper_download'));
      expect(AnalyticsEventName.epaperPageOpen, equals('epaper_page_open'));
      expect(AnalyticsEventName.gameListOpen, equals('game_list_open'));
      expect(AnalyticsEventName.gameOpen, equals('game_open'));
      expect(AnalyticsEventName.gameStart, equals('game_start'));
      expect(AnalyticsEventName.gamePause, equals('game_pause'));
      expect(AnalyticsEventName.gameResume, equals('game_resume'));
      expect(AnalyticsEventName.gameComplete, equals('game_complete'));
      expect(AnalyticsEventName.gameIncomplete, equals('game_incomplete'));
      expect(AnalyticsEventName.gameExit, equals('game_exit'));
      expect(AnalyticsEventName.gameScoreRecorded, equals('game_score_recorded'));
      expect(AnalyticsEventName.reporterListOpen, equals('reporter_list_open'));
      expect(AnalyticsEventName.reporterProfileOpen, equals('reporter_profile_open'));
      expect(AnalyticsEventName.reporterContentOpen, equals('reporter_content_open'));
      expect(AnalyticsEventName.reporterFollow, equals('reporter_follow'));
      expect(AnalyticsEventName.reporterUnfollow, equals('reporter_unfollow'));
      expect(AnalyticsEventName.reporterShare, equals('reporter_share'));
      expect(AnalyticsEventName.videoOpen, equals('video_open'));
      expect(AnalyticsEventName.videoPlay, equals('video_play'));
      expect(AnalyticsEventName.videoPause, equals('video_pause'));
      expect(AnalyticsEventName.videoResume, equals('video_resume'));
      expect(AnalyticsEventName.videoProgress, equals('video_progress'));
      expect(AnalyticsEventName.videoComplete, equals('video_complete'));
      expect(AnalyticsEventName.videoReplay, equals('video_replay'));
      expect(AnalyticsEventName.videoShare, equals('video_share'));
      expect(AnalyticsEventName.videoError, equals('video_error'));
      expect(AnalyticsEventName.adRequest, equals('ad_request'));
      expect(AnalyticsEventName.adLoaded, equals('ad_loaded'));
      expect(AnalyticsEventName.adImpression, equals('ad_impression'));
      expect(AnalyticsEventName.adClicked, equals('ad_clicked'));
      expect(AnalyticsEventName.adLoadFailed, equals('ad_load_failed'));
      expect(AnalyticsEventName.adDismissed, equals('ad_dismissed'));
      expect(AnalyticsEventName.reelPause, equals('reel_pause'));
      expect(AnalyticsEventName.reelRewatch, equals('reel_rewatch'));
      expect(AnalyticsEventName.liveTvShare, equals('live_tv_share'));
      expect(AnalyticsEventName.backNavigation, equals('back_navigation'));
      expect(AnalyticsEventName.navigationClick, equals('navigation_click'));
      expect(AnalyticsEventName.userActivitySummary, equals('user_activity_summary'));
      expect(AnalyticsEventName.userEngagement, equals('user_engagement'));
    });
  });

  group('AnalyticsService Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      PackageInfo.setMockInitialValues(
        appName: 'BIGTV',
        packageName: 'com.chotanews',
        version: '6.0.2',
        buildNumber: '3030',
        buildSignature: '',
      );
    });

    test('initializes service, loads and persists queue', () async {
      final service = AnalyticsService.instance;
      await service.init(
        deviceId: 'test_device_123',
        platform: 'android',
        userId: '456',
      );

      expect(service.isInitialized, isTrue);
      expect(service.deviceId, equals('test_device_123'));
      expect(service.platform, equals('android'));
      expect(service.userId, equals(456));
      expect(service.appVersion, equals('6.0.2+3030'));

      // Test setUser string vs int vs null
      service.setUser('789');
      expect(service.userId, equals(789));

      service.setUser(null);
      expect(service.userId, isNull);

      // Test tracking an event adds to queue and persists
      await service.track(
        AnalyticsEventName.screenView,
        properties: {'screen_name': 'home', 'previous_screen': 'splash'},
      );

      final prefs = await SharedPreferences.getInstance();
      final storedQueue = prefs.getStringList('analytics_event_queue');
      expect(storedQueue, isNotNull);
      expect(storedQueue!.length, equals(1));

      final decoded = jsonDecode(storedQueue.first) as Map<String, dynamic>;
      expect(decoded['eventName'], equals('screen_view'));
      expect(decoded['properties']['screen_name'], equals('home'));
    });
  });

  group('AdAnalytics Helper Tests', () {
    test('tracks all advertising SDK events per spec', () async {
      await AdAnalytics.trackRequest(
        adUnitId: 'banner_home',
        adFormat: 'banner',
        placement: 'home_bottom',
      );

      await AdAnalytics.trackLoaded(
        adUnitId: 'banner_home',
        adFormat: 'banner',
        placement: 'home_bottom',
        loadDurationMs: 320,
      );

      await AdAnalytics.trackImpression(
        adUnitId: 'banner_home',
        adFormat: 'banner',
        placement: 'home_bottom',
      );

      await AdAnalytics.trackClicked(
        adUnitId: 'banner_home',
        adFormat: 'banner',
        placement: 'home_bottom',
      );

      await AdAnalytics.trackLoadFailed(
        adUnitId: 'banner_home',
        adFormat: 'banner',
        placement: 'home_bottom',
        errorCode: 'no_fill',
      );

      await AdAnalytics.trackDismissed(
        adUnitId: 'interstitial_exit',
        adFormat: 'interstitial',
      );

      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList('analytics_event_queue')!;
      final eventNames = stored.map((s) => (jsonDecode(s) as Map)['eventName']).toList();

      expect(eventNames, contains(AnalyticsEventName.adRequest));
      expect(eventNames, contains(AnalyticsEventName.adLoaded));
      expect(eventNames, contains(AnalyticsEventName.adImpression));
      expect(eventNames, contains(AnalyticsEventName.adClicked));
      expect(eventNames, contains(AnalyticsEventName.adLoadFailed));
      expect(eventNames, contains(AnalyticsEventName.adDismissed));
    });
  });

  group('Hive Storage & 1-Hour Cron Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      if (Hive.isBoxOpen(AnalyticsService.hiveBoxName)) {
        await Hive.box(AnalyticsService.hiveBoxName).clear();
      }
    });

    test('stores events directly in local Hive box in the meanwhile time', () async {
      final service = AnalyticsService.instance;
      final box = Hive.box(AnalyticsService.hiveBoxName);
      await box.clear();

      await service.track(
        AnalyticsEventName.articleOpen,
        properties: {'article_id': 101, 'article_category': 'politics'},
      );

      await service.track(
        AnalyticsEventName.articleReadComplete,
        properties: {'article_id': 101, 'read_duration_seconds': 45},
      );

      expect(box.length, equals(2));
      final firstRaw = box.getAt(0) as String;
      final firstJson = jsonDecode(firstRaw) as Map<String, dynamic>;
      expect(firstJson['eventName'], equals('article_open'));
      expect(firstJson['properties']['article_id'], equals(101));

      final secondRaw = box.getAt(1) as String;
      final secondJson = jsonDecode(secondRaw) as Map<String, dynamic>;
      expect(secondJson['eventName'], equals('article_read_complete'));
    });

    test('app open check skips send when less than 1 hour elapsed', () async {
      final service = AnalyticsService.instance;
      final box = Hive.box(AnalyticsService.hiveBoxName);
      await box.clear();

      // Set last sync to 20 minutes ago (< 1 hour)
      final twentyMinsAgo = DateTime.now().subtract(const Duration(minutes: 20));
      await service.setLastSyncTime(twentyMinsAgo);

      // Track an event stored in Hive
      await service.track(AnalyticsEventName.screenView, properties: {'screen_name': 'home'});
      expect(box.length, equals(1));

      // Trigger app open check
      await service.checkAndSendOnAppOpen();

      // Data must remain in Hive because 1 hour has not elapsed yet
      expect(box.length, equals(1));
    });

    test('clearHiveData clears all local Hive analytics records', () async {
      final service = AnalyticsService.instance;
      final box = Hive.box(AnalyticsService.hiveBoxName);
      await box.clear();

      await service.track(AnalyticsEventName.gameStart, properties: {'game_id': 'zip_1'});
      expect(box.length, equals(1));

      await service.clearHiveData();
      expect(box.length, equals(0));
    });

    test('EventCron schedules 1-hour cron and periodic timer, then stops cleanly', () {
      final eventCron = EventCron();
      expect(() => eventCron.start(), returnsNormally);
      expect(() => eventCron.stop(), returnsNormally);
    });
  });
}


