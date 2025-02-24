import 'dart:developer';
import 'dart:io';

import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../globel_keys/global_variables_data.dart';

Future<String?> getUniqueDeviceId(String token) async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    GlobalVariables().platForm = androidInfo.brand;
    GlobalVariables().deviceId = androidInfo.id;
    log("Android Details ---- ${androidInfo}");
    sendAndroidDeviceDetails( androidInfo);
    // return androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    GlobalVariables().platForm = iosInfo.systemName;
    GlobalVariables().deviceId = iosInfo.identifierForVendor;
    log("iOS Details ---- ${iosInfo}");
    sendiOSDeviceDetails(iosInfo);
    // return iosInfo.identifierForVendor; // Returns a unique ID for iOS devices
  } else {
    return null; // Handle other platforms or return a default value
  }
  return null;
}

// void fetchDeviceId(String token) async {
//   String? deviceId = await getUniqueDeviceId(token);
//   GlobalVariables().deviceId = deviceId;
//   print("Device ID: ${GlobalVariables().deviceId}");
// }
