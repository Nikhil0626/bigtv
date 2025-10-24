import 'package:chotanews/aggricator_screens/referral_screen/referral_view/referal_dialog.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyDialog {
  static const _lastShownReferEarnKey = "last_refer_earn";

  static Future<void> showReferDialog({
    required BuildContext context,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();

    // Get last shown date
    final lastShownString = prefs.getString(_lastShownReferEarnKey);
    DateTime? lastShown;
    if (lastShownString != null) {
      lastShown = DateTime.tryParse(lastShownString);
    }

    // If already shown today → skip
    // if (lastShown != null &&
    //     lastShown.year == today.year &&
    //     lastShown.month == today.month &&
    //     lastShown.day == today.day) {
    //   return;
    // }

    // Save today's date
    await prefs.setString(_lastShownReferEarnKey, today.toIso8601String());

    // Show dialog
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(16),
          // ),
          child: ReferralDialog(),
        ),
      );
    }
  }
}
