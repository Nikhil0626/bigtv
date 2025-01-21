

import 'package:intl/intl.dart';

String dateConversion(String dateTimeString) {
  DateTime targetTime = DateTime.parse(dateTimeString);
  DateTime currentTime = DateTime.now();

  Duration difference = currentTime.difference(targetTime);

  int days = difference.inDays;
  int hours = difference.inHours % 24;
  int minutes = difference.inMinutes % 60;
  int seconds = difference.inSeconds % 60;

  return "${days}d ${hours}h ${minutes}m ${seconds}s";
}


String dateFormat(String dateString) {
  DateTime date = DateTime.parse(dateString);

  return DateFormat('dd MMM yyyy').format(date);
}

