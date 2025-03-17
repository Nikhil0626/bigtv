import 'dart:developer';

import 'package:kochava_measurement/kochava_measurement.dart';

class KochavaService {
  static Future<void> initKochava() async {
    KochavaMeasurement.instance.registerAndroidAppGuid("kochota-news-mrl");
    KochavaMeasurement.instance.registerIosAppGuid("kochotanews-4zrr8u7az");
    KochavaMeasurement.instance.setLogLevel(KochavaMeasurementLogLevel.Trace);
    KochavaMeasurement.instance.start();

    String deviceId = await KochavaMeasurement.instance.retrieveInstallId();
    log("kochava device id $deviceId");
    KochavaMeasurement.instance.registerDefaultEventUserId(deviceId);

  }
}