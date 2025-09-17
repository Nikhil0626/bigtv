import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../aggricator_screens/ad_manager_screen/ad_provider/ad_mob_banner_provider.dart';
import '../aggricator_screens/home_screen/home_provider/home_provider.dart';
import '../globel_keys/globel_keys.dart';
import '../main.dart';
import '../services/deviice_details.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  AppLifecycleManager({required this.child});

  @override
  _AppLifecycleManagerState createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {
  final WebEngagePlugin webEngage = WebEngagePlugin();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive) {
      // disposePushCallbacks();
      print('Notification shade may have been opened');
    }
    // else if (state == AppLifecycleState.paused) {
    //   getUniqueDeviceId("close",);
    //   print('App is in the background.');
    //   Provider.of<AdMobBannerProvider>(mainNavigatorKey.currentContext!, listen: false).cronClose();
    //
    // }
    // else if (state == AppLifecycleState.resumed) {
    //   print('App is in the foreground.');
    //   Provider.of<AdMobBannerProvider>(mainNavigatorKey.currentContext!, listen: false).autoBannerCall();
    //   // if( mainNavigatorKey.currentContext!.read<HomeProvider>().postId.toString() != "0" ) {
    //   //   log("getIndividualPost in life cycle ${mainNavigatorKey.currentContext!.read<HomeProvider>().postId.toString() }");
    //   //   mainNavigatorKey.currentContext?.read<HomeProvider>().getIndividualPost( mainNavigatorKey.currentContext!.read<HomeProvider>().postId.toString());
    //   // }else{
    //   //   log("getIndividualPost in home ${mainNavigatorKey.currentContext!.read<HomeProvider>().postId.toString() }");
    //   //   mainNavigatorKey.currentContext?.read<HomeProvider>().getAllPost();
    //   //
    //   // }
    // // getNotifications();
    // }
    if (state == AppLifecycleState.detached) {
      print('app_removes');
      FirebaseAnalytics.instance.logEvent(name: "app_remove");
    }

  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void getNotifications() async{
    // subscribeToPushCallbacks();
  }
}