import 'package:flutter/material.dart';
import 'analytics/analytics_service.dart';
import 'analytics/models/analytics_event_name.dart';
import 'services/app_wakelock_manager.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  DateTime? _backgroundedAt;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final a = AnalyticsService.instance;
    switch (state) {
      case AppLifecycleState.paused:
        _backgroundedAt = DateTime.now();
        AppWakelockManager.onAppPaused();
        a.track(AnalyticsEventName.appBackground);
        break;
      case AppLifecycleState.resumed:
        AppWakelockManager.onAppResumed();
        a.track(AnalyticsEventName.appForeground);
        final seconds = _backgroundedAt == null
            ? 0
            : DateTime.now().difference(_backgroundedAt!).inSeconds;
        a.track(AnalyticsEventName.appResume,
            properties: {'time_in_background_seconds': seconds});
        _backgroundedAt = null;
        a.checkAndSendOnAppOpen();
        break;
      case AppLifecycleState.detached:
        AppWakelockManager.releaseAll();
        a.endSession();
        break;
      default:
        break;
    }
  }
}
