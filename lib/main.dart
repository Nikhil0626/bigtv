import 'dart:developer';

import 'package:chotanews/screens/districts_selection/districts_selection_screen.dart';
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
  fetchDeviceId();
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
  // log('APNs Token: $apnsToken');



  var token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    log("FCM token $token");
    WebEngagePlugin.setPushToken(token);
    WebEngagePlugin.userLogin('3254');



  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    WebEngagePlugin.onPushMessageReceive(message.data);
  });

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
        theme:ThemeData(
          primaryColor: Colors.lightBlue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange.shade300),
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

        home:  DistrictsSelectionScreen(className: "hgh"),
        debugShowCheckedModeBanner: false,
        // debugShowMaterialGrid: true,
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