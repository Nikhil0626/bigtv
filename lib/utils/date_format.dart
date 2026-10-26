import 'dart:developer';

import 'package:intl/intl.dart';

String formatTimeDifference(String? inputTime, {bool isComment = false}) {
  final now = DateTime.now();

  if (inputTime == null || inputTime.trim().isEmpty) {
    return '0 seconds ago';
  }

  DateTime date;
  try {
    final cleanTime = inputTime.trim();
    // 1. If explicit UTC indicator ('Z') or offset (+05:30, -04:00) is present
    if (cleanTime.endsWith('Z') || cleanTime.contains('+') || RegExp(r'-\d{2}:\d{2}$').hasMatch(cleanTime)) {
      date = DateTime.parse(cleanTime).toLocal();
    } else {
      // 2. Server timestamps for comments, posts, polls, reviews, etc. are stored in UTC without timezone offset.
      // E.g. "2026-10-26 06:55:00" or "2026-10-26T06:55:00" or "2026-10-26 06:55:00.000"
      final iso = cleanTime.contains('T') ? cleanTime : cleanTime.replaceFirst(' ', 'T');
      try {
        date = DateTime.parse('${iso}Z').toLocal();
      } catch (_) {
        try {
          date = DateFormat('yyyy-MM-dd HH:mm:ss').parse(cleanTime, true).toLocal();
        } catch (_) {
          date = DateTime.parse(cleanTime).toLocal();
        }
      }
    }
  } catch (e) {
    log(e.toString());
    return "Invalid date ";
  }

  log("${now}-------${date}");

  final difference = now.difference(date);
  if (difference.inSeconds < 0) {
    return '0 seconds ago';
  } else if (difference.inSeconds < 60) {
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inMinutes < 60) {
    return difference.inMinutes == 1 ? '${difference.inMinutes} min ago' : '${difference.inMinutes} mins ago';
  } else if (difference.inHours < 24) {
    return difference.inHours == 1 ? '${difference.inHours} hour ago' : '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return difference.inDays == 1 ? '${difference.inDays} day ago' : '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()} week ago';
  } else {
    return DateFormat('dd MMM yyyy').format(date); // Display full date
  }
}
