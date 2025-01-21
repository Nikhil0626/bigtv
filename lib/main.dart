import 'package:chotanews/screens/language_selection_screen/language_selection_view.dart';
import 'package:chotanews/screens/splash_screen/splash_screen_view.dart';
import 'package:chotanews/screens/videos_main/tab_screen.dart';
import 'package:chotanews/utils/register_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'globel_keys/app_router.dart';
import 'globel_keys/globel_keys.dart';

void main() {
  runApp(const MyApp());
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
            home: TabScreen(),
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