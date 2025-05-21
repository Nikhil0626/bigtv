import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:app_links/app_links.dart';

import 'package:chotanews/services/analytics_service.dart';

import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/services/webengage_notification.dart';
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

// import 'package:install_referrer/install_referrer.dart';
import 'package:platform_device_id_plus/platform_device_id.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import 'aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'aggricator_screens/e_papers_screens/paper_provider/epapers_provider.dart';
import 'aggricator_screens/event_repo.dart';
import 'aggricator_screens/home_screen/home_provider.dart';
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
  checkForUpdate();
  getAndSendReferrerDetails();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await facebookAppEvents.setAdvertiserTracking(enabled: true);

  String? deviceId = await PlatformDeviceId.getDeviceId;
  checkForUpdate();
  log("Device ID: $deviceId");
  // MobileAds.instance.updateRequestConfiguration(
  //   RequestConfiguration(testDeviceIds: [deviceId??""]),
  // );
  unawaited(MobileAds.instance.initialize());
  await Firebase.initializeApp();
  // KochavaService.initKochava();

  /// app Events firebase
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

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> getAndSendReferrerDetails() async {
  try {
    final referrerDetails = await InstallReferrer.app;

    final String packageName = referrerDetails.packageName ?? 'unknown';
    final String platform = referrerToReadableString(referrerDetails.referrer);
    final String referrer = referrerDetails.referrer.toString();
    final String clickTimestamp = DateTime.now().toString() ?? '0';
    final String installTimestamp = DateTime.now().add(Duration(minutes: 10)).toString() ?? '0';

    log("Install_referrer   ${{
      'package_name': packageName,
      'platform': platform,
      'referrer_enum': referrer,
      'click_timestamp': clickTimestamp,
      'install_timestamp': installTimestamp,
    }}");
    // await analytics.logEvent(
    //   name: 'Install_referrer',
    //   parameters: {
    //     'package_name': packageName,
    //     'platform': platform,
    //     'referrer_enum': referrer,
    //     'click_timestamp': clickTimestamp,
    //     'install_timestamp': installTimestamp,
    //   },
    // );

    print('Referrer data sent to Firebase Analytics');
  } catch (e) {
    print('Failed to get or send install referrer: $e');
  }
}

String referrerToReadableString(InstallationAppReferrer referrer) {
  switch (referrer) {
    case InstallationAppReferrer.iosAppStore:
      return "Apple - App Store";
    case InstallationAppReferrer.iosTestFlight:
      return "Apple - Test Flight";
    case InstallationAppReferrer.iosDebug:
      return "Apple - Debug";
    case InstallationAppReferrer.androidGooglePlay:
      return "Android - Google Play";
    case InstallationAppReferrer.androidAmazonAppStore:
      return "Android - Amazon App Store";
    case InstallationAppReferrer.androidHuaweiAppGallery:
      return "Android - Huawei App Gallery";
    case InstallationAppReferrer.androidOppoAppMarket:
      return "Android - Oppo App Market";
    case InstallationAppReferrer.androidSamsungAppShop:
      return "Android - Samsung App Shop";
    case InstallationAppReferrer.androidVivoAppStore:
      return "Android - Vivo App Store";
    case InstallationAppReferrer.androidXiaomiAppStore:
      return "Android - Xiaomi App Store";
    case InstallationAppReferrer.androidManually:
      return "Android - Manual installation";
    case InstallationAppReferrer.androidDebug:
      return "Android - Debug";
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
  final FacebookAppEvents facebookAppEvents = FacebookAppEvents();
  final AppLinks _appLinks = AppLinks();
  Locale? _locale;
  StreamSubscription<Uri>? linkSubscription;
  String postId = "";


  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    try {
      final initialUri = await _appLinks.getInitialLink(); // Use the same _appLinks
      if (initialUri != null) {
        debugPrint('Initial URI: $initialUri');
        _handleDeepLink(initialUri);
      }
    } catch (err) {
      debugPrint('Failed to get initial URI: $err');
    }

    log("Initializing deep link listener");
    linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        log("Deep link received: ${uri.toString()}");
        final String? id = uri.queryParameters['postId'];
        if (id != null) {
          sp.setString("webPostId", id);
        }
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      log("Error in deep link handling: $err");
    });
  }

  void _handleDeepLink(Uri uri) async {
    log("Deep link path: $uri");
    SharedPreferences sp = await SharedPreferences.getInstance();
    final String path = uri.path;
    final String? id = uri.queryParameters['postId'];

    EventRepo().sendEvent({
      "key": "dynamic_link_app_open",
      "data": {
        "device_id": sp.getString("deviceId") ?? "1234",
        "userId": sp.getString('userId') ?? "",
        "postId": id ?? "",
      }
    });

    switch (path) {
      case '/settings':
        log("Navigating to Settings screen");
        mainNavigatorKey.currentState?.pushNamed('/settings');
        break;
      case '/individualPage':
        if (id != null) {
          postId = id;
          log("Navigating to Individual Post screen with postId: $postId");
          await Future.delayed(const Duration(seconds: 1), () {
            mainNavigatorKey.currentState?.pushNamed(
              '/individualPage',
              arguments: {'postId': postId},
            );
          });
        } else {
          log("postId is missing for /individualPage route.");
        }
        return;
      case '/profile':
        log("Navigating to Profile screen");
        mainNavigatorKey.currentState?.pushNamed(
          '/profile',
          arguments: {'userId': id},
        );
        break;
      default:
        log("Unrecognized path: $path — Navigating to Home screen (optional)");
    // Optionally push home here if needed:
    // mainNavigatorKey.currentState?.pushNamed('/');
    }
  }




  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void dispose() {
    linkSubscription?.cancel();
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
          // use it only ONCE
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

