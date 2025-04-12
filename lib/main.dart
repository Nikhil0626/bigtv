import 'dart:async';
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:chotanews/aggricator_screens/auth_screens/authentication_view/login_background_view.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_view.dart';
import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/screens/chota_info_screens/chota_info.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/screens/profile_screen/profile_screen.dart';
import 'package:chotanews/screens/splash_screen/splash_screen_view.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/services/dynamic_link_service.dart';
import 'package:chotanews/services/kochava_service.dart';
import 'package:chotanews/services/webengage_notification.dart';
import 'package:chotanews/utils/app_life_cycle.dart';
import 'package:chotanews/utils/register_providers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import 'aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import 'aggricator_screens/e_papers_screens/paper_provider/epapers_provider.dart';
import 'aggricator_screens/home_screen/home_provider.dart';
import 'aggricator_screens/home_screen/news_posts_provider.dart';
import 'aggricator_screens/individual_post_details/individual_post_view.dart';
import 'aggricator_screens/reels_screens/reels_provider/reels_providers.dart';
import 'aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'aggricator_screens/settings_screen/settings_view/settings_view.dart';
import 'globel_keys/app_router.dart';
import 'globel_keys/globel_keys.dart';

final FacebookAppEvents facebookAppEvents = FacebookAppEvents();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  await facebookAppEvents.setAdvertiserTracking(enabled: true);
  WebEngagePlugin _webEngagePlugin = WebEngagePlugin();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  KochavaService.initKochava();

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

  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  if (initialLink != null) {
    final Uri deepLink = initialLink.link;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mainNavigatorKey.currentContext != null) {
        DynamicLinkService.handleDeepLink(
            mainNavigatorKey.currentContext!, deepLink);
      }
    });
  }

  FirebaseDynamicLinks.instance.onLink.listen(
    (pendingDynamicLinkData) {
      if (pendingDynamicLinkData != null) {
        final Uri deepLink = pendingDynamicLinkData.link;
        DynamicLinkService.handleDeepLink(
            mainNavigatorKey.currentContext!, deepLink);
      }
    },
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(EasyLocalization(
        supportedLocales: [
          Locale('en'),
          Locale('te'),
          Locale('hi'),
        ],
        path: 'assets/translations',
        fallbackLocale: Locale("en"),
        child: AppLifecycleManager(child: MyApp())));
  });
  subscribeToPushCallbacks(_webEngagePlugin);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
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
    log("Initializing deep link listener");
    linkSubscription = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        log("Deep link received: ${uri.toString()}");
        _handleDeepLink(uri);
      }
    }, onError: (err) {
      log("Error in deep link handling: $err");
    });
  }

  void _handleDeepLink(Uri uri) {
    final String path = uri.path;
    final String? id = uri.queryParameters['id'];
    log("Path: $path, ID: $id");

    switch (path) {
      case '/settings':
        log("Navigating to Settings screen");
        mainNavigatorKey.currentState?.pushNamed('/settings');
        break;
      case '/individualPost':

        postId = id ?? "";
        log("Navigating to Individual Post screen  $postId");
        mainNavigatorKey.currentState?.pushNamed(
          '/individualPost',
          arguments: {'postId': postId},
        );
        break;
      case '/profile':
        log("Navigating to Profile screen");
        mainNavigatorKey.currentState?.pushNamed(
          '/profile',
          arguments: {'userId': id},
        );
        break;
      default:
        log("Navigating to Home screen");
        mainNavigatorKey.currentState?.pushNamed('/');
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
          ChangeNotifierProvider<FlipProvider>(create: (context) => FlipProvider()),
          ChangeNotifierProvider<EPapersProvider>(create: (context) => EPapersProvider()),
          ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider()),
          ChangeNotifierProvider<HomeProvider>(create: (context) => HomeProvider()),

          ChangeNotifierProvider<NewsPostsProvider>(create: (context) => NewsPostsProvider()),
          ChangeNotifierProvider<AuthenticationProvider>(
              create: (context) => AuthenticationProvider()),
          ChangeNotifierProvider<ReelsProviders>(create: (context) => ReelsProviders()),
          ChangeNotifierProvider<SettingsProvider>(create: (context) => SettingsProvider()),
        ],
        child: MaterialApp(
          navigatorKey: mainNavigatorKey,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: const [Locale('en', ''), Locale('es', '')], // Add your locales
          locale: _locale,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routes: {
            '/': (context) => LoginBackgroundView(),
            '/individualPost': (context) => IndividualPostView(postId: postId,),
            '/settings': (context) => SettingsView(),
            // Add other routes like '/settings', '/profile', etc.
          },
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}



final mainNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<Object?>> routeObserver =
    RouteObserver<ModalRoute<Object?>>();
final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey();
