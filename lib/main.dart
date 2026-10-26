import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:chotanews/services/analytics_service.dart' as legacy_analytics;
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/analytics_navigator_observer.dart';
import 'package:chotanews/analytics/analytics_connectivity_watcher.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/utils/local_data.dart';
import 'app_lifecycle_observer.dart';
import 'package:chotanews/services/event_cron.dart';
import 'package:chotanews/services/deviice_details.dart';
import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/services/register_provider.dart';
import 'package:chotanews/utils/app_life_cycle.dart';


import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';

import 'aggricator_screens/events_data/event_repo.dart';
import 'aggricator_screens/settings_screen/settings_view/settings_view.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'aggricator_screens/splash_screen/splash_screen_view.dart';
import 'globel_keys/globel_keys.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/home/presentation/widgets/html_notification_dialog.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await EventRepo().processAndPushEvents();
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  try {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);
    await Hive.openBox('events');
    await Hive.openBox('analytics_events');
    await Hive.openBox('pollBox');
  } catch (e) {
    debugPrint("Hive init error: $e");
  }

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    final platform = kIsWeb
        ? 'web'
        : Platform.isAndroid
            ? 'android'
            : Platform.isIOS
                ? 'ios'
                : 'web';

    final deviceId = await AnalyticsService.getStableDeviceId();
    final userIdStr = await getUserid();
    final userId = (userIdStr != null && userIdStr.isNotEmpty) ? int.tryParse(userIdStr) : null;

    await AnalyticsService.instance.init(
      deviceId: deviceId,
      platform: platform,
      userId: userId,
    );

    AnalyticsConnectivityWatcher.start();

    await AnalyticsService.instance.track(
      AnalyticsEventName.appOpen,
      properties: {'launch_type': 'cold'},
    );

    final prefs = await SharedPreferences.getInstance();
    final isFirstOpen = prefs.getBool('is_first_open_done') != true;
    if (isFirstOpen) {
      await AnalyticsService.instance.track(
        AnalyticsEventName.appFirstOpen,
        properties: {'install_source': 'organic'},
      );
      await AnalyticsService.instance.track(
        AnalyticsEventName.userFirstOpen,
        properties: {'install_source': 'organic'},
      );
      await prefs.setBool('is_first_open_done', true);
    } else {
      final lastOpenStr = prefs.getString('analytics_last_open_date');
      if (lastOpenStr != null) {
        final lastDate = DateTime.tryParse(lastOpenStr);
        if (lastDate != null) {
          final daysSince = DateTime.now().difference(lastDate).inDays;
          if (daysSince > 0) {
            await AnalyticsService.instance.track(
              AnalyticsEventName.userReturn,
              properties: {'days_since_last_open': daysSince},
            );
          }
        }
      }
    }
    await prefs.setString('analytics_last_open_date', DateTime.now().toIso8601String());

    final todayStr = DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final lastDaily = prefs.getString('analytics_last_daily_activity');
    if (lastDaily != todayStr) {
      await AnalyticsService.instance.track(
        AnalyticsEventName.appDailyActivity,
        properties: {'date': todayStr},
      );
      await AnalyticsService.instance.track(
        AnalyticsEventName.userActivitySummary,
        properties: {'date': todayStr, 'type': 'daily_summary'},
      );
      await prefs.setString('analytics_last_daily_activity', todayStr);
    }

    await AnalyticsService.instance.startSession();

    WidgetsBinding.instance.addObserver(AppLifecycleObserver());
    EventCron().start();
  } catch (e) {
    debugPrint("[Analytics] Init error in main: $e");
  }

  runApp(AppLifecycleManager(child: const MyApp()));

  // Run non-blocking background initialization tasks
  _initBackgroundServices();
}

void _initBackgroundServices() async {
  try {
    initPlugin();
    getReferrerFromPlayStore();
    checkForUpdate();

    legacy_analytics.AnalyticsService.logAppOpen();
    legacy_analytics.AnalyticsService().trackAppOpen();
    legacy_analytics.AnalyticsService.startSession();
    legacy_analytics.AnalyticsService.checkRetention();

    // Configure foreground notification options for iOS
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Request notification permissions
    FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Foreground FCM message received: ${message.data}");
      AnalyticsService.instance.track(AnalyticsEventName.notificationReceived, properties: {
        'notification_id': message.messageId,
        'campaign_id': message.data['campaign_id'],
        'notification_type': message.data['type'] ?? 'general',
      });
      _handleForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification opened app: ${message.data}");
      AnalyticsService.instance.track(AnalyticsEventName.notificationOpen, properties: {
        'notification_id': message.messageId,
        'campaign_id': message.data['campaign_id'],
        'destination': message.data['destination'] ?? 'home',
      });
      if (message.data['campaign_id'] != null) {
        AnalyticsService.instance.track(AnalyticsEventName.campaignEntry, properties: {
          'campaign_id': message.data['campaign_id'],
          'source': 'push_notification',
        });
      }
      _handleBackgroundNotification(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("Initial FCM message on launch: ${message.data}");
        AnalyticsService.instance.track(AnalyticsEventName.notificationOpen, properties: {
          'notification_id': message.messageId,
          'campaign_id': message.data['campaign_id'],
          'destination': message.data['destination'] ?? 'home',
        });
        if (message.data['campaign_id'] != null) {
          AnalyticsService.instance.track(AnalyticsEventName.campaignEntry, properties: {
            'campaign_id': message.data['campaign_id'],
            'source': 'push_notification',
          });
        }
        _handleBackgroundNotification(message.data);
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      debugPrint("FCM token refreshed: $newToken");
      getUniqueDeviceId(newToken);
    });

    try {
      final appLinks = AppLinks();
      appLinks.getInitialLink().then((uri) {
        if (uri != null) {
          debugPrint("AppLinks initial link: $uri");
          _handleBackgroundDeepLink(uri);
        }
      });
      appLinks.uriLinkStream.listen((uri) {
        debugPrint("AppLinks stream link: $uri");
        _handleBackgroundDeepLink(uri);
      });
    } catch (e) {
      debugPrint("Error initializing AppLinks in main: $e");
    }

    logFullDeviceAndFcmDetails();
  } catch (e) {
    debugPrint("Error in background services initialization: $e");
  }
}

void _handleForegroundNotification(RemoteMessage message) {
  final Map<String, dynamic> payload = Map<String, dynamic>.from(message.data);
  if (message.notification != null) {
    if (message.notification!.title != null) {
      payload['title'] ??= message.notification!.title;
    }
    if (message.notification!.body != null) {
      payload['body'] ??= message.notification!.body;
      payload['content'] ??= message.notification!.body;
    }
    if (message.notification!.android?.imageUrl != null) {
      payload['imageUrl'] ??= message.notification!.android!.imageUrl;
    }
    if (message.notification!.apple?.imageUrl != null) {
      payload['imageUrl'] ??= message.notification!.apple!.imageUrl;
    }
  }

  final String? content = payload['content'] ??
      payload['html_content'] ??
      payload['html'] ??
      payload['message'] ??
      payload['body'];

  if (content != null && content.isNotEmpty && (content.contains('<') && content.contains('>'))) {
    showHtmlNotificationDialog(
      content: content,
      title: payload['title']?.toString(),
      imageUrl: payload['image']?.toString() ?? payload['imageUrl']?.toString() ?? payload['image_url']?.toString(),
      ctaUrl: payload['deepLink'] ?? payload['deeplink'] ?? payload['url'] ?? payload['link'],
      rawPayload: payload,
    );
  } else if (mainNavigatorKey.currentContext != null) {
    mainNavigatorKey.currentContext!.read<HomeProvider>().handleNotificationTap(payload);
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Background FCM message received: ${message.data}");
}

Map<String, dynamic>? pendingPushPayload;
String? pendingDeepLink;

void _handleBackgroundNotification(Map<String, dynamic>? payload, {String? deepLink}) {
  if (mainNavigatorKey.currentContext != null) {
    mainNavigatorKey.currentContext!.read<HomeProvider>().handleNotificationTap(payload, deepLink: deepLink);
  } else {
    pendingPushPayload = payload ?? {};
    pendingDeepLink = deepLink;
  }
}

void _handleBackgroundDeepLink(Uri uri) {
  AnalyticsService.instance.track(AnalyticsEventName.deepLinkOpen, properties: {
    'destination': uri.path,
    'source': uri.queryParameters['source'] ?? 'deep_link',
    'url': uri.toString(),
  });
  if (uri.queryParameters.containsKey('campaign_id') ||
      uri.queryParameters.containsKey('utm_campaign') ||
      uri.queryParameters.containsKey('campaign')) {
    AnalyticsService.instance.track(AnalyticsEventName.campaignEntry, properties: {
      'campaign_id': uri.queryParameters['campaign_id'] ??
          uri.queryParameters['utm_campaign'] ??
          uri.queryParameters['campaign'],
      'source': uri.queryParameters['utm_source'] ?? 'deep_link',
    });
  }
  if (mainNavigatorKey.currentContext != null) {
    mainNavigatorKey.currentContext!.read<HomeProvider>().routeDeepLink(uri);
  } else {
    pendingDeepLink = uri.toString();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Adjust to your design
      child: MultiProvider(
        providers: AppProviders.all,
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return MaterialApp(
              navigatorKey: mainNavigatorKey,
              navigatorObservers: [AnalyticsNavigatorObserver()],

              // supportedLocales: const [Locale('te', '')],
              // // Add your locales
              // locale: _locale,
              themeMode: themeProvider.themeMode,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              routes: {
                '/': (context) => SplashScreen(),
                '/settings': (context) => SettingsView(),
              },
              debugShowCheckedModeBanner: false,
            );
          },
        ),
      ),
    );
  }
}
