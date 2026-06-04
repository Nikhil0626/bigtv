import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import '../core/theme/theme_extensions.dart';

class AppLoadingScreen extends StatelessWidget {
  final Color? loadingColor;
  const AppLoadingScreen({super.key, this.loadingColor});

  @override
  Widget build(BuildContext context) {
    return  Center(
      child: SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(color: loadingColor ?? context.primaryColor, strokeWidth: 1,)),
    );
  }
}
