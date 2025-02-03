
import 'dart:developer';

import 'package:app_links/app_links.dart';
import 'package:chotanews/screens/home_screen/flip_way2news.dart';
import 'package:chotanews/utils/register_providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:webengage_flutter/webengage_flutter.dart';
import 'dart:io' show Platform;

import 'globel_keys/app_router.dart';
import 'globel_keys/global_variables_data.dart';
import 'globel_keys/globel_keys.dart';


Future<String?> getUniqueDeviceId() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    GlobalVariables().platForm = androidInfo.brand;
    log(androidInfo.toString());
    return androidInfo.id; // Returns a unique ID for Android devices
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    GlobalVariables().platForm = iosInfo.systemName;
    log(iosInfo.systemName);
    return iosInfo.identifierForVendor; // Returns a unique ID for iOS devices
  } else {
    return null; // Handle other platforms or return a default value
  }
}


void fetchDeviceId() async {
  String? deviceId = await getUniqueDeviceId();
  GlobalVariables().deviceId = deviceId; // Store in the global variable
  print("Device ID: ${GlobalVariables().deviceId}");
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  WebEngagePlugin.onPushMessageReceive(message.data);
}


Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp();
  final appLinks = AppLinks();

  appLinks.uriLinkStream.listen((uri) {
    log("app loimnks  --------- $uri");
  });

  // if (Platform.isAndroid) {
  //   try {
  //   } catch (e) {
  //     print("Firebase initialization error: $e");
  //   }
  // }
  fetchDeviceId();
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  print('APNs Token: $apnsToken');



  // var token = await FirebaseMessaging.instance.getToken();
  // if (token != null) {
  //   log("gksgojgoigspoas ${token}");
  //  WebEngagePlugin.setPushToken(token);
  //   WebEngagePlugin.userLogin('user123');
  //
  // }
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   WebEngagePlugin.onPushMessageReceive(message.data);
  //   log("gksgojgoigspoas ${message.data}");
  // });



  runApp(const MyApp());
  // String? uniqueId = await DeviceIdentifier.deviceId..toString();
  //
  // if (Platform.isAndroid) {
  //
  //   final deviceInfoPlugin = DeviceInfoPlugin();
  //   final deviceInfo = await deviceInfoPlugin.deviceInfo;
  //   final allInfo = deviceInfo.data;
  //
  //
  //   log('Running on ${allInfo}');
  //
  // }
  // else if (Platform.isIOS) {
  //   IosDeviceInfo data = await deviceInfo.iosInfo;
  //   Map body =<String, dynamic>{
  //     'name': data.name,
  //     'systemName': data.systemName,
  //     'systemVersion': data.systemVersion,
  //     'model': data.model,
  //     'modelName': data.modelName,
  //     'localizedModel': data.localizedModel,
  //     'identifierForVendor': data.identifierForVendor,
  //     'isPhysicalDevice': data.isPhysicalDevice,
  //     'isiOSAppOnMac': data.isiOSAppOnMac,
  //     'utsname.sysname:': data.utsname.sysname,
  //     'utsname.nodename:': data.utsname.nodename,
  //     'utsname.release:': data.utsname.release,
  //     'utsname.version:': data.utsname.version,
  //     'utsname.machine:': data.utsname.machine,
  //   };
  //   print('Running on ${body}');
  // }




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
        // home:  MyHomePage1(title: "",),
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