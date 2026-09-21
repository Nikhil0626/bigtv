import 'dart:async';

import 'package:chotanews/services/analytics_service.dart';
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
    await Hive.openBox('pollBox');
    EventCron().start();
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

  runApp(AppLifecycleManager(child: const MyApp()));

  // Run non-blocking background initialization tasks
  _initBackgroundServices();
}

void _initBackgroundServices() async {
  try {
    initPlugin();
    getReferrerFromPlayStore();
    checkForUpdate();

    AnalyticsService.logAppOpen();
    AnalyticsService().trackAppOpen();
    AnalyticsService.startSession();
    AnalyticsService.checkRetention();

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
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification opened app: ${message.data}");
      _handleBackgroundNotification(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("Initial FCM message on launch: ${message.data}");
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
