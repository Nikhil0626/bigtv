
import 'dart:io';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../aggricator_screens/events_data/event_repo.dart';

Future<void> requestManageStoragePermission() async {
  if (Platform.isAndroid) {
    var status = await Permission.manageExternalStorage.status;
    if (status.isGranted) {
      print("✅ Manage External Storage permission already granted");
    } else if (status.isDenied) {
      var result = await Permission.manageExternalStorage.request();
      if (result.isGranted) {
        print("✅ Manage External Storage permission granted");
      } else {
        await Permission.manageExternalStorage.request();
      }
    } else if (status.isPermanentlyDenied) {
      print("⚠️ Manage External Storage permission permanently denied. Opening settings...");
      await openAppSettings();
    }
  }
}

Future<void> requestStoragePermission() async {
  if (Platform.isAndroid) {
    var status = await Permission.storage.status;

    if (status.isGranted) {
      print("✅ Storage permission already granted");
    } else if (status.isDenied) {
      var result = await Permission.storage.request();
      if (result.isGranted) {
        print("✅ Storage permission granted");
      } else {
        print("❌ Storage permission denied");
      }
    } else if (status.isPermanentlyDenied) {
      print("⚠️ Storage permission permanently denied. Opening settings...");
      await openAppSettings();
    }
  }
}

Future<void> checkForUpdate() async {
  PackageInfo _packageInfo = PackageInfo();
  final info = await PackageManager.getPackageInfo();
  _packageInfo = info;
  if (Platform.isAndroid) {
    try {
      InAppUpdateManager manager = InAppUpdateManager();
      AppUpdateInfo? updateInfo = await manager.checkForUpdate();

      if (updateInfo == null) {
        debugPrint("No update info received");
        return;
      }

      debugPrint("Update Info: ${updateInfo.toJson()}");

      if (updateInfo.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress) {
        debugPrint("Resuming developer triggered update...");
        String? msg = await manager.startAnUpdate(type: AppUpdateType.immediate);
        debugPrint(msg ?? '');
      } else if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        if (updateInfo.immediateAllowed) {
          debugPrint("Starting immediate update...");
          String? msg = await manager.startAnUpdate(type: AppUpdateType.immediate);
          debugPrint(msg ?? '');
        } else if (updateInfo.flexibleAllowed) {
          debugPrint("Starting flexible update...");
          String? msg = await manager.startAnUpdate(type: AppUpdateType.flexible);
          debugPrint(msg ?? '');
          // Optionally call completeFlexibleUpdate() after download finishes
        } else {
          debugPrint("Update available but no method allowed");
        }
      } else {
        debugPrint("No update available");
      }
    } catch (e) {
      debugPrint("Error checking update: $e");
    }
  } else if (Platform.isIOS) {
    try {
      VersionInfo? versionInfo = await UpgradeVersion.getiOSStoreVersion(packageInfo: _packageInfo, regionCode: "US");

      if (versionInfo != null) {
        debugPrint("iOS Store Info: ${versionInfo.toJson()}");

        if (versionInfo.canUpdate && versionInfo.appStoreLink != null) {
          final Uri url = Uri.parse(versionInfo.appStoreLink!);
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            debugPrint("Cannot launch App Store URL");
          }
        } else {
          debugPrint("No update needed or no URL");
        }
      }
    } catch (e) {
      debugPrint("Error checking iOS update: $e");
    }
  }
}

Future<void> initPlugin() async {
  final TrackingStatus status = await AppTrackingTransparency.trackingAuthorizationStatus;
  if (status == TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }

  final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
  print("UUID: $uuid");
}

Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return;
    }
  }

  if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("Location: ${position.latitude}, ${position.longitude}");
    getAddressFromLatLng(position.latitude, position.longitude);
  }
}

Future<void> getAddressFromLatLng(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    SharedPreferences sp = await SharedPreferences.getInstance();
    print("location ------ $placemarks");
    Placemark place = placemarks[0];
    sendLiveLocationDetails(place);
  } catch (e) {
    print(e);
  }
}

Future<void> requestNotificationPermission() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
}

final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

Future<void> getReferrerFromPlayStore() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  String? userId = sharedPreferences.getString("userId");
  try {
    final ReferrerDetails referrerDetails = await AndroidPlayInstallReferrer.installReferrer;

    final String? referrerUrl = referrerDetails.installReferrer;
    final int clickTimestamp = referrerDetails.referrerClickTimestampSeconds;
    final int installTimestamp = referrerDetails.installBeginTimestampSeconds;
    EventRepo().addEvent({
      "shareApp": Platform.isIOS ? "iOS" : "Android",
      "userId": userId ?? "0",
      'referrerUrl': referrerUrl,
      'clickTimestamp': clickTimestamp,
      'installTimestamp': installTimestamp,
      "createAt": DateTime.now().toString(),
      "error": "",
      "isSharedUser": false
    }, "referral");

    final uri = Uri.parse("https://dummy.com/?$referrerUrl");
    sharedPreferences.setString("referralCode", uri.queryParameters['user_id'].toString().split("=").last.toString() ?? "chota123");
  } catch (e) {
    // EventRepo().addEvent({
    //   "shareApp": Platform.isIOS ? "iOS" : "Android",
    //   "userId": userId ?? "0",
    //   'referrerUrl': "",
    //   'clickTimestamp': "",
    //   'installTimestamp': "",
    //   "createAt": DateTime.now().toString(),
    //   "error": e.toString(),
    //   "isSharedUser": false
    // }, "referral");
  }
}
