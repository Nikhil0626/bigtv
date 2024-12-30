import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tweetai/services/base_service.dart';
import 'package:tweetai/services/base_urls.dart';
import 'package:tweetai/utils/app_colors.dart';
import 'package:tweetai/utils/app_enums.dart';
import 'package:tweetai/utils/app_fonts.dart';

import '../../globel_keys/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    getCall();
  }

  Future<void> getCall() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    print(
        "appName=$appName   packageName=$packageName   version=$version   buildNumber=$buildNumber");
    String finalVersion = "$version+$buildNumber";
    print(finalVersion);

    try {
      Response response = await BaseService().makeRequest(
        url: BaseUrls.getMobileVersions,
        method: RequestType.get,
      );

      if (response.data['data'] != null &&
          response.data['data'].length > 1 &&
          response.data['data'][1]['name'] == "android_app_version") {
        String serverVersion = response.data['data'][1]['value'].toString();

        if (finalVersion == serverVersion) {
          Future.delayed(const Duration(milliseconds: 500), () async {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            String token = sharedPreferences.getString("accessToken") ?? "";
            print("helllllllll ${token}");
            if (token.isEmpty) {
              Navigator.pushNamed(context, RoutesManager.login);
            } else {
              Navigator.pushNamed(context, RoutesManager.homeScreen);
            }
          });
          print(serverVersion);
        } else {
          showUpdateDialog(serverVersion);
        }
      }
    } on DioException catch (e, st) {
      print(st.toString());
      print(e.toString());
    } catch (e, st) {
      print(st.toString());
      print(e.toString());
    }
  }

  void showUpdateDialog(String serverVersion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.wColor,
          title: const Text(
            "Update Available",
            style: TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          content: Text(
            "Are you sure you want to update to version $serverVersion?",
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                navigateToUpdateScreen();
              },
              child: Text("Yes",
                  style: fontStyle(
                      fontSize: 14,
                      color: AppColors.appButtonColor,
                      fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No",
                  style: fontStyle(
                      fontSize: 14,
                      color: AppColors.appButtonColor,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void navigateToUpdateScreen() {
    print("Navigating to update screen");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: const Color(0xff00a8ff),
        child: Center(
          child: SvgPicture.asset(
            "assets/mobile_logo.svg",
            height: 150.w,
            width: 150.w,
          ),
        ),
      ),
    );
  }
}
