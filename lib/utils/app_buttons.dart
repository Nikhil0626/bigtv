import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_fonts.dart';

class AppButtons extends StatelessWidget {
  final String name;
  final bool isLoading;
  final onTap;

  const AppButtons({super.key, required this.name, required this.onTap,  this.isLoading=false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // gradient: const LinearGradient(
        //   colors: [Color(0xffF86754), Color(0xffF98054)], // Gradient colors
        //   begin: Alignment.topLeft,
        //   end: Alignment.bottomRight,
        // ),
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8.0.sp),
      ),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * .05,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          // Set transparent to use gradient from container
          shadowColor: Colors
              .transparent, // Remove shadow to avoid conflict with gradient
        ),
        child: Text(
          name,
          style: fontStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
