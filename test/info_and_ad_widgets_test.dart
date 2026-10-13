import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/aggricator_screens/ad_manager_screen/are_like_app.dart';
import 'package:chotanews/aggricator_screens/ad_manager_screen/rate_your_app.dart';
import 'package:chotanews/aggricator_screens/ad_manager_screen/share_app.dart';
import 'package:chotanews/aggricator_screens/chota_info_screens/about_us.dart';
import 'package:chotanews/aggricator_screens/chota_info_screens/privacy_policy.dart';
import 'package:chotanews/aggricator_screens/chota_info_screens/terms_conditions.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Info and Ad Widgets Tests', () {
    testWidgets('AreLikeApp renders header text and empty survey list gracefully', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: AreLikeApp(),
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Are liking our app?'), findsOneWidget);
    });

    testWidgets('RateYourApp renders star rating row and button', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: RateYourApp(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('Rate your experience'), findsOneWidget);
      expect(find.text('Awesome, liked it'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(5));
    });

    testWidgets('ShareYourApp renders message and button', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: ShareYourApp(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Are you liking our app?'), findsOneWidget);
      expect(find.textContaining('Share the ChotaNewsApp'), findsOneWidget);
    });

    testWidgets('AboutUs renders help header and company details', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
            ],
            child: const MaterialApp(
              home: AboutUs(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Bigtv News'), findsOneWidget);
      expect(find.text('Contact Details'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
    });

    testWidgets('PrivacyPolicy renders title and privacy content', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
            ],
            child: const MaterialApp(
              home: PrivacyPolicy(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('TermsConditions renders terms and conditions header', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
            ],
            child: const MaterialApp(
              home: TermsConditions(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Terms & Conditions'), findsOneWidget);
    });
  });
}
