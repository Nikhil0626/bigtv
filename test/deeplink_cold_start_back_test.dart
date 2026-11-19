import 'dart:async';
import 'dart:io';
import 'package:chotanews/aggricator_screens/individual_post_details/individual_post_view.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:chotanews/features/events/presentation/screens/folk_night_event_screen.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:chotanews/services/register_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeHomeProvider extends HomeProvider {
  bool getAllPostCalled = false;
  bool isGetAllPostFlag = false;

  @override
  Future<void> getAppConfig() async {
    // No-op for tests: keeps the preset folkNight value
  }

  @override
  Future<void> getAllPost({String postIds = "0", bool isGetAllPost = false}) async {
    getAllPostCalled = true;
    isGetAllPostFlag = isGetAllPost;
    isHomeLoading = false;
    isInitialHomeLoaded = true;
    getAllPostList = [
      {
        'id': 101,
        'title': 'Test Home Article',
        'type': 'Standard',
        'subType': 'Standard',
        'content': 'Test content for home news feed.',
      }
    ];
    notifyListeners();
  }

  @override
  Future<bool> getIndividualPost(
    dynamic postId, {
    bool isAds = false,
    bool isLink = false,
  }) async {
    clearSinglePost();
    getSinglePostList = {
      'id': int.tryParse(postId.toString()) ?? 19604,
      'title': 'Deep Link Post Title',
      'content': 'Full content for deep link post.',
      'type': 'Standard',
      'subType': 'Standard',
      'image_url': '',
    };
    isPostLoading = false;
    notifyListeners();
    return true;
  }
}

class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = _TestHttpOverrides();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'selectedLanguageCode': 'te',
      'userId': '1',
      'deviceId': 'test_device',
    });
  });

  testWidgets('Scenario 1: Folk Night event screen back navigation resets link state and loads home feed',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final homeProvider = _FakeHomeProvider();
    homeProvider.folkNight = true;
    homeProvider.isComeFromLinkOrNotification = true;
    homeProvider.isHomeLoading = true;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
          ChangeNotifierProvider<VideoProvider>(create: (_) => VideoProvider()),
          ChangeNotifierProvider<BookmarksProvider>(create: (_) => BookmarksProvider()),
          ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MaterialApp(
            navigatorKey: mainNavigatorKey,
            home: const Scaffold(body: Text('Root Screen')),
          ),
        ),
      ),
    );
    await tester.pump();

    // Push FolkNightEventScreen
    mainNavigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => const FolkNightEventScreen(autoFetch: false, initialLoading: false)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FolkNightEventScreen), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Tap back button on FolkNightEventScreen
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Screen should be popped
    expect(find.byType(FolkNightEventScreen), findsNothing);
    // Link states should be cleanly reset and posts loaded
    expect(homeProvider.isComeFromLinkOrNotification, isFalse);
    expect(homeProvider.isHomeLoading, isFalse);
    expect(homeProvider.getAllPostCalled, isTrue);
  });

  testWidgets('Scenario 2: IndividualPostView1 back button can be clicked and cleans up navigation state',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final homeProvider = _FakeHomeProvider();
    homeProvider.isComeFromLinkOrNotification = true;
    homeProvider.getAllPostList = [];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
          ChangeNotifierProvider<VideoProvider>(create: (_) => VideoProvider()),
          ChangeNotifierProvider<BookmarksProvider>(create: (_) => BookmarksProvider()),
          ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MaterialApp(
            navigatorKey: mainNavigatorKey,
            home: const Scaffold(body: Text('Home Screen Placeholder')),
          ),
        ),
      ),
    );
    await tester.pump();

    // Push IndividualPostView1 as done by routeDeepLink on cold start
    mainNavigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => const IndividualPostView1(postId: "19604", isComeFrom: true),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(IndividualPostView1), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // IndividualPostView1 is popped cleanly
    expect(find.byType(IndividualPostView1), findsNothing);
    expect(homeProvider.isComeFromLinkOrNotification, isFalse);
    expect(homeProvider.isHomeLoading, isFalse);
    expect(homeProvider.selectedIndex, 1);
    expect(homeProvider.getAllPostCalled, isTrue);
    expect(homeProvider.isGetAllPostFlag, isTrue);
  });

  testWidgets(
      'Scenario 4: When user taps back on IndividualPostView1, return to home screen and hit allpost API even if posts already exist',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final homeProvider = _FakeHomeProvider();
    homeProvider.selectedIndex = 0;
    homeProvider.getAllPostList = [
      {'id': 1, 'title': 'Existing Post'}
    ];
    homeProvider.getAllPostCalled = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
          ChangeNotifierProvider<VideoProvider>(create: (_) => VideoProvider()),
          ChangeNotifierProvider<BookmarksProvider>(create: (_) => BookmarksProvider()),
          ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MaterialApp(
            navigatorKey: mainNavigatorKey,
            home: const Scaffold(body: Text('Home Screen Placeholder')),
          ),
        ),
      ),
    );
    await tester.pump();

    // Push IndividualPostView1
    mainNavigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => const IndividualPostView1(postId: "19604", isComeFrom: false),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(IndividualPostView1), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Popped cleanly and returned to home screen
    expect(find.byType(IndividualPostView1), findsNothing);
    expect(homeProvider.selectedIndex, 1);
    expect(homeProvider.getAllPostCalled, isTrue);
    expect(homeProvider.isGetAllPostFlag, isTrue);
    expect(homeProvider.getAllPostList.isNotEmpty, isTrue);
  });

  testWidgets(
      'Scenario 3: When user clicks folk night back, navigate to home screen and hit allpost api even if posts already exist',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final homeProvider = _FakeHomeProvider();
    homeProvider.folkNight = true;
    homeProvider.selectedIndex = 0;
    homeProvider.getAllPostList = [
      {'id': 1, 'title': 'Existing Post'}
    ];
    homeProvider.getAllPostCalled = false;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
          ChangeNotifierProvider<VideoProvider>(create: (_) => VideoProvider()),
          ChangeNotifierProvider<BookmarksProvider>(create: (_) => BookmarksProvider()),
          ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MaterialApp(
            navigatorKey: mainNavigatorKey,
            home: const Scaffold(body: Text('Root Screen')),
          ),
        ),
      ),
    );
    await tester.pump();

    mainNavigatorKey.currentState!.push(
      MaterialPageRoute(builder: (_) => const FolkNightEventScreen(autoFetch: false, initialLoading: false)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(FolkNightEventScreen), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(FolkNightEventScreen), findsNothing);
    // Home tab must be selected (tab 1)
    expect(homeProvider.selectedIndex, 1);
    // allpost API must have been hit
    expect(homeProvider.getAllPostCalled, isTrue);
    expect(homeProvider.isGetAllPostFlag, isTrue);
  });

  testWidgets(
      'Scenario 5: When cold start has pending deep link, isPageNavigation bypasses getAllPost to prioritize individual post',
      (tester) async {
    final homeProvider = _FakeHomeProvider();
    homeProvider.isComeFromLinkOrNotification = true;
    homeProvider.getAllPostList = [];
    homeProvider.getAllPostCalled = false;

    final authProvider = AuthenticationProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ...AppProviders.all.where((p) => p is! ChangeNotifierProvider<HomeProvider>),
          ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
        ],
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MaterialApp(
            navigatorKey: mainNavigatorKey,
            home: Builder(
              builder: (context) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => authProvider.isPageNavigation(context),
                  child: const Text('Navigate'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Set loginState to home
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('loginState', 'NewAppLoginStatus.home');

    // Trigger isPageNavigation
    await tester.tap(find.text('Navigate'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify getAllPost was BYPASSED
    expect(homeProvider.getAllPostCalled, isFalse);
    expect(homeProvider.selectedIndex, 1);
  });
}
