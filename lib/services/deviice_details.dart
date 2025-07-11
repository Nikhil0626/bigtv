import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id_plus/platform_device_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globel_keys/global_variables_data.dart';

Future<String?> getUniqueDeviceId(
  String token,
) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  String? deviceId = await PlatformDeviceId.getDeviceId;
  log("Device ID: $deviceId");

  log("app latest version ${packageInfo.toString()}");
  log("app latest version ${packageInfo.buildNumber}");

  String? storedVersion = sp.getString("app_version");
  log("app latest version $storedVersion");
  if ("${packageInfo.version}+${packageInfo.buildNumber}" != (sp.getString("app_version") ?? "")) {
    AnalyticsService.logEvent2("app_update");
    sp.setString("app_version", "${packageInfo.version}+${packageInfo.buildNumber}");
  }

  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    sp.setString("deviceId", deviceId.toString());
    if (token == "close") {
      return "";
    }
    GlobalVariables().platForm = androidInfo.brand;
    GlobalVariables().deviceId = androidInfo.id;

    if (sp.getString("deviceName").toString() != "true") {
      sendAndroidDeviceDetails(androidInfo);

      EventRepo().addEvent({
        "platform": Platform.isIOS ? "iOS" : "android",
        "createAt": DateTime.now().toString(),
      }, "first_open");
      EventRepo().addEvent(
        {
          "createAt": DateTime.now().toString(),
          "platform": Platform.isIOS ? "iOS" : "android",
          "device_id": androidInfo.id.toString(),
          "device_brand": androidInfo.brand.toString(),
          "device_model": androidInfo.model.toString(),
          "device_sdk": androidInfo.version.sdkInt.toString(),
        },
        "device_details",
      );
      sp.setString("deviceName", "true");
    }

    // return androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    sp.setString("deviceId", iosInfo.identifierForVendor.toString());
    if (token == "close") {
      return "";
    }

    log("iOS Details ---- $iosInfo");
    log("iOS Details ---- ${sp.getString("deviceName").toString()}");

    if (sp.getString("deviceName").toString() != "true") {
      sendiOSDeviceDetails(iosInfo);
      EventRepo().addEvent({
        "platform": Platform.isIOS ? "iOS" : "android",
        "createAt": DateTime.now().toString(),
      }, "first_open");
      EventRepo().addEvent(
        {
          "createAt": DateTime.now().toString(),
          "platform": Platform.isIOS ? "iOS" : "android",
          "device_id": iosInfo.identifierForVendor.toString(),
          "device_brand": "Apple",
          "device_model": iosInfo.modelName.toString(),
          "device_sdk": iosInfo.model.toString(),
          "device_os": "ios",
        },
        "device_details",
      );
      sp.setString("deviceName", "true");
    }
  } else {
    return null; // Handle other platforms or return a default value
  }
  return null;
}
