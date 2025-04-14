import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';

class AppLoadingScreen extends StatelessWidget {
  final Color loadingColor;
  const AppLoadingScreen({super.key, this.loadingColor = AppColors.appButtonColor});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(color: loadingColor,strokeWidth: 1,)),
      // child: Lottie.asset(
      //   "assets/loading.json",height: 50,width: 50,),
    );
  }
}
