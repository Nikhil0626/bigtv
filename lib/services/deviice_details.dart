import 'dart:developer';
import 'dart:io';

import 'package:chotanews/screens/home_screen/home_repo/event_repo.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globel_keys/global_variables_data.dart';

Future<String?> getUniqueDeviceId(String token, ) async {
  SharedPreferences sp =await SharedPreferences.getInstance();
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();


  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

    if(token == "close"){
      EventRepo().sendEvent({"key":"opened_app",
        "data":{"device_id": androidInfo.id.toString(),"userId":sp.getString("loginId")??"","isOpen":false}});
      return "";
    }
    GlobalVariables().platForm = androidInfo.brand;
    GlobalVariables().deviceId = androidInfo.id;


    if (sp.getString("deviceName").toString() != "true") {
      sendAndroidDeviceDetails( androidInfo);
     EventRepo().sendEvent({"key":"device_details",
         "data":{
           "device_id": androidInfo.id.toString(),
           "device_brand": androidInfo.brand.toString(),
           "device_model": androidInfo.model.toString(),
           "device_sdk": androidInfo.version.sdkInt.toString(),
           "device_os": "android",
         }
     });

      sp.setString("deviceName", "true");
    }
    String? userId = sp.getString('loginId');

    EventRepo().sendEvent({"key":"opened_app",
      "data":{"device_id": androidInfo.id.toString(),"userId":userId,"isOpen":true}});
    // return androidInfo.id;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    if(token == "close"){
      EventRepo().sendEvent({"key":"opened_app",
        "data":{"device_id": iosInfo.identifierForVendor.toString(),"userId":sp.getString("loginId")??"","isOpen":false}});
      return "";
    }
    GlobalVariables().platForm = iosInfo.systemName;
    GlobalVariables().deviceId = iosInfo.identifierForVendor;
    log("iOS Details ---- $iosInfo");
    log("iOS Details ---- ${sp.getString("deviceName").toString()}");

    if (sp.getString("deviceName").toString() != "true") {
      sendiOSDeviceDetails(iosInfo);
      EventRepo().sendEvent({"key":"device_details",
        "data":{
          "device_id": iosInfo.identifierForVendor.toString(),
          "device_brand": iosInfo.model.toString(), // iPhone/iPad
          "device_model": iosInfo.utsname.machine.toString(), // Corrected field
          "device_sdk": iosInfo.systemVersion.toString(),
          "device_os": iosInfo.systemName.toString(),
        }
      });
      sp.setString("deviceName", "true");
    }
    String? userId = sp.getString('loginId');

    EventRepo().sendEvent({"key":"opened_app",
      "data":{"device_id": iosInfo.identifierForVendor.toString(),"userId":userId,"isOpen":true}});
    // sendiOSDeviceDetails(iosInfo);
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
