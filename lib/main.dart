import 'dart:developer';

import 'package:chotanews/screens/flip_page/articals_bloc.dart';
import 'package:chotanews/screens/flip_page/article_bloc_provider.dart';
import 'package:chotanews/screens/flip_page/test_one.dart';
import 'package:chotanews/screens/home_screen/home_repo.dart';
import 'package:chotanews/screens/testing_screen/test4.dart';
import 'package:chotanews/services/dynamic_link_service.dart';
import 'package:chotanews/utils/register_providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import 'dart:io' show Platform;

import 'globel_keys/app_router.dart';
import 'globel_keys/global_variables_data.dart';
import 'globel_keys/globel_keys.dart';


Future<String?> getUniqueDeviceId(String token) async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    GlobalVariables().platForm = androidInfo.brand;

    // AuthRepo().addDeviceDetails({
    //   "deviceId": androidInfo.id,
    //   "deviceType": "1",
    //   "fcmKey": token,
    //   "brand": androidInfo.brand
    // });
    return androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    GlobalVariables().platForm = iosInfo.systemName;

    // AuthRepo().addDeviceDetails({
    //   "deviceId": iosInfo.identifierForVendor,
    //   "deviceType": "1",
    //   "fcmKey": token,
    //   "brand": iosInfo.systemName
    // });
    return iosInfo.identifierForVendor; // Returns a unique ID for iOS devices
  } else {
    return null; // Handle other platforms or return a default value
  }
}


void fetchDeviceId(String token) async {
  String? deviceId = await getUniqueDeviceId(token);
  GlobalVariables().deviceId = deviceId;

  print("Device ID: ${GlobalVariables().deviceId}");

}





Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  WebEngagePlugin _webEngagePlugin = new WebEngagePlugin();

  if(Platform.isIOS){
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    log('APNs Token: $apnsToken');
    fetchDeviceId("");
  }
if(Platform.isAndroid){
  // await WebEngagePlugin.userLogout();
  var token = await FirebaseMessaging.instance.getToken();
  if (token != null) {

    fetchDeviceId(token);
    _webEngagePlugin = new WebEngagePlugin();
    _webEngagePlugin.tokenInvalidatedCallback(_onTokenInvalidated);

     WebEngagePlugin.setPushToken(token);
    // await WebEngagePlugin.userLogin('63860');
    // await WebEngagePlugin.setUserEmail('jogisivakumar.eee@gmail.com');
    // await WebEngagePlugin.trackScreen('Home_Page');
    // WebEngagePlugin.setUserOptIn('in_app', true);
    // WebEngagePlugin.setUserOptIn('sms', true);
    // WebEngagePlugin.setUserOptIn('push', true);
    // WebEngagePlugin.setUserOptIn('email', true);
    // WebEngagePlugin.setUserOptIn('whatsapp', true);
    // WebEngagePlugin.setUserOptIn('viber', true);
    // await WebEngagePlugin.trackScreen('Product Page', {'Product Id': 'UHUH799'});

    // WebEngagePlugin.trackEvent('opened_app', {
    //   'platform': "android"
    // });
    // WebEngagePlugin.trackEvent("hello_siva_test",{
    //   "userName":"Siva",
    //   "mobileNumber":"9951755530",
    //
    // });
    //
    // WebEngagePlugin.trackEvent("Email Address",{
    //   "userName":"siva143145@gmail.com",
    //   "mobileNumber":"9951755530",
    //
    // });
  }
}

  // WENotificationInbox().init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    WebEngagePlugin.onPushMessageReceive(message.data);
  });
  runApp(const MyApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WebEngagePlugin.onPushMessageReceive(message.data);
}

void _onTokenInvalidated(Map<String, dynamic>? message) {
  print("tokenInvalidated callback received $message");
  // Reset with new Security Token in the callback
  WebEngagePlugin.setSecureToken("siva kumar", message.toString());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: RegisterProviders.providers(context),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme:
          ColorScheme.fromSeed(seedColor: Colors.blue),
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
          // ScreenUtil.init(context, designSize: const Size(385, 890));
          return child!;
        },
        // builder: (BuildContext context, Widget? child) {
        //   ScreenUtil.init(context, designSize: const Size(385, 890));
        //   return MediaQuery(
        //     data: MediaQuery.of(context)
        //         .copyWith(textScaler: const TextScaler.linear(1)),
        //     child: child!,
        //   );
        // },
        // home: DownloadApp(),
        debugShowCheckedModeBanner: false,
        // initialRoute: RoutesManager.onboardingScreen,
      ),
    );
  }
}




final mainNavigatorKey =
GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<Object?>> routeObserver =
RouteObserver<ModalRoute<Object?>>();
final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey();