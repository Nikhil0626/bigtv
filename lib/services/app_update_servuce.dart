import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService {
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      log("Checking for updates...");
      AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      log("Update availability: ${updateInfo.updateAvailability}");
      log("Immediate update allowed: ${updateInfo.immediateUpdateAllowed}");
      log("Flexible update allowed: ${updateInfo.flexibleUpdateAllowed}");

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        log("Update available. Starting flexible update...");
        await InAppUpdate.startFlexibleUpdate().then((_) {
          log("Completing flexible update...");
          InAppUpdate.completeFlexibleUpdate();
        }).catchError((e) {
          log("Flexible update error: $e");
          // _showSnackBar(context, "Flexible update failed: $e");
        });
      } else {
        log("App is up to date.");
        // _showSnackBar(context, "Your app is up-to-date!");
      }
    } catch (e) {
      log("Failed to check for updates: $e");
      // _showSnackBar(context, "Failed to check for updates: $e");
    }
  }

  static void _showSnackBar(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(SnackBar(content: Text(message)));
  }
}
