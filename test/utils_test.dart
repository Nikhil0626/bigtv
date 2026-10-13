import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/utils/date_format.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_strings.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Utils Tests', () {
    test('formatTimeDifference handles various inputs', () {
      expect(formatTimeDifference(null), equals('0 seconds ago'));
      expect(formatTimeDifference(''), equals('0 seconds ago'));
      expect(formatTimeDifference('invalid-date-string'), equals('Invalid date '));

      final now = DateTime.now();
      final tenSecondsAgo = now.subtract(const Duration(seconds: 10)).toIso8601String();
      expect(formatTimeDifference(tenSecondsAgo), contains('seconds ago'));

      final oneMinuteAgo = now.subtract(const Duration(minutes: 1)).toIso8601String();
      expect(formatTimeDifference(oneMinuteAgo), equals('1 min ago'));

      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5)).toIso8601String();
      expect(formatTimeDifference(fiveMinutesAgo), equals('5 mins ago'));

      final oneHourAgo = now.subtract(const Duration(hours: 1)).toIso8601String();
      expect(formatTimeDifference(oneHourAgo), equals('1 hour ago'));

      final fiveHoursAgo = now.subtract(const Duration(hours: 5)).toIso8601String();
      expect(formatTimeDifference(fiveHoursAgo), equals('5 hours ago'));

      final oneDayAgo = now.subtract(const Duration(days: 1)).toIso8601String();
      expect(formatTimeDifference(oneDayAgo), equals('1 day ago'));

      final fiveDaysAgo = now.subtract(const Duration(days: 5)).toIso8601String();
      expect(formatTimeDifference(fiveDaysAgo), equals('5 days ago'));

      final twoWeeksAgo = now.subtract(const Duration(days: 14)).toIso8601String();
      expect(formatTimeDifference(twoWeeksAgo), equals('2 week ago'));

      final twoMonthsAgo = now.subtract(const Duration(days: 60)).toIso8601String();
      final formatted = formatTimeDifference(twoMonthsAgo);
      expect(formatted, isNotEmpty);
      expect(formatted, isNot(equals('Invalid date ')));
    });

    test('app_spaces height and width widgets create SizedBox with correct dimensions', () {
      final hWidget = height(height: 25.0) as SizedBox;
      expect(hWidget.height, equals(25.0));

      final wWidget = width(width: 40.0) as SizedBox;
      expect(wWidget.width, equals(40.0));
    });

    test('AppStrings contains standard app strings', () {
      expect(AppStrings.appName, equals('Chota News'));
      expect(AppStrings.appNotWorking, equals('No Data Found'));
    });

    test('AppEnums values exist and match expected types', () {
      expect(RequestType.values.length, equals(4));
      expect(RequestType.get, isNotNull);
      expect(RequestType.post, isNotNull);

      expect(BannerAdsLoading.values.length, equals(3));
      expect(ScreenType.values.length, equals(5));
      expect(LoginStatus.values.length, equals(7));
      expect(NewAppLoginStatus.values.length, equals(8));
    });

    test('AppColors fallback values are valid', () {
      expect(AppColors.wColor, equals(Colors.white));
      expect(AppColors.ratingColor, equals(const Color(0xFFFFD700)));
      expect(AppColors.borderColor, isNotNull);
      expect(AppColors.headerTextColor, isNotNull);
      expect(AppColors.bodyTextColor, isNotNull);
      expect(AppColors.appButtonColor, isNotNull);
    });

    test('fontStyle creates TextStyle with standard properties', () {
      final style = fontStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.blue);
      expect(style.fontSize, equals(16.0));
      expect(style.fontWeight, equals(FontWeight.bold));
      expect(style.color, equals(Colors.blue));
    });
  });
}
