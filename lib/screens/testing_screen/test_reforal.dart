import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:url_launcher/url_launcher.dart';


class TestReforal extends StatefulWidget {
  const TestReforal({super.key});

  @override
  State<TestReforal> createState() => _TestReforalState();
}

class _TestReforalState extends State<TestReforal> {
  PackageInfo _packageInfo = PackageInfo();

  @override
  void initState() {
    super.initState();
    _getPackageData();
  }

  Future<void> _getPackageData() async {
    try {
      final info = await PackageManager.getPackageInfo();
      if (!mounted) return;
      setState(() {
        _packageInfo = info;
      });
    } catch (e) {
      debugPrint("Failed to get package info: $e");
    }
  }

  Future<void> _checkForUpdate() async {
    if (Platform.isAndroid) {
      try {
        InAppUpdateManager manager = InAppUpdateManager();
        AppUpdateInfo? updateInfo = await manager.checkForUpdate();

        if (updateInfo == null) {
          debugPrint("No update info received");
          return;
        }

        debugPrint("Update Info: ${updateInfo.toJson()}");

        if (updateInfo.updateAvailability ==
            UpdateAvailability.developerTriggeredUpdateInProgress) {
          debugPrint("Resuming developer triggered update...");
          String? msg = await manager.startAnUpdate(
              type: AppUpdateType.immediate);
          debugPrint(msg ?? '');
        } else if (updateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          if (updateInfo.immediateAllowed) {
            debugPrint("Starting immediate update...");
            String? msg = await manager.startAnUpdate(
                type: AppUpdateType.immediate);
            debugPrint(msg ?? '');
          } else if (updateInfo.flexibleAllowed) {
            debugPrint("Starting flexible update...");
            String? msg = await manager.startAnUpdate(
                type: AppUpdateType.flexible);
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
        VersionInfo? versionInfo =
        await UpgradeVersion.getiOSStoreVersion(
            packageInfo: _packageInfo, regionCode: "US");

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

  @override
  Widget build(BuildContext context) {
    final appVersion = _packageInfo.version ?? 'N/A';
    final buildNumber = _packageInfo.buildNumber ?? 'N/A';

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('App Update Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("App Version: $appVersion ($buildNumber)"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _checkForUpdate,
                  child: const Text("Check for Update"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
