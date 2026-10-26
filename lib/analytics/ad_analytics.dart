import 'analytics_service.dart';
import 'models/analytics_event_name.dart';

/// Helper for tracking advertising events compliant with the Flutter Analytics specification.
class AdAnalytics {
  AdAnalytics._();

  /// Emitted when an ad request is initiated.
  static Future<void> trackRequest({
    required String adUnitId,
    String adFormat = 'banner',
    String? placement,
  }) async {
    await AnalyticsService.instance.track(AnalyticsEventName.adRequest, properties: {
      'ad_unit_id': adUnitId,
      'ad_format': adFormat,
      if (placement != null) 'placement': placement,
    });
  }

  /// Emitted when an ad is loaded by the SDK.
  static Future<void> trackLoaded({
    required String adUnitId,
    String adFormat = 'banner',
    String? placement,
    int? loadDurationMs,
  }) async {
    await AnalyticsService.instance.track(AnalyticsEventName.adLoaded, properties: {
      'ad_unit_id': adUnitId,
      'ad_format': adFormat,
      if (placement != null) 'placement': placement,
      if (loadDurationMs != null) 'load_duration_ms': loadDurationMs,
    });
  }

  /// Emitted when the ad impression is recorded (only after SDK confirms impression, not on load).
  static Future<void> trackImpression({
    required String adUnitId,
    String adFormat = 'banner',
    String? placement,
  }) async {
    await AnalyticsService.instance.track(AnalyticsEventName.adImpression, properties: {
      'ad_unit_id': adUnitId,
      'ad_format': adFormat,
      if (placement != null) 'placement': placement,
    });
  }

  /// Emitted when the user clicks on an ad.
  static Future<void> trackClicked({
    required String adUnitId,
    String adFormat = 'banner',
    String? placement,
  }) async {
    await AnalyticsService.instance.track(AnalyticsEventName.adClicked, properties: {
      'ad_unit_id': adUnitId,
      'ad_format': adFormat,
      if (placement != null) 'placement': placement,
    });
  }

  /// Emitted when ad loading fails.
  static Future<void> trackLoadFailed({
    required String adUnitId,
    String adFormat = 'banner',
    String? placement,
    required String errorCode,
  }) async {
    await AnalyticsService.instance.track(AnalyticsEventName.adLoadFailed, properties: {
      'ad_unit_id': adUnitId,
      'ad_format': adFormat,
      if (placement != null) 'placement': placement,
      'error_code': errorCode,
    });
  }

  /// Emitted when an interstitial / rewarded ad is dismissed.
  static Future<void> trackDismissed({
    required String adUnitId,
    String adFormat = 'interstitial',
    String? placement,
  }) async {
    await AnalyticsService.instance.track(AnalyticsEventName.adDismissed, properties: {
      'ad_unit_id': adUnitId,
      'ad_format': adFormat,
      if (placement != null) 'placement': placement,
    });
  }
}
