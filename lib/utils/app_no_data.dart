import 'package:flutter/material.dart';

import 'app_fonts.dart';

class AppNoData extends StatelessWidget {
  final String data;

  const AppNoData({super.key, this.data = ""});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        data == "" ? "No data Found" : data,
        style: fontStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
