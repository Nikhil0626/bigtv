import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get typography => theme.textTheme;
  IconThemeData get iconTheme => theme.iconTheme;

  // Semantic Shortcuts based on our design system
  Color get primaryColor => colors.primary;
  Color get backgroundColor => colors.surface;
  Color get surfaceColor => colors.surface;
  Color get textColor => colors.onSurface;
  Color get subtitleColor => theme.brightness == Brightness.light ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF);
  Color get borderColor => colors.outline;
  Color get cardColor => theme.cardColor;
}
