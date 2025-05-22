import 'dart:async';
import 'dart:developer';

import 'package:chotanews/services/analytics_service.dart';

import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/utils/app_life_cycle.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_install_referrer/flutter_install_referrer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:platform_device_id_plus/platform_device_id.dart';
import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import 'aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'aggricator_screens/e_papers_screens/paper_provider/epapers_provider.dart';
import 'aggricator_screens/home_screen/home_provider/home_provider.dart';
import 'aggricator_screens/home_screen/news_posts_provider.dart';
import 'aggricator_screens/individual_post_details/individual_post_view.dart';
import 'aggricator_screens/reels_screens/reels_provider/reels_providers.dart';
import 'aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import 'aggricator_screens/settings_screen/settings_view/settings_view.dart';
import 'aggricator_screens/splash_screen/splash_screen_view.dart';

final FacebookAppEvents facebookAppEvents = FacebookAppEvents();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initPlugin();
  getAndSendReferrerDetails();
  await EasyLocalization.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await facebookAppEvents.setAdvertiserTracking(enabled: true);
  checkForUpdate();
  unawaited(MobileAds.instance.initialize());
  await Firebase.initializeApp();
  // KochavaService.initKochava();
  AnalyticsService.logAppOpen();
  AnalyticsService().trackAppOpen();
  AnalyticsService.startSession();
  AnalyticsService.checkRetention();

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

  String postId = "";

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
        providers: [
          ChangeNotifierProvider<EPapersProvider>(create: (_) => EPapersProvider()),
          ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
          ChangeNotifierProvider<NewsPostsProvider>(create: (_) => NewsPostsProvider()),
          ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
          ChangeNotifierProvider<ReelsProviders>(create: (_) => ReelsProviders()),
          ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
          ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider()),
        ],
        child: MaterialApp(
          navigatorKey: mainNavigatorKey,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: const [Locale('te', '')],
          locale: _locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          initialRoute: '/',
          onGenerateInitialRoutes: (String routeName) {
            if (postId.isNotEmpty) {
              return [
                MaterialPageRoute(
                  builder: (_) => IndividualPostView(postId: postId),
                ),
              ];
            }
            return [
              MaterialPageRoute(builder: (_) => SplashScreen()),
            ];
          },
          routes: {
            '/individualPage': (context) => IndividualPostView(postId: postId),
            '/settings': (context) => SettingsView(),
            // Ensure the root route is defined (even if onGenerateInitialRoutes is used)
            // '/': (context) => SplashScreen(),
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

final GlobalKey<NavigatorState> mainNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<Object?>> routeObserver = RouteObserver<ModalRoute<Object?>>();
final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey();
