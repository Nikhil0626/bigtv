import 'package:flutter/material.dart';
import '../globel_keys/globel_keys.dart';
import '../core/theme/theme_extensions.dart';

@Deprecated('Use context.colors and context.primaryColor from theme_extensions.dart instead.')
class AppColors {
  static BuildContext? get _ctx => mainNavigatorKey.currentContext;

  static Color get borderColor => _ctx?.borderColor ?? const Color(0xFFD9D9D9);
  static Color get headerTextColor => _ctx?.textColor ?? const Color(0xFF111111);
  static Color get wColor => Colors.white;
  static Color get bodyTextColor => _ctx?.subtitleColor ?? const Color(0xFF5E5E5E);
  static Color get appButtonColor => _ctx?.primaryColor ?? const Color(0xFFF40000);
  static Color get newAppButtonColor => _ctx?.cardColor ?? const Color(0xFFFAFAFA);
  static Color get settingsPageBackgroundColor => _ctx?.backgroundColor ?? const Color(0xFFF2F2F2);
  static Color get referEarnColor => _ctx?.colors.secondary ?? const Color(0xFFC70000);
  
  ///New App Colors
  static Color get iconColors => _ctx?.iconTheme.color ?? const Color(0xFF5E5E5E);
  static Color get cardBackgroundColor => _ctx?.cardColor ?? const Color(0xFFFAFAFA);
  static Color get textColor => _ctx?.textColor ?? const Color(0xFF111111);
  static Color get settingsPageTextColor => _ctx?.textColor ?? const Color(0xFF111111);
  static Color get settingsPageIconColor => _ctx?.iconTheme.color ?? const Color(0xFF5E5E5E);
  static Color get ePaperCardColor => _ctx?.cardColor ?? const Color(0xFFFAFAFA);
  static Color get loginBgColor => _ctx?.primaryColor ?? const Color(0xFFF40000);
  static Color get loginNumberBg => _ctx?.cardColor ?? const Color(0xFFFAFAFA);
  static Color get ratingColor => const Color(0xFFFFD700);
  static Color get adsBackgroundColor => _ctx?.colors.outline ?? const Color(0xFFD9D9D9);
}