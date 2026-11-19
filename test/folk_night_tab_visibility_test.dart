import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/events/presentation/screens/folk_night_event_screen.dart';
import 'package:chotanews/features/events/presentation/widgets/folk_night_floating_button.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/services/content_share_dispatcher.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

class _MockConfigHomeProvider extends HomeProvider {
  bool getAppConfigCalled = false;
  bool getAllPostCalled = false;
  bool mockFolkNightValue = false;

  @override
  Future<void> getAppConfig() async {
    getAppConfigCalled = true;
    folkNight = mockFolkNightValue;
  }

  @override
  Future<void> getAllPost({String postIds = "0", bool isGetAllPost = false}) async {
    getAllPostCalled = true;
    isHomeLoading = false;
    notifyListeners();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  Widget createWidget(HomeProvider homeProvider) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, _) => ChangeNotifierProvider<HomeProvider>.value(
        value: homeProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: FolkNightFloatingButton(),
          ),
        ),
      ),
    );
  }

  group('Folk Night Tab Visibility Tests', () {
    testWidgets('Folk Night button is VISIBLE when on Home page news tab (selectedIndex == 1)', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 1;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      // Button content should be rendered
      expect(find.byType(FolkNightFloatingButton), findsOneWidget);
      expect(find.text('Folk Night'), findsOneWidget);
    });

    testWidgets('Folk Night button is HIDDEN when on Search tab (selectedIndex == 0)', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 0;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('Folk Night button is HIDDEN when on Reels tab (selectedIndex == 2)', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 2;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);
    });

    testWidgets('Folk Night button is HIDDEN when on Settings/More tab (selectedIndex == 3)', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 3;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);
    });

    testWidgets('Folk Night button is HIDDEN when folkNight config is false or Malayalam', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = false;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 1;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);

      homeProvider.folkNight = true;
      homeProvider.langCode = 'ml';
      homeProvider.notifyListeners();
      await tester.pump();

      expect(find.text('Folk Night'), findsNothing);
    });

    testWidgets('Close icon is visible on Folk Night button and tapping it dismisses the button', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 1;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      // Verify Folk Night and close icon are rendered
      expect(find.text('Folk Night'), findsOneWidget);
      expect(find.byKey(const Key('folk_night_close_button')), findsOneWidget);

      // Tap close icon
      await tester.tap(find.byKey(const Key('folk_night_close_button')));
      await tester.pump();

      // Button should now be dismissed / hidden
      expect(homeProvider.isFolkNightDismissed, isTrue);
      expect(find.text('Folk Night'), findsNothing);

      // Coming to All Posts tab again restores the button
      homeProvider.onItemTapped(1);
      await tester.pump();

      expect(homeProvider.isFolkNightDismissed, isFalse);
      expect(find.text('Folk Night'), findsOneWidget);
    });

    testWidgets('Switching to another tab and returning to All Posts tab restores dismissed button', (tester) async {
      final homeProvider = HomeProvider();
      homeProvider.folkNight = true;
      homeProvider.langCode = 'te';
      homeProvider.selectedIndex = 1;

      await tester.pumpWidget(createWidget(homeProvider));
      await tester.pump();

      // Dismiss button
      homeProvider.dismissFolkNight();
      await tester.pump();
      expect(find.text('Folk Night'), findsNothing);

      // User switches to Reels (tab 2)
      homeProvider.onItemTapped(2);
      await tester.pump();

      // User returns to All Posts (tab 1)
      homeProvider.onItemTapped(1);
      await tester.pump();

      expect(homeProvider.isFolkNightDismissed, isFalse);
      expect(find.text('Folk Night'), findsOneWidget);
    });

    testWidgets('Folk Night deep link hits config API; if folkNight is false, lands on home screen and hits allpost', (tester) async {
      final homeProvider = _MockConfigHomeProvider();
      homeProvider.mockFolkNightValue = false;
      homeProvider.folkNight = true; // initially set, should be updated by getAppConfig
      homeProvider.eventsEnable = true;
      homeProvider.isHomeScreen = true;
      homeProvider.selectedIndex = 0;
      homeProvider.isComeFromLinkOrNotification = true;
      homeProvider.isHomeLoading = true;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            navigatorKey: mainNavigatorKey,
            home: const Scaffold(body: Text('Base Screen')),
          ),
        ),
      );

      final uri = Uri.parse('https://app.bigtv24x7.com/events?eventId=test-123');
      await homeProvider.routeDeepLink(uri);
      await tester.pump(const Duration(milliseconds: 100));

      // Config API was called
      expect(homeProvider.getAppConfigCalled, isTrue);
      // folkNight evaluated to false
      expect(homeProvider.folkNight, isFalse);
      // Lands directly on Home Screen Tab 1
      expect(homeProvider.selectedIndex, 1);
      // Link/loading states reset
      expect(homeProvider.isHomeLoading, isFalse);
      expect(homeProvider.isComeFromLinkOrNotification, isFalse);
      // All posts API triggered
      expect(homeProvider.getAllPostCalled, isTrue);
      // Does not push FolkNightEventScreen
      expect(find.text('Base Screen'), findsOneWidget);
    });

    testWidgets('Folk Night deep link hits config API; if folkNight is true, routes to FolkNightEventScreen', (tester) async {
      final homeProvider = _MockConfigHomeProvider();
      homeProvider.mockFolkNightValue = true;
      homeProvider.folkNight = false; // initially false, will become true from getAppConfig
      homeProvider.eventsEnable = true;
      homeProvider.isHomeScreen = true;
      homeProvider.selectedIndex = 0;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            navigatorKey: mainNavigatorKey,
            home: const Scaffold(body: Text('Base Screen')),
          ),
        ),
      );

      final uri = Uri.parse('https://app.bigtv24x7.com/events?eventId=test-123');
      await homeProvider.routeDeepLink(uri);
      await tester.pump(const Duration(milliseconds: 100));

      expect(homeProvider.getAppConfigCalled, isTrue);
      expect(homeProvider.folkNight, isTrue);
      expect(homeProvider.selectedIndex, 1);
    });

    testWidgets('Folk Night share button triggers ContentShareDispatcher with event details', (tester) async {
      String? capturedShareText;
      String? capturedSubject;

      ContentShareDispatcher.debugShareOverride = ({
        required String shareText,
        required String subject,
        required bool isWhatsAppOnly,
        String? imagePath,
      }) async {
        capturedShareText = shareText;
        capturedSubject = subject;
      };

      addTearDown(() {
        ContentShareDispatcher.debugShareOverride = null;
      });

      final homeProvider = _MockConfigHomeProvider();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          builder: (context, _) => ChangeNotifierProvider<HomeProvider>.value(
            value: homeProvider,
            child: const MaterialApp(
              home: FolkNightEventScreen(initialLoading: false, autoFetch: false),
            ),
          ),
        ),
      );
      await tester.pump();

      final shareBtn = find.byKey(const Key('folk_night_share_button'));
      expect(shareBtn, findsOneWidget);

      await tester.tap(shareBtn);
      await tester.pump();

      expect(capturedShareText, isNotNull);
      expect(capturedShareText, contains('Folk Night'));
      expect(capturedShareText, contains('https://app.bigtv24x7.com/events'));
      expect(capturedSubject, contains('Folk Night'));
    });
  });
}

