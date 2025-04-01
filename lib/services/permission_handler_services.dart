import 'dart:developer';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geocoding/geocoding.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

import '../globel_keys/global_variables_data.dart';
import '../screens/home_screen/home_repo/event_repo.dart';

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
      print(
          "⚠️ Manage External Storage permission permanently denied. Opening settings...");
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


Future<void> initPlugin() async {
  final TrackingStatus status =
  await AppTrackingTransparency.trackingAuthorizationStatus;
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

  if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("Location: ${position.latitude}, ${position.longitude}");
    getAddressFromLatLng(position.latitude, position.longitude);
  }
}

Future<void> getAddressFromLatLng(double latitude, double longitude) async {
  try {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    print("location ------ $placemarks");
    Placemark place = placemarks[0];

    EventRepo().sendEvent({"key":"live_location",
      "data":{
        "device_id": "${GlobalVariables().deviceId}",
        "country": "${place.country}",
        "state": "${place.administrativeArea}",
        "district": place.locality.toString(),
        "mandel": "${place.subLocality}",
        "village": "",
      }
    });
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
