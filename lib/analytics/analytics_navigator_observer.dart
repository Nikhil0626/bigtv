import 'package:flutter/material.dart';
import 'analytics_service.dart';
import 'models/analytics_event_name.dart';

class AnalyticsNavigatorObserver extends NavigatorObserver {
  String? _previousRoute;

  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    _track(route.settings.name, _previousRoute);
    _previousRoute = route.settings.name;
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
    _track(previousRoute?.settings.name, route.settings.name);
    if (route.settings.name != null) {
      AnalyticsService.instance.track(AnalyticsEventName.backNavigation, properties: {
        'from_screen': route.settings.name,
        'to_screen': previousRoute?.settings.name ?? 'unknown',
      });
    }
    _previousRoute = previousRoute?.settings.name;
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _track(newRoute?.settings.name, oldRoute?.settings.name);
    _previousRoute = newRoute?.settings.name;
  }

  void _track(String? screen, String? previous) {
    if (screen == null || screen.isEmpty) return;
    AnalyticsService.instance.track(AnalyticsEventName.screenView,
        properties: {'screen_name': screen, 'previous_screen': previous});
  }
}
