import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator()),
      // child: Lottie.asset(
      //   "assets/loading.json",height: 50,width: 50,),
    );
  }
}
