import 'package:flutter/material.dart';

import 'color_tokens.dart';

/// Resolved color tokens for modal dialogs and bottom sheets so login,
/// logout, guest-prompt, and account pop-ups stay consistent with the active
/// light or dark application theme.
class ThemedPopupPalette {
  const ThemedPopupPalette({
    required this.isDark,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.bodyColor,
    required this.accentColor,
  });

  final bool isDark;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final Color bodyColor;
  final Color accentColor;

  factory ThemedPopupPalette.of(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return ThemedPopupPalette(
      isDark: isDark,
      backgroundColor:
          isDark ? AppColorTokens.darkSurface : AppColorTokens.lightSurface,
      borderColor:
          isDark ? AppColorTokens.darkBorder : AppColorTokens.lightBorder,
      titleColor: isDark
          ? AppColorTokens.darkTextPrimary
          : AppColorTokens.lightTextPrimary,
      bodyColor: isDark
          ? AppColorTokens.darkTextSecondary
          : AppColorTokens.lightTextSecondary,
      accentColor:
          isDark ? AppColorTokens.darkPrimaryRed : AppColorTokens.primaryRed,
    );
  }

  RoundedRectangleBorder dialogShape([double radius = 18]) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: borderColor,
        width: isDark ? 1.0 : 0.6,
      ),
    );
  }
}

/// Shared themed confirmation dialog for login / logout pop-ups.
Future<bool> showThemedConfirmDialog({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String message,
  required String cancelLabel,
  required String confirmLabel,
  Key? dialogKey,
  Key? cancelKey,
  Key? confirmKey,
}) async {
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) {
      final palette = ThemedPopupPalette.of(dialogCtx);
      return AlertDialog(
        key: dialogKey,
        backgroundColor: palette.backgroundColor,
        shape: palette.dialogShape(18),
        contentPadding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: palette.accentColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: palette.accentColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.titleColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.bodyColor,
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: cancelKey,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: palette.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () => Navigator.pop(dialogCtx, false),
                    child: Text(
                      cancelLabel,
                      style: TextStyle(
                        color: palette.bodyColor,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    key: confirmKey,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.pop(dialogCtx, true),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
  return result ?? false;
}

