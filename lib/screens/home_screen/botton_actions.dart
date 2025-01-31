import 'package:flutter/material.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class BottomActions extends StatelessWidget {
  final IconData icon;
  final String label;
  final Function onTap;

  const BottomActions({super.key, required this.icon, required this.label,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        height(height: 2),
        Text(
          label,
          style: fontStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}