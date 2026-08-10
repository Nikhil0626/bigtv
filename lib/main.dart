import 'dart:async';
import 'dart:ui';

import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/services/event_cron.dart';

import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/services/register_provider.dart';
import 'package:chotanews/utils/app_life_cycle.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
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

  // Catch disposed webview channel calls silently
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exception is MissingPluginException ||
        details.exception.toString().contains('flutter_inappwebview') ||
        details.exception.toString().contains('evaluateJavascript')) {
      return;
    }
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    if (error is MissingPluginException ||
        error.toString().contains('flutter_inappwebview') ||
        error.toString().contains('evaluateJavascript')) {
      return true;
    }
    return false;
  };

  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('events');
  await Hive.openBox('pollBox');
  EventCron().start();
  initPlugin();
  getReferrerFromPlayStore();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  checkForUpdate();
  await Firebase.initializeApp();
  AnalyticsService.logAppOpen();
  AnalyticsService().trackAppOpen();
  AnalyticsService.startSession();
  AnalyticsService.checkRetention();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    WebEngagePlugin.onPushMessageReceive(message.data);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleBackgroundNotification(message.data);
  });

  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      _handleBackgroundNotification(message.data);
    }
  });

  WebEngagePlugin().pushStream.listen((event) {
    if (event.payload != null) {
      _handleBackgroundNotification(event.payload!);
    }
  });

  WebEngagePlugin().pushActionStream.listen((event) {
    if (event.payload != null) {
      _handleBackgroundNotification(event.payload!);
    }
  });

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(EasyLocalization(
        supportedLocales: [
          Locale('te'),
        ],
        path: 'assets/translations',
        fallbackLocale: Locale("te"),
        child: AppLifecycleManager(child: MyApp())));
  });
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  WebEngagePlugin.onPushMessageReceive(message.data);
}

Map<String, dynamic>? pendingPushPayload;

void _handleBackgroundNotification(Map<String, dynamic> payload) {
  if (mainNavigatorKey.currentContext != null) {
    mainNavigatorKey.currentContext!.read<HomeProvider>().handleNotificationTap(payload);
  } else {
    pendingPushPayload = payload;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
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
            final isDark = themeProvider.themeMode == ThemeMode.dark ||
                (themeProvider.themeMode == ThemeMode.system &&
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark);
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                // Light icons (white) in dark mode, dark icons (black) in light mode
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness:
                    isDark ? Brightness.dark : Brightness.light,
              ),
              child: MaterialApp(
                navigatorKey: mainNavigatorKey,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: const [Locale('te', '')],
                locale: _locale,
                themeMode: themeProvider.themeMode,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                routes: {
                  '/': (context) => SplashScreen(),
                  '/settings': (context) => SettingsView(),
                },
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
