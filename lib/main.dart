import 'dart:developer';

import 'package:chotanews/screens/Auth_module/auth_repo.dart';
import 'package:chotanews/screens/Auth_module/auth_screen.dart';
import 'package:chotanews/screens/testing_screen/test4.dart';
import 'package:chotanews/utils/register_providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
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
    log(androidInfo.toString());

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
    log(iosInfo.toString());

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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WebEngagePlugin.onPushMessageReceive(message.data);
}


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  if(Platform.isIOS){
    String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    log('APNs Token: $apnsToken');
    fetchDeviceId("");
  }
if(Platform.isAndroid){
  var token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    fetchDeviceId(token);
    WebEngagePlugin.setPushToken(token);
    WebEngagePlugin.userLogin('63855');
  }
}
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    WebEngagePlugin.onPushMessageReceive(message.data);
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: RegisterProviders.providers(context),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme:
          ColorScheme.fromSeed(seedColor: Colors.orange.shade300),
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
          ScreenUtil.init(context, designSize: const Size(385, 890));
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
        // home:  LoginScreen(),
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