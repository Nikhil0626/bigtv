import 'package:flutter/material.dart';

import 'app_fonts.dart';

class AppNoData extends StatelessWidget {
  final String data;
  final Color? textColor;

  const AppNoData({super.key, this.data = "", this.textColor});

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        textColor ?? Theme.of(context).colorScheme.onSurface;
    return Center(
      child: Text(
        data == "" ? "No data Found" : data,
        style: fontStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: resolvedColor,
        ),
      ),
    );
  }
}
