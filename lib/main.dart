
import 'dart:developer';

import 'package:chotanews/screens/Auth_module/auth_provider/auth_provider.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/services/dynamic_link_service.dart';
import 'package:chotanews/services/kochava_service.dart';
import 'package:chotanews/services/webengage_notification.dart';
import 'package:chotanews/utils/app_life_cycle.dart';
import 'package:chotanews/utils/register_providers.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import 'globel_keys/app_router.dart';
import 'globel_keys/globel_keys.dart';
final FacebookAppEvents facebookAppEvents = FacebookAppEvents();
Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar
    statusBarIconBrightness: Brightness.dark, // Dark icons (black)
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

  // Check if you received the link via `getInitialLink` first
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
    runApp(AppLifecycleManager(child: const MyApp()));
  });
  subscribeToPushCallbacks(_webEngagePlugin);
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WebEngagePlugin.onPushMessageReceive(message.data);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FacebookAppEvents facebookAppEvents = FacebookAppEvents();
  @override
  void initState() {
    appEventLogs();
    super.initState();
  }
  void appEventLogs() async{
    try{
      facebookAppEvents.logEvent(
        name: 'flutter_test',
        parameters: {
          'name': 'siva',
          'time': 123,  // You can pass int, double, String
        },
      );
      log("facebook event success");
    }catch(e){
      log("facebook event fail");
    }

  }
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), // Set according to your design
      // minTextAdapt: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<FlipProvider>(
              create: (context) => FlipProvider()),
          ChangeNotifierProvider<AuthProvider>(
              create: (context) => AuthProvider()),
        ],
        child: MultiBlocProvider(
          providers: RegisterProviders.providers(context),
          child: MaterialApp(
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            scrollBehavior: MyBehavior(),
            navigatorKey: mainNavigatorKey,
            navigatorObservers: [routeObserver],
            onGenerateRoute: (RouteSettings setting) {
              return RoutesManager.generateRoute(setting);
            },
            builder: (
                BuildContext context,
                Widget? child,
                ) {
              return child!;
            },
            // home: OnboardingScreen1(),
          ),
        ),
      ),
    );
  }
}

final mainNavigatorKey = GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<Object?>> routeObserver =
RouteObserver<ModalRoute<Object?>>();
final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey();