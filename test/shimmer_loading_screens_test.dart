import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:chotanews/aggricator_screens/loading_screen/300_250_loading_screen.dart';
import 'package:chotanews/aggricator_screens/loading_screen/ads_loading_screen.dart';
import 'package:chotanews/aggricator_screens/loading_screen/Banner300x50Size_loading.dart';
import 'package:chotanews/aggricator_screens/loading_screen/home_shimmer.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/common_appbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('Loading and Shimmer Screens Widget Tests', () {
    testWidgets('Loading300250Screen renders properly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: Loading300250Screen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Loading300250Screen), findsOneWidget);
    });

    testWidgets('AdsLoadingScreen renders properly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: AdsLoadingScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AdsLoadingScreen), findsOneWidget);
    });

    testWidgets('Banner300x50sizeLoading renders properly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: Banner300x50sizeLoading(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(Banner300x50sizeLoading), findsOneWidget);
    });

    testWidgets('HomeShimmer renders properly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: HomeShimmer(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(HomeShimmer), findsOneWidget);
    });

    testWidgets('AppLoadingScreen renders CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingScreen(loadingColor: Colors.red),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AppLoadingScreen), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CommonAppbar renders screen name correctly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              appBar: CommonAppbar(screenName: 'Trending News'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Trending News'), findsOneWidget);
    });
  });
}
