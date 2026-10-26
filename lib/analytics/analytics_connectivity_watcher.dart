import 'package:connectivity_plus/connectivity_plus.dart';
import 'analytics_service.dart';

class AnalyticsConnectivityWatcher {
  static void start() {
    Connectivity().onConnectivityChanged.listen((results) {
      final isConnected = results.any((result) => result != ConnectivityResult.none);
      if (isConnected) {
        AnalyticsService.instance.flush();
      }
    });
  }
}
