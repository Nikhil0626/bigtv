import 'dart:async';

import 'package:chotanews/aggricator_screens/individual_post_details/individual_post_view.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/screens/search_discover_screen.dart';
import 'package:chotanews/features/notifications/data/models/app_notification_model.dart';
import 'package:chotanews/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubNotificationHomeProvider extends HomeProvider {
  Completer<void>? fetchCompleter;
  String? requestedPostId;

  @override
  Future<void> getIndividualPost(
    dynamic postId, {
    bool isAds = false,
    bool isLink = false,
  }) async {
    requestedPostId = postId?.toString();
    clearSinglePost();
    if (fetchCompleter != null) {
      await fetchCompleter!.future;
    }
    getSinglePostList = {
      'id': int.tryParse(postId.toString()) ?? postId,
      'title': 'Actual Post Title',
      'content': 'Actual full news body from API.',
      'type': 'Standard',
      'subType': 'Standard',
      'image_url': '',
      'categoryName': ['వార్తలు'],
    };
    isPostLoading = false;
    notifyListeners();
  }
}

class _StubNotificationsProvider extends NotificationsProvider {
  final List<AppNotificationModel> _items;
  _StubNotificationsProvider(this._items);

  @override
  List<AppNotificationModel> get notifications => _items;

  @override
  List<AppNotificationModel> get filteredNotifications => _items;

  @override
  bool get isLoading => false;

  @override
  bool get isLoadingMore => false;

  @override
  bool get hasMore => false;

  @override
  Future<void> fetchNotifications({
    bool isRefresh = false,
    String? languageCode,
  }) async {}

  @override
  Future<void> loadMore() async {}
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'selectedLanguageCode': 'te',
      'loginType': 'guest',
    });
  });

  testWidgets(
      'IndividualPostView1 waits for actual post instead of showing stale post when no initialArticle is passed',
      (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final completer = Completer<void>();
    final homeProvider = _StubNotificationHomeProvider()
      ..fetchCompleter = completer
      ..getSinglePostList = {
        'id': 100,
        'title': 'Previous Cached Post Title',
        'content': 'Previous Cached Post Content',
        'type': 'Standard',
      };

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        builder: (_, __) => MultiProvider(
          providers: [
            ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
            ChangeNotifierProvider<VideoProvider>(
              create: (_) => VideoProvider(),
            ),
            ChangeNotifierProvider<BookmarksProvider>(
              create: (_) => BookmarksProvider(),
            ),
            ChangeNotifierProvider<AuthenticationProvider>(
              create: (_) => AuthenticationProvider(),
            ),
          ],
          child: const MaterialApp(
            home: IndividualPostView1(
              postId: '200',
              isComeFrom: true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(AppLoadingScreen), findsOneWidget);
    expect(find.text('Previous Cached Post Title'), findsNothing);

    completer.complete();
    await tester.pump();
    await tester.pump();

    expect(homeProvider.requestedPostId, equals('200'));
    expect(find.text('Actual Post Title'), findsOneWidget);
  });

  testWidgets(
      'Notifications tab post tap opens IndividualPostView1 without flashing notification title/content',
      (tester) async {
    tester.view.physicalSize = const Size(1236, 2745);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final completer = Completer<void>();
    final homeProvider = _StubNotificationHomeProvider()
      ..langCode = 'te'
      ..fetchCompleter = completer;

    final notif = AppNotificationModel(
      id: 'n1',
      title: 'Notification Teaser Title',
      content: 'Notification Teaser Body',
      postId: 305,
      link: 'https://app.bigtv24x7.com/individualPage?postId=305',
      imageUrl: '',
    );
    final notifProvider = _StubNotificationsProvider([notif]);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(420, 690),
        builder: (_, __) => MultiProvider(
          providers: [
            ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
            ChangeNotifierProvider<NotificationsProvider>.value(
              value: notifProvider,
            ),
            ChangeNotifierProvider<VideoProvider>(
              create: (_) => VideoProvider(),
            ),
            ChangeNotifierProvider<BookmarksProvider>(
              create: (_) => BookmarksProvider(),
            ),
            ChangeNotifierProvider<AuthenticationProvider>(
              create: (_) => AuthenticationProvider(),
            ),
          ],
          child: const MaterialApp(
            home: SearchDiscoverScreen(),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Switch to Notifications tab
    await tester.tap(find.text('నోటిఫికేషన్‌లు'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Notification Teaser Title'), findsOneWidget);

    // Tap the notification card
    await tester.tap(find.text('Notification Teaser Title'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // On IndividualPostView1 while loading, notification teaser title/content must NOT be shown
    expect(find.byType(IndividualPostView1), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(IndividualPostView1),
        matching: find.text('Notification Teaser Title'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: find.byType(IndividualPostView1),
        matching: find.byType(AppLoadingScreen),
      ),
      findsOneWidget,
    );

    completer.complete();
    await tester.pump();
    await tester.pump();

    expect(homeProvider.requestedPostId, equals('305'));
    expect(
      find.descendant(
        of: find.byType(IndividualPostView1),
        matching: find.text('Actual Post Title'),
      ),
      findsOneWidget,
    );
  });
}

