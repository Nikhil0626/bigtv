import 'dart:developer';

import 'package:intl/intl.dart';

String formatTimeDifference(String inputTime,{bool isComment= false} ) {


  final now = DateTime.now().add(const Duration(hours: -5, minutes: -30));


  DateFormat inputFormat = DateFormat("MMM d, yyyy h:mm a");
  DateFormat format = DateFormat('yyyy-MM-ddTHH:mm:ss');
  DateFormat format1 = DateFormat('yyyy-MM-dd HH:mm:ss');

  DateTime date;
  try {
    if (inputTime.trim().isEmpty) {
      date = now;

    } else {
       date = isComment?format1.parse(inputTime).toLocal():format.parse(inputTime).toLocal(); // Convert to local time
       date.toString();
    }
  } catch (e) {
    print(e.toString());
    return "Invalid date ";
  }

  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inMinutes < 60) {
    return difference.inMinutes==1?'${difference.inMinutes} min ago':'${difference.inMinutes} mins ago';
  } else if (difference.inHours < 24) {
    return difference.inHours==1?'${difference.inHours} hour ago':'${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return difference.inDays==1?'${difference.inDays} day ago':'${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()} week ago';
  } else {
    return DateFormat('dd MMM yyyy').format(date); // Display full date
  }
}
