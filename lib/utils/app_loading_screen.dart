import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppLoadingScreen extends StatelessWidget {
  const AppLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        "assets/loading",height: 50,width: 50,),
    );
  }
}
