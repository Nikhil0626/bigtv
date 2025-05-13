import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../screens/home_screen/home_repo/event_repo.dart';
import '../services/deviice_details.dart';
import '../services/webengage_notification.dart';

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
    }else if (state == AppLifecycleState.paused) {
      getUniqueDeviceId("close",);
      print('App is in the background.');

    } else if (state == AppLifecycleState.resumed) {
      print('App is in the foreground.');
    getNotifications();
    }
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

    // subscribeToPushCallbacks(webEngage);
  }
}