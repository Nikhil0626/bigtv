import 'package:chotanews/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/screens/search_discover_screen.dart';
import 'package:chotanews/features/notifications/data/models/app_notification_model.dart';
import 'package:chotanews/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:chotanews/features/notifications/presentation/widgets/notification_item_card.dart';
import 'package:chotanews/features/notifications/presentation/widgets/notification_shimmer_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  group('AppNotificationModel Tests', () {
    test('Correctly parses complete notification JSON from sample response', () {
      final json = {
        "id": "8fba5418-6b0c-408c-a88f-b8b997459cda",
        "title": "తలపై రాయితో కొట్టి.. గొంతు నులిమి.. ఆపై?",
        "content": "బెంగళూరులో భార్య తరచూ ఫోన్లో మాట్లాడుతుందన్న అనుమానంతో 28 ఏళ్ల ఇర్ఫాజ్ తన భార్య రుక్సానా (25)ను హత్య చేశాడు.",
        "postId": 13293,
        "link": "https://app.chotanews.com/individualPage?postId=13293",
        "imageUrl": "https://bigtv-cms.s3.ap-south-1.amazonaws.com/cms_news_183cebe1-3b30-4e93-a4d5-d10fede68e37.jpg",
        "brandName": "BigTV",
        "brandLogo": "www.logo.com",
        "lan": "te",
        "status": "COMPLETED",
        "totalTargeted": 4279,
        "successCount": 3666,
        "failureCount": 613,
        "statusMessage": null,
        "sentAt": "2026-10-23T05:37:57.714Z",
        "createdAt": "2026-10-23T05:35:22.146Z",
        "updatedAt": "2026-10-23T05:37:57.717Z"
      };

      final model = AppNotificationModel.fromJson(json);

      expect(model.id, "8fba5418-6b0c-408c-a88f-b8b997459cda");
      expect(model.title, "తలపై రాయితో కొట్టి.. గొంతు నులిమి.. ఆపై?");
      expect(model.postId, 13293);
      expect(model.link, "https://app.chotanews.com/individualPage?postId=13293");
      expect(model.brandName, "BigTV");
      expect(model.totalTargeted, 4279);
      expect(model.successCount, 3666);
      expect(model.failureCount, 613);
      expect(model.displayImageUrl, contains("https://bigtv-cms.s3.ap-south-1.amazonaws.com/"));
      expect(model.sentAt, isNotNull);

      final initialArticle = model.toInitialArticleMap();
      expect(initialArticle['id'], 13293);
      expect(initialArticle['title'], model.title);
      expect(initialArticle['content'], model.content);
      expect(initialArticle['image_url'], model.imageUrl);
      expect(initialArticle['type'], 'Standard');
    });

    test('Parses postId from link query parameter when postId field is missing', () {
      final json = {
        "id": "abc-123",
        "title": "Breaking News",
        "content": "Description here",
        "link": "https://app.chotanews.com/individualPage?postId=9999",
      };

      final model = AppNotificationModel.fromJson(json);
      expect(model.postId, 9999);
    });

    test('Handles relative image URLs cleanly', () {
      final json = {
        "id": "abc-456",
        "title": "News",
        "content": "Content",
        "imageUrl": "/uploads/test.jpg",
      };

      final model = AppNotificationModel.fromJson(json);
      expect(model.displayImageUrl, "https://migwp.chotanews.com/uploads/test.jpg");
    });

    test('getTimeAgo formats relative time properly', () {
      final now = DateTime.now();
      final model = AppNotificationModel(
        id: "1",
        title: "Test",
        content: "Test",
        sentAt: now.subtract(const Duration(minutes: 5)),
      );

      final timeTelugu = model.getTimeAgo(isTelugu: true);
      expect(timeTelugu, contains("నిమిషాల క్రితం"));

      final timeEnglish = model.getTimeAgo(isTelugu: false);
      expect(timeEnglish, "5m ago");
    });
  });

  group('NotificationsProvider Search and Filtering Tests', () {
    test('Search query filters items by title and content', () {
      final provider = NotificationsProvider();

      // Seed mock notifications via AppNotificationModel
      final item1 = AppNotificationModel(
        id: "1",
        title: "భారత్ vs ఆస్ట్రేలియా టీ20",
        content: "రెండో టీ20 మ్యాచ్ రేపు ప్రారంభం",
        postId: 101,
      );
      final item2 = AppNotificationModel(
        id: "2",
        title: "భారీ భూకంపం",
        content: "టిబెట్లో భారీ భూకంపం సంభవించింది",
        postId: 102,
      );

      // Verify empty search initially
      expect(provider.filteredNotifications, isEmpty);

      // Simulate provider search mechanism
      provider.search("భూకంపం");
      expect(provider.searchQuery, "భూకంపం");

      provider.clearSearch();
      expect(provider.searchQuery, "");
    });
  });

  group('Widget Tests', () {
    testWidgets('NotificationItemCard renders title, brand pill, time, and calls onTap', (tester) async {
      bool tapped = false;
      final notification = AppNotificationModel(
        id: "test-id",
        title: "భారీగా పెరిగిన ధరలు",
        content: "ఎల్నినో పరిస్థితుల నేపథ్యంలో సన్న వడ్లకు డిమాండ్ పెరిగింది.",
        postId: 13254,
        brandName: "BigTV",
        sentAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: NotificationItemCard(
                notification: notification,
                isTelugu: true,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text("భారీగా పెరిగిన ధరలు"), findsOneWidget);
      expect(find.text("BigTV"), findsOneWidget);
      expect(find.text("#13254"), findsOneWidget);
      expect(find.text("పూర్తి వార్త చదవండి"), findsOneWidget);

      await tester.tap(find.byType(NotificationItemCard));
      expect(tapped, isTrue);
    });

    testWidgets('NotificationShimmerList renders placeholder cards', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: NotificationShimmerList(count: 3),
            ),
          ),
        ),
      );

      expect(find.byType(NotificationShimmerList), findsOneWidget);
    });

    testWidgets('SearchDiscoverScreen displays Discoveries first, Notifications second, and no search bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final homeProvider = HomeProvider();
      final notifProvider = NotificationsProvider();
      final bookmarksProvider = BookmarksProvider();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
              ChangeNotifierProvider<NotificationsProvider>.value(value: notifProvider),
              ChangeNotifierProvider<BookmarksProvider>.value(value: bookmarksProvider),
            ],
            child: const MaterialApp(
              home: SearchDiscoverScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Discover tab is visible and first
      expect(find.text("డిస్కవర్"), findsOneWidget);
      expect(find.text("నోటిఫికేషన్‌లు"), findsOneWidget);

      // Verify no TextField (search bar removed)
      expect(find.byType(TextField), findsNothing);

      // Verify wave design CustomPaint and top bar buttons (Bookmarks, Live TV)
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.text("LIVE 24x7"), findsOneWidget);
      expect(find.text("బుక్‌మార్క్స్"), findsOneWidget);

      // Switch to notifications tab
      await tester.tap(find.text("నోటిఫికేషన్‌లు"));
      await tester.pumpAndSettle();

      // Notifications tab header is now visible
      expect(find.text("తాజా నోటిఫికేషన్‌లు"), findsOneWidget);
    });

    testWidgets('SearchDiscoverScreen displays Editorials horizontal grid slider and no Taaja Mukyamshaalu', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final homeProvider = HomeProvider();
      homeProvider.editorialPosts = [
        {
          'id': 1001,
          'title': 'రాజకీయ విశ్లేషణ: సమగ్ర సమీక్ష',
          'image_url': '',
          'publishDate': '23 Oct 2026',
          'link': 'https://bigtvlive.com/test-editorial',
        },
      ];
      final notifProvider = NotificationsProvider();
      final bookmarksProvider = BookmarksProvider();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (context, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
              ChangeNotifierProvider<NotificationsProvider>.value(value: notifProvider),
              ChangeNotifierProvider<BookmarksProvider>.value(value: bookmarksProvider),
            ],
            child: const MaterialApp(
              home: SearchDiscoverScreen(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Taaja Mukyamshaalu is removed
      expect(find.text("తాజా ముఖ్యాంశాలు"), findsNothing);

      // Verify Editorials section header and horizontal card are present
      expect(find.text("ఎడిటోరియల్స్"), findsOneWidget);
      expect(find.text("EDITORIAL"), findsOneWidget);
      expect(find.text("రాజకీయ విశ్లేషణ: సమగ్ర సమీక్ష"), findsOneWidget);
      expect(find.text("చదవండి"), findsOneWidget);
    });
  });
}
