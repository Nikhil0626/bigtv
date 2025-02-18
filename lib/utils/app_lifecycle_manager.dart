import 'package:flutter/material.dart';

import '../main.dart';
import '../services/dynamic_link_service.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({super.key, required this.child});

  @override
  _AppLifecycleManagerState createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {

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
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        debugPrint("App is in inactive state");
        break;
      case AppLifecycleState.paused:
        debugPrint("App is in paused state");
        break;
      case AppLifecycleState.detached:
        debugPrint("App is in detached state");
        break;
      case AppLifecycleState.hidden:
        debugPrint("App is in hidden state");
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
