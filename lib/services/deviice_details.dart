import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:chotanews/services/permission_handler_services.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/services/analytics_service.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globel_keys/global_variables_data.dart';

Future<String?> getUniqueDeviceId(
  String token,
) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

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
    sp.setString("deviceId", androidInfo.id);
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

Future<Map<String, String>> getDeviceInfoData() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String osVersion = "";
  String deviceType = Platform.isIOS ? "ios" : "android";

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    osVersion = androidInfo.version.release;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    osVersion = iosInfo.systemVersion;
  }
  
  return {
    "app_version": "${packageInfo.version}+${packageInfo.buildNumber}",
    "os_version": osVersion,
    "device_type": deviceType,
  };
}

Future<void> logFullDeviceAndFcmDetails() async {
  try {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    SharedPreferences sp = await SharedPreferences.getInstance();

    String deviceId = sp.getString("deviceId") ?? "";
    String brand = "";
    String model = "";
    String osVersion = "";
    String deviceType = Platform.isIOS ? "ios" : "android";

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = deviceId.isNotEmpty ? deviceId : androidInfo.id;
      brand = androidInfo.brand;
      model = androidInfo.model;
      osVersion = "Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = deviceId.isNotEmpty ? deviceId : (iosInfo.identifierForVendor ?? "");
      brand = "Apple";
      model = iosInfo.modelName;
      osVersion = "iOS ${iosInfo.systemVersion}";
    }

    String? fcmToken = await getAppFcmToken();
    String? apnsToken;
    if (Platform.isIOS) {
      try {
        apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      } catch (_) {}
    }

    debugPrint("\n==================================================");
    debugPrint("📱 CONNECTED DEVICE & FCM DETAILS:");
    debugPrint("--------------------------------------------------");
    debugPrint("• Device ID     : $deviceId");
    debugPrint("• Device Type   : $deviceType");
    debugPrint("• Brand / Model : $brand $model");
    debugPrint("• OS Version    : $osVersion");
    debugPrint("• App Version   : ${packageInfo.version}+${packageInfo.buildNumber}");
    if (Platform.isIOS) {
      debugPrint("• Apple APNs Hex Token (for Apple Developer Portal):\n$apnsToken");
    }
    debugPrint("• Firebase FCM Token (for Firebase Console / Backend):\n$fcmToken");
    debugPrint("==================================================\n");
  } catch (e) {
    debugPrint("Error logging device details: $e");
  }
}
