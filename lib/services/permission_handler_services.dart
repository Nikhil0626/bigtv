import 'dart:io';
import 'package:permission_handler/permission_handler.dart';


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
