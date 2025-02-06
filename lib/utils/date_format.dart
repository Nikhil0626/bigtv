import 'package:intl/intl.dart';

String formatTimeDifference(String inputTime, ) {
  print("Input Time: $inputTime");

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
      print("Parsed Date: $date");
    }
  } catch (e) {
    print("Error parsing date: $e");
    return "Invalid date"; // Return an error string
  }

  final difference = now.difference(date);
  print("Time Difference: $difference");

  // Formatting the difference
  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}s ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()}w ago';
  } else {
    return DateFormat('dd MMM yyyy').format(date); // Display full date
  }
}
