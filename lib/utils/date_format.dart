import 'package:intl/intl.dart';

String formatTimeDifference(String inputTime, ) {

  final now = DateTime.now().add(Duration(hours: -5, minutes: -30)); // Get current local time

  // Define date formats
  DateFormat inputFormat = DateFormat("MMM d, yyyy h:mm a"); // Format for tweets
  DateFormat format = DateFormat('yyyy-MM-ddTHH:mm:ss'); // Generic ISO format

  DateTime date;
  try {
    if (inputTime.trim().isEmpty) {
      date = now; // Fallback to 'now' if input is empty
    } else {
      date =  format.parse(inputTime);
      date = date; // Convert to local time
    }
  } catch (e) {
    return "Invalid date"; // Return an error string
  }

  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return '${difference.inSeconds} seconds ago';
  } else if (difference.inMinutes < 60) {
    return difference.inMinutes==1?'${difference.inMinutes} minute ago':'${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return difference.inHours==1?'${difference.inHours} hour ago':'${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return difference.inDays==1?'${difference.inDays} days ago':'${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()} week ago';
  } else {
    return DateFormat('dd MMM yyyy').format(date); // Display full date
  }
}
