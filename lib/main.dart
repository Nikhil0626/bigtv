import 'dart:async';

import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/services/event_cron.dart';

import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/services/register_provider.dart';
import 'package:chotanews/utils/app_life_cycle.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'aggricator_screens/ad_manager_screen/ad_provider/banner_ads_provider.dart';
import 'aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'aggricator_screens/e_papers_screens/paper_provider/epapers_provider.dart';
import 'aggricator_screens/events_data/event_repo.dart';
import 'aggricator_screens/home_screen/home_provider/home_provider.dart';
import 'aggricator_screens/home_screen/home_provider/news_posts_provider.dart';
import 'aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import 'aggricator_screens/reels_screens/reels_provider/reels_providers.dart';
import 'aggricator_screens/referral_screen/referral_provider/referral_provider.dart';
import 'aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import 'aggricator_screens/settings_screen/settings_view/settings_view.dart';
import 'aggricator_screens/splash_screen/splash_screen_view.dart';
import 'globel_keys/globel_keys.dart';

final FacebookAppEvents facebookAppEvents = FacebookAppEvents();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await EventRepo().processAndPushEvents();
    return Future.value(true);
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocumentDir.path);
  await Hive.openBox('events');
  EventCron().start();
  MobileAds.instance.initialize();
  initPlugin();
  getReferrerFromPlayStore();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await facebookAppEvents.setAdvertiserTracking(enabled: true);
  checkForUpdate();
  unawaited(MobileAds.instance.initialize());
  await Firebase.initializeApp();
  AnalyticsService.logAppOpen();
  AnalyticsService().trackAppOpen();
  AnalyticsService.startSession();
  AnalyticsService.checkRetention();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    WebEngagePlugin.onPushMessageReceive(message.data);

    print(message.data);
    print("push data receive   &&& ${message.data}");
  });

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(EasyLocalization(supportedLocales: [
      Locale('te'),
    ], path: 'assets/translations', fallbackLocale: Locale("te"), child: AppLifecycleManager(child: MyApp())));
  });
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  WebEngagePlugin.onPushMessageReceive(message.data);
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
  final FacebookAppEvents facebookAppEvents = FacebookAppEvents();

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
        providers:  AppProviders.all,
        child: MaterialApp(
          navigatorKey: mainNavigatorKey,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: const [Locale('te', '')],
          // Add your locales
          locale: _locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routes: {
            '/': (context) => SplashScreen(),
            '/settings': (context) => SettingsView(),
          },

          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}


