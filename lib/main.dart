import 'dart:developer';

import 'package:chotanews/screens/chota_info_screens/chota_info.dart';
import 'package:chotanews/screens/districts_selection/districts_selection_screen.dart';
import 'package:chotanews/utils/register_providers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io' show Platform;

import 'globel_keys/app_router.dart';
import 'globel_keys/globel_keys.dart';
import 'onbording_screens/onboarding_screen.dart';

void main() async{
  runApp(const MyApp());
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
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
      child: ScreenUtilInit(
        designSize: const Size(385, 890),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
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
            home: ChotaInfo(),
            debugShowCheckedModeBanner: false,
            // initialRoute: RoutesManager.onboardingScreen,
          );
        },
      ),
    );
  }
}




final mainNavigatorKey =
GlobalKey<NavigatorState>();
final RouteObserver<ModalRoute<Object?>> routeObserver =
RouteObserver<ModalRoute<Object?>>();
final GlobalKey<ScaffoldMessengerState> scaffoldKey = GlobalKey();