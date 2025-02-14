import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';



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


Future<void> requestLocationPermission() async {
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      // Permissions are permanently denied
      print('Location permissions are permanently denied.');
      return;
    }
  }

  if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print("Location: ${position.latitude}, ${position.longitude}");
  }
}


Future<void> requestNotificationPermission() async {
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

}
