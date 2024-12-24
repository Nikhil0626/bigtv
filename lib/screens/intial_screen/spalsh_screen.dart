import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {


    Future.delayed(const Duration(milliseconds: 500), () async{
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      String token = sharedPreferences.getString("accessToken")??"";

      print("helllllllll ${token}");
      if(token == null || token =="" || token.isEmpty){
        Navigator.pushNamed(context, RoutesManager.login);
      }else {
        Navigator.pushNamed(context, RoutesManager.homeScreen);

      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: const Color(0xff00a8ff),
        child:  Center(
          child: SvgPicture.asset("assets/mobile_logo.svg",height: 150.w,width: 150.w,),
        ),
      ),
    );
  }
}
