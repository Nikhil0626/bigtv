import 'dart:convert';
import 'dart:io';

import 'package:chotanews/aggricator_screens/polls_screens/poll_model.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_repo.dart';
import 'package:chotanews/aggricator_screens/polls_screens/polls_view/polls_feed_screen.dart';
import 'package:chotanews/aggricator_screens/polls_screens/polls_view/polls_screen.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_model.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_repo/rating_repo.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_view/movie_reviews.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_view/movie_reviews_screen.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';
import 'package:chotanews/core/theme/app_theme.dart';
import 'package:chotanews/core/widgets/content_share_buttons.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:chotanews/services/content_share_dispatcher.dart';
import 'package:chotanews/services/movie_review_share_helper.dart';
import 'package:chotanews/services/poll_share_helper.dart';
import 'package:chotanews/widgets/clean_youtube_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class FakeRatingRepo extends RatingRepo {
  bool shouldSucceed;
  bool throwDio;
  Map<String, dynamic> reviewsPayload;

  FakeRatingRepo({
    this.shouldSucceed = true,
    this.throwDio = false,
    Map<String, dynamic>? reviewsPayload,
  }) : reviewsPayload = reviewsPayload ??
            {
              'overall_rating': 4.2,
              'critic_rating': 3.5,
              'total_reviews': 2,
              'movie_platform_ratings': [
                {'platform_name': 'IMDb', 'platform_rating': '7.8/10'},
                {'platform_name': 'BMS', 'platform_rating': '84%'},
              ],
              'reviews': [
                {
                  'user': {'name': 'Ravi'},
                  'comment': 'Great visual spectacle!',
                  'rating': 4,
                  'created_at': DateTime.now().toUtc().toIso8601String(),
                },
              ],
            };

  @override
  Future postSubmitRating(body) async {
    if (throwDio) {
      throw DioException(
        requestOptions: RequestOptions(path: '/moviereviews/submit'),
        response: Response(
          requestOptions: RequestOptions(path: '/moviereviews/submit'),
          statusCode: 400,
          data: {'message': 'Submission failed'},
        ),
      );
    }
    return Response(
      requestOptions: RequestOptions(path: '/moviereviews/submit'),
      statusCode: shouldSucceed ? 200 : 400,
      data: {
        'message': shouldSucceed ? 'Rating submitted' : 'Rating failed',
      },
    );
  }

  @override
  Future getReviews(dynamic postId, [Map<String, dynamic>? queryParams]) async {
    return Response(
      requestOptions: RequestOptions(path: '/moviereviews/$postId'),
      statusCode: 200,
      data: reviewsPayload,
    );
  }
}

class FakePollRepo extends PollRepo {
  bool shouldSucceed;
  bool throwDio;
  Map<String, dynamic> resultsPayload;

  FakePollRepo({
    this.shouldSucceed = true,
    this.throwDio = false,
    Map<String, dynamic>? resultsPayload,
  }) : resultsPayload = resultsPayload ??
            {
              'totalVotes': 120,
              'userHasVoted': true,
              'userVotedOption': 1,
              'options': [
                {'id': 1, 'text': 'Yes', 'votes': 80, 'percentage': 66.7},
                {'id': 2, 'text': 'No', 'votes': 40, 'percentage': 33.3},
              ],
            };

  @override
  Future submitPolls(body) async {
    if (throwDio) {
      throw DioException(
        requestOptions: RequestOptions(path: '/polls/submit'),
        response: Response(
          requestOptions: RequestOptions(path: '/polls/submit'),
          statusCode: 500,
          data: {'message': 'Server error'},
        ),
      );
    }
    return Response(
      requestOptions: RequestOptions(path: '/polls/submit'),
      statusCode: shouldSucceed ? 200 : 400,
      data: {'message': shouldSucceed ? 'Vote recorded' : 'Vote failed'},
    );
  }

  @override
  Future getPollResults(dynamic postId, {dynamic userId}) async {
    return Response(
      requestOptions: RequestOptions(path: '/polls/$postId/results'),
      statusCode: 200,
      data: resultsPayload,
    );
  }

  @override
  Future getAllPollComments(id) async {
    return Response(
      requestOptions: RequestOptions(path: '/polls/$id'),
      statusCode: 200,
      data: {
        'options': [
          {'option_text': 'Yes', 'percentage': 67},
          {'option_text': 'No', 'percentage': 33},
        ],
        'comments': [],
      },
    );
  }
}

class TestHomeProvider extends HomeProvider {
  List<Map<String, dynamic>> stubReviews = [];
  List<Map<String, dynamic>> stubPolls = [];
  int fetchReviewsCallCount = 0;
  int fetchPollsCallCount = 0;

  @override
  List<Map<String, dynamic>> getAllMovieReviews() => stubReviews;

  @override
  List<Map<String, dynamic>> getAllPolls() => stubPolls;

  @override
  Future<void> fetchDynamicMovieReviews({bool refresh = false}) async {
    fetchReviewsCallCount++;
  }

  @override
  Future<void> fetchDynamicPolls({bool refresh = false}) async {
    fetchPollsCallCount++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempHiveDir;
  late Directory tempShareDir;

  setUpAll(() async {
    tempHiveDir = Directory.systemTemp.createTempSync('hive_poll_review_test');
    tempShareDir = Directory.systemTemp.createTempSync('share_tmp_test');
    Hive.init(tempHiveDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    try {
      tempHiveDir.deleteSync(recursive: true);
    } catch (_) {}
    try {
      tempShareDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'selectedLanguageCode': 'te',
      'userId': '42',
      'deviceId': 'dev_123',
      'userName': 'Suresh',
      'loginType': 'login',
    });
    ContentShareDispatcher.debugShareOverride = null;
  });

  tearDown(() {
    ContentShareDispatcher.debugShareOverride = null;
  });

  void setPhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  Widget wrapWidget({
    required Widget child,
    RatingProvider? ratingProvider,
    PollProvider? pollProvider,
    HomeProvider? homeProvider,
    ThemeData? theme,
  }) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (context, _) => MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeProvider>(
            create: (_) => homeProvider ?? TestHomeProvider(),
          ),
          ChangeNotifierProvider<RatingProvider>(
            create: (_) =>
                ratingProvider ?? RatingProvider(ratingRepo: FakeRatingRepo()),
          ),
          ChangeNotifierProvider<PollProvider>(
            create: (_) =>
                pollProvider ?? PollProvider(pollRepo: FakePollRepo()),
          ),
          ChangeNotifierProvider<AuthenticationProvider>(
            create: (_) => AuthenticationProvider(),
          ),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.darkTheme,
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  group('AnalyticsEventName Share Constants', () {
    test('defines movieReviewShare and pollShare event names', () {
      expect(AnalyticsEventName.movieReviewShare, equals('movie_review_share'));
      expect(AnalyticsEventName.pollShare, equals('poll_share'));
    });
  });

  group('MovieReviewShareHelper Unit Tests', () {
    final sampleReview = <String, dynamic>{
      'id': 1051,
      'movie_name': 'Devara',
      'chotaMeter': '3.5/5',
      'genre': 'యాక్షన్',
      'certification': 'UA',
      'description': 'High-octane coastal action drama with strong visuals.',
      'image_url': '/uploads/devara.jpg',
    };

    test('generates canonical app.bigtv24x7.com deep link URLs', () {
      expect(
        MovieReviewShareHelper.baseUrl,
        equals('https://app.bigtv24x7.com'),
      );
      expect(
        MovieReviewShareHelper.getMovieReviewShareUrl(1051),
        equals('https://app.bigtv24x7.com/moviereviews?postId=1051'),
      );
      expect(
        MovieReviewShareHelper.getMovieReviewShareUrl(null),
        equals('https://app.bigtv24x7.com/moviereviews'),
      );
      expect(
        MovieReviewShareHelper.getMovieReviewShareUrl('0'),
        equals('https://app.bigtv24x7.com/moviereviews'),
      );
    });

    test('resolves relative and absolute poster URLs', () {
      expect(
        MovieReviewShareHelper.resolveImageUrl('/posters/a.jpg'),
        equals('https://migwp.chotanews.com/posters/a.jpg'),
      );
      expect(
        MovieReviewShareHelper.resolveImageUrl('posters/a.jpg'),
        equals('https://migwp.chotanews.com/posters/a.jpg'),
      );
      expect(
        MovieReviewShareHelper.resolveImageUrl('https://cdn.example.com/a.jpg'),
        equals('https://cdn.example.com/a.jpg'),
      );
      expect(MovieReviewShareHelper.resolveImageUrl(null), equals(''));
    });

    test('builds localized share text for te, ml, and en with synopsis truncation', () {
      final longSynopsisArticle = {
        ...sampleReview,
        'description': 'A' * 200,
      };

      final teText = MovieReviewShareHelper.getShareText(
        article: longSynopsisArticle,
        langCode: 'te',
      );
      expect(teText, contains('🎬 Devara'));
      expect(teText, contains('⭐ BIG TV రేటింగ్: 3.5/5'));
      expect(teText, contains('🎭 యాక్షన్ • UA'));
      expect(teText, contains('...'));
      expect(
        teText,
        contains('https://app.bigtv24x7.com/moviereviews?postId=1051'),
      );

      final mlText = MovieReviewShareHelper.getShareText(
        article: sampleReview,
        langCode: 'ml',
      );
      expect(mlText, contains('⭐ BIG TV റേറ്റിംഗ്: 3.5/5'));
      expect(
        mlText,
        contains('https://app.bigtv24x7.com/moviereviews?postId=1051'),
      );

      final enText = MovieReviewShareHelper.getShareText(
        article: {'id': 200, 'title': 'Kalki 2898 AD'},
        ratingDetails: MovieReviewDetails(
          overallRating: 4.4,
          criticRating: 4.0,
          platformRatings: const [],
          totalReviews: 12,
        ),
        langCode: 'en',
      );
      expect(enText, contains('🎬 Kalki 2898 AD'));
      expect(enText, contains('⭐ BIG TV Rating: 4.0/5'));
      expect(
        enText,
        contains('https://app.bigtv24x7.com/moviereviews?postId=200'),
      );
    });

    testWidgets('shareMovieReview dispatches text, analytics, and target mode',
        (tester) async {
      String? capturedText;
      String? capturedSubject;
      bool? capturedWhatsApp;

      final fakeDispatcher = ContentShareDispatcher(
        httpClient: MockClient((_) async => http.Response('', 404)),
        tempDirectoryProvider: () async => tempShareDir,
        canLaunchUrlFn: (_) async => false,
        shareTextFn: (text, {subject, sharePositionOrigin}) async {
          capturedText = text;
          capturedSubject = subject;
        },
      );

      await tester.pumpWidget(
        wrapWidget(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                MovieReviewShareHelper.shareMovieReview(
                  context: ctx,
                  article: sampleReview,
                  isWhatsAppOnly: false,
                  dispatcher: fakeDispatcher,
                );
              },
              child: const Text('Trigger'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Trigger'));
      await tester.pumpAndSettle();

      expect(capturedText, contains('Devara'));
      expect(
        capturedText,
        contains('https://app.bigtv24x7.com/moviereviews?postId=1051'),
      );
      expect(capturedSubject, equals('Devara - BIG TV Movie Review'));

      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('analytics_event_queue') ?? [];
      expect(queue, isNotEmpty);
      final event = jsonDecode(queue.last) as Map<String, dynamic>;
      expect(event['eventName'], equals('movie_review_share'));
      expect(event['properties']['post_id'], equals('1051'));
      expect(event['properties']['share_target'], equals('system_share'));
      expect(capturedWhatsApp, isNull);
    });
  });

  group('PollShareHelper Unit Tests', () {
    final samplePoll = <String, dynamic>{
      'id': 1050,
      'title': 'Who will win the upcoming debate?',
      'category': 'రాజకీయాలు',
      'image_url': '/uploads/poll.jpg',
      'pollData': {
        'totalVotes': 1420,
        'userHasVoted': false,
        'options': [
          {'id': 1, 'text': 'Party A', 'votes': 800, 'percentage': 56.3},
          {'id': 2, 'text': 'Party B', 'votes': 620, 'percentage': 43.7},
        ],
      },
    };

    test('generates canonical app.bigtv24x7.com deep link URLs', () {
      expect(PollShareHelper.baseUrl, equals('https://app.bigtv24x7.com'));
      expect(
        PollShareHelper.getPollShareUrl(1050),
        equals('https://app.bigtv24x7.com/polls?postId=1050'),
      );
      expect(
        PollShareHelper.getPollShareUrl(null),
        equals('https://app.bigtv24x7.com/polls'),
      );
      expect(
        PollShareHelper.getPollShareUrl('0'),
        equals('https://app.bigtv24x7.com/polls'),
      );
      expect(
        PollShareHelper.resolveImageUrl('uploads/poll.png'),
        equals('https://migwp.chotanews.com/uploads/poll.png'),
      );
      expect(
        PollShareHelper.resolveImageUrl('https://cdn.example.com/p.png'),
        equals('https://cdn.example.com/p.png'),
      );
      expect(PollShareHelper.resolveImageUrl(null), equals(''));
    });

    test('builds localized poll share text with numbered options for te, ml, en',
        () {
      final teText = PollShareHelper.getShareText(
        article: samplePoll,
        langCode: 'te',
      );
      expect(teText, contains('📊 BIG TV పోల్ (రాజకీయాలు)'));

      // Empty array/null categoryName must never render "([])"
      final emptyCatPoll = <String, dynamic>{
        'id': 295,
        'title': 'Sample Poll',
        'categoryName': [],
        'poll_options': [
          {'id': 1, 'text': 'Yes'},
        ],
      };
      final teNoCat = PollShareHelper.getShareText(
        article: emptyCatPoll,
        langCode: 'te',
      );
      expect(teNoCat, contains('📊 BIG TV పోల్\n'));
      expect(teNoCat, isNot(contains('([])')));

      final listCatPoll = <String, dynamic>{
        'id': 296,
        'title': 'List Poll',
        'categoryName': ['రాజకీయాలు'],
      };
      final teListCat = PollShareHelper.getShareText(
        article: listCatPoll,
        langCode: 'te',
      );
      expect(teListCat, contains('📊 BIG TV పోల్ (రాజకీయాలు)'));
      expect(teText, contains('Who will win the upcoming debate?'));
      expect(teText, contains('1. Party A'));
      expect(teText, contains('2. Party B'));
      expect(teText, contains('https://app.bigtv24x7.com/polls?postId=1050'));

      final fallbackOptsText = PollShareHelper.getShareText(
        article: {
          'id': 78,
          'title': 'Fallback Options',
          'poll_options': [
            {'option_name': 'Alpha'},
            {'title': 'Beta'},
          ],
        },
        isTelugu: false,
      );
      expect(fallbackOptsText, contains('1. Alpha'));
      expect(fallbackOptsText, contains('2. Beta'));

      final plainOptsText = PollShareHelper.getShareText(
        article: {
          'id': 79,
          'title': 'Plain List Poll',
          'options': ['First', 'Second'],
        },
        isTelugu: true,
      );
      expect(plainOptsText, contains('1. First'));
      expect(plainOptsText, contains('2. Second'));

      final mlText = PollShareHelper.getShareText(
        article: samplePoll,
        langCode: 'ml',
      );
      expect(mlText, contains('📊 BIG TV വോട്ടെടുപ്പ്'));
      expect(mlText, contains('https://app.bigtv24x7.com/polls?postId=1050'));

      final enText = PollShareHelper.getShareText(
        article: {'id': 77, 'title': 'Best format?'},
        pollData: PollData(
          totalVotes: 10,
          userHasVoted: true,
          options: [
            PollOption(id: 1, text: 'Test', votes: 6, percentage: 60),
            PollOption(id: 2, text: 'ODI', votes: 4, percentage: 40),
          ],
        ),
        langCode: 'en',
      );
      expect(enText, contains('📊 BIG TV Poll'));
      expect(enText, contains('1. Test'));
      expect(enText, contains('2. ODI'));
      expect(enText, contains('https://app.bigtv24x7.com/polls?postId=77'));
    });

    testWidgets('sharePoll dispatches WhatsApp share and tracks analytics',
        (tester) async {
      String? launchedUrl;
      final fakeDispatcher = ContentShareDispatcher(
        httpClient: MockClient((_) async => http.Response('', 404)),
        tempDirectoryProvider: () async => tempShareDir,
        canLaunchUrlFn: (_) async => true,
        launchUrlFn: (uri) async {
          launchedUrl = uri.toString();
          return true;
        },
      );

      await tester.pumpWidget(
        wrapWidget(
          child: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () {
                PollShareHelper.sharePoll(
                  context: ctx,
                  article: samplePoll,
                  isWhatsAppOnly: true,
                  dispatcher: fakeDispatcher,
                );
              },
              child: const Text('TriggerPoll'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('TriggerPoll'));
      await tester.pumpAndSettle();

      expect(launchedUrl, startsWith('whatsapp://send?text='));
      expect(
        Uri.decodeComponent(launchedUrl!),
        contains('https://app.bigtv24x7.com/polls?postId=1050'),
      );

      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList('analytics_event_queue') ?? [];
      final event = jsonDecode(queue.last) as Map<String, dynamic>;
      expect(event['eventName'], equals('poll_share'));
      expect(event['properties']['post_id'], equals('1050'));
      expect(event['properties']['share_target'], equals('whatsapp'));
    });
  });

  group('ContentShareDispatcher Unit Tests', () {
    testWidgets('downloads fallback image and shares file via Share.shareXFiles',
        (tester) async {
      List<XFile>? sharedFiles;
      String? sharedText;
      final fakeDispatcher = ContentShareDispatcher(
        httpClient: MockClient(
          (_) async => http.Response.bytes([1, 2, 3, 4], 200),
        ),
        tempDirectoryProvider: () async => tempShareDir,
        shareXFilesFn: (files, {text, subject, sharePositionOrigin}) async {
          sharedFiles = files;
          sharedText = text;
        },
      );

      await tester.pumpWidget(
        wrapWidget(
          child: const Center(child: Text('ShareFileHost')),
        ),
      );

      final fileCtx = tester.element(find.text('ShareFileHost'));
      await tester.runAsync(() async {
        await fakeDispatcher.shareContent(
          context: fileCtx,
          shareText: 'Hello Review',
          subject: 'Review',
          filePrefix: 'test_review',
          fallbackImageUrl: 'https://example.com/poster.png',
          isWhatsAppOnly: false,
        );
      });
      await tester.pump();

      expect(sharedFiles, isNotNull);
      expect(sharedFiles!.length, equals(1));
      expect(File(sharedFiles!.first.path).existsSync(), isTrue);
      expect(sharedText, equals('Hello Review'));
    });

    testWidgets('falls back to Share.share when WhatsApp scheme cannot launch',
        (tester) async {
      String? fallbackText;
      final fakeDispatcher = ContentShareDispatcher(
        httpClient: MockClient((_) async => http.Response('err', 500)),
        tempDirectoryProvider: () async => tempShareDir,
        canLaunchUrlFn: (_) async => false,
        shareTextFn: (text, {subject, sharePositionOrigin}) async {
          fallbackText = text;
        },
      );

      await tester.pumpWidget(
        wrapWidget(
          child: const Center(child: Text('ShareFallbackHost')),
        ),
      );

      final fallbackCtx = tester.element(find.text('ShareFallbackHost'));
      await tester.runAsync(() async {
        await fakeDispatcher.shareContent(
          context: fallbackCtx,
          shareText: 'Poll fallback text',
          subject: 'Poll',
          filePrefix: 'test_poll',
          fallbackImageUrl: 'https://example.com/broken.png',
          isWhatsAppOnly: true,
        );
      });
      await tester.pump();

      expect(fallbackText, equals('Poll fallback text'));
    });

    testWidgets(
        'dispatches WhatsApp image via shareXFiles on non-Android and falls back on network/file errors',
        (tester) async {
      List<XFile>? waFiles;
      String? textFallback;
      var throwOnDownload = false;
      final dispatcher = ContentShareDispatcher(
        httpClient: MockClient((_) async {
          if (throwOnDownload) {
            throw Exception('Network down');
          }
          return http.Response.bytes([9, 8, 7], 200);
        }),
        tempDirectoryProvider: () async {
          if (throwOnDownload) {
            throw const FileSystemException('Disk full');
          }
          return tempShareDir;
        },
        shareXFilesFn: (files, {text, subject, sharePositionOrigin}) async {
          waFiles = files;
        },
        shareTextFn: (text, {subject, sharePositionOrigin}) async {
          textFallback = text;
        },
      );

      await tester.pumpWidget(
        wrapWidget(child: const Center(child: Text('DispatcherEdgeHost'))),
      );
      final ctx = tester.element(find.text('DispatcherEdgeHost'));

      // WhatsApp with image -> uses shareXFiles on non-Android test host
      await tester.runAsync(() async {
        await dispatcher.shareContent(
          context: ctx,
          shareText: 'WA Image Text',
          subject: 'Subject',
          filePrefix: 'wa_img',
          fallbackImageUrl: 'https://example.com/wa.png',
          isWhatsAppOnly: true,
        );
      });
      expect(waFiles, isNotNull);
      expect(waFiles!.length, equals(1));

      // System share with download failure -> falls back to shareTextFn
      throwOnDownload = true;
      await tester.runAsync(() async {
        await dispatcher.shareContent(
          context: ctx,
          shareText: 'System Text Fallback',
          subject: 'Subject',
          filePrefix: 'sys_txt',
          fallbackImageUrl: 'https://example.com/wa.png',
          isWhatsAppOnly: false,
        );
      });
      expect(textFallback, equals('System Text Fallback'));
    });
  });

  group('ContentShareButtons Widget Tests', () {
    testWidgets('renders in light and dark themes and fires callbacks',
        (tester) async {
      var whatsAppTapped = 0;
      var shareTapped = 0;

      await tester.pumpWidget(
        wrapWidget(
          theme: AppTheme.lightTheme,
          child: ContentShareButtons(
            useDarkOverlay: false,
            whatsAppButtonKey: const Key('wa_btn'),
            shareButtonKey: const Key('sys_btn'),
            onShareWhatsApp: () => whatsAppTapped++,
            onShareMore: () => shareTapped++,
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('wa_btn')), findsOneWidget);
      expect(find.byKey(const Key('sys_btn')), findsOneWidget);
      expect(find.byIcon(Icons.share_rounded), findsOneWidget);

      await tester.tap(find.byKey(const Key('wa_btn')));
      await tester.tap(find.byKey(const Key('sys_btn')));
      expect(whatsAppTapped, equals(1));
      expect(shareTapped, equals(1));

      await tester.pumpWidget(
        wrapWidget(
          theme: AppTheme.darkTheme,
          child: ContentShareButtons(
            useDarkOverlay: true,
            whatsAppButtonKey: const Key('wa_btn_dark'),
            shareButtonKey: const Key('sys_btn_dark'),
            onShareWhatsApp: () => whatsAppTapped++,
            onShareMore: () => shareTapped++,
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('wa_btn_dark')), findsOneWidget);
      expect(find.byKey(const Key('sys_btn_dark')), findsOneWidget);

      await tester.pumpWidget(
        wrapWidget(
          theme: AppTheme.darkTheme,
          child: ContentShareButtons(
            useDarkOverlay: true,
            whatsAppButtonKey: const Key('wa_only_btn'),
            shareButtonKey: const Key('sys_only_btn'),
            onShareWhatsApp: () => whatsAppTapped++,
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(const Key('wa_only_btn')), findsOneWidget);
      expect(find.byKey(const Key('sys_only_btn')), findsNothing);
      expect(find.byIcon(Icons.share_rounded), findsNothing);
    });
  });

  group('RatingProvider Unit Tests (State Management & Review Flow)', () {
    test('manages editing, submitting, userComment, userName, and feed state without setState',
        () async {
      final trackedEvents = <String>[];
      final provider = RatingProvider(
        ratingRepo: FakeRatingRepo(shouldSucceed: true),
        eventTracker: (_, name) async => trackedEvents.add(name),
      );

      await provider.loadUserName();
      expect(provider.userName, equals('Suresh'));

      // Feed view transitions
      provider.initFeedView(initialIndex: 1);
      expect(provider.currentReviewIndex, equals(1));
      expect(provider.isGridView, isFalse);

      provider.setGridView(true);
      expect(provider.isGridView, isTrue);

      provider.selectReviewFromGrid(3);
      expect(provider.currentReviewIndex, equals(3));
      expect(provider.isGridView, isFalse);

      // Per-post editing and validation
      provider.setUserComment(101, 'Old comment');
      provider.toggleEditingForPost(101);
      expect(provider.isEditingForPost(101), isTrue);
      expect(provider.getCommentControllerForPost(101).text, equals('Old comment'));

      // Empty comment validation fails cleanly
      provider.getCommentControllerForPost(101).text = '   ';
      final emptySubmit = await provider.submitReviewForArticle(
        articleId: 101,
        userHasReviewed: false,
        title: 'Devara',
        fallbackRating: 0,
      );
      expect(emptySubmit, isFalse);

      // Missing rating validation fails cleanly
      provider.getCommentControllerForPost(101).text = 'Super movie';
      final noRatingSubmit = await provider.submitReviewForArticle(
        articleId: 101,
        userHasReviewed: false,
        title: 'Devara',
        fallbackRating: 0,
      );
      expect(noRatingSubmit, isFalse);

      // Valid rating + comment succeeds and transitions state
      provider.ratingUpdate(4, 101);
      final okSubmit = await provider.submitReviewForArticle(
        articleId: 101,
        userHasReviewed: false,
        title: 'Devara',
        fallbackRating: 4,
      );
      expect(okSubmit, isTrue);
      expect(provider.isEditingForPost(101), isFalse);
      expect(provider.isSubmittingForPost(101), isFalse);
      expect(provider.getUserComment(101), equals('Super movie'));
      expect(provider.isArticleRated(101), isTrue);
      expect(trackedEvents, contains('submit_rating'));

      // Filter & reviews retrieval
      provider.filterData(101);
      await Future.delayed(const Duration(milliseconds: 20));
      expect(provider.isFilterData, isTrue);
      expect(provider.movieReviewDetails?.criticRating, equals(3.5));

      provider.dispose();
    });

    test('handles failed submission and DioException cleanly', () async {
      final failingProvider = RatingProvider(
        ratingRepo: FakeRatingRepo(shouldSucceed: false),
      );
      failingProvider.ratingUpdate(5, 202);
      failingProvider.getCommentControllerForPost(202).text = 'Nice';
      expect(
        await failingProvider.submitReviewForArticle(
          articleId: 202,
          userHasReviewed: false,
          title: 'Movie',
          fallbackRating: 5,
        ),
        isFalse,
      );
      expect(failingProvider.isSubmittingForPost(202), isFalse);

      final dioErrorProvider = RatingProvider(
        ratingRepo: FakeRatingRepo(throwDio: true),
      );
      dioErrorProvider.ratingUpdate(5, 203);
      dioErrorProvider.getCommentControllerForPost(203).text = 'Nice';
      expect(
        await dioErrorProvider.submitReviewForArticle(
          articleId: 203,
          userHasReviewed: false,
          title: 'Movie',
          fallbackRating: 5,
        ),
        isFalse,
      );
    });
  });

  group('PollProvider Unit Tests (State Management & Voting Flow)', () {
    setUp(() async {
      if (!Hive.isBoxOpen('pollBox')) {
        await Hive.openBox('pollBox');
      }
      await Hive.box('pollBox').clear();
    });

    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      if (Hive.isBoxOpen('pollBox')) {
        await Hive.box('pollBox').close();
      }
    });

    test('manages feed view state, Hive storage, live results, and vote submission',
        () async {
      final trackedEvents = <String>[];
      final provider = PollProvider(
        pollRepo: FakePollRepo(shouldSucceed: true),
        eventTracker: (_, name) async => trackedEvents.add(name),
      );

      provider.initFeedView(initialIndex: 0);
      provider.setCurrentPollIndex(2);
      expect(provider.currentPollIndex, equals(2));

      provider.setGridView(true);
      expect(provider.isGridView, isTrue);

      provider.selectPollFromGrid(1);
      expect(provider.currentPollIndex, equals(1));
      expect(provider.isGridView, isFalse);

      final pollArticle = <String, dynamic>{
        'id': 501,
        'title': 'Best player?',
        'pollData': {
          'totalVotes': 10,
          'userHasVoted': false,
          'options': [
            {'id': 1, 'text': 'Player A', 'votes': 6, 'percentage': 60.0},
            {'id': 2, 'text': 'Player B', 'votes': 4, 'percentage': 40.0},
          ],
        },
      };

      await provider.loadPollFromHive(pollArticle);
      expect(provider.currentPollData?.totalVotes, equals(10));

      await provider.executeVoteForArticle(
        optId: 1,
        article: pollArticle,
        title: 'Best player?',
      );
      expect(provider.isSubmittingVoteForPost(501), isFalse);
      expect(provider.userVotedOptionId, equals(1));
      expect(provider.currentPollData?.userHasVoted, isTrue);
      expect(trackedEvents, contains('submit_poll'));

      await provider.loadPollFromHive(pollArticle);
      expect(provider.userVotedOptionId, equals(1));

      await provider.getAllPollComments('501', 'sort_by');
      expect(provider.getAllPollCommentsList['options'], isNotEmpty);

      provider.clearData();
      expect(provider.localArticle, isEmpty);
      expect(provider.currentPollData, isNull);
    });

    test('handles failed poll submission and DioException cleanly', () async {
      final failProvider = PollProvider(
        pollRepo: FakePollRepo(shouldSucceed: false),
      );
      await failProvider.executeVoteForArticle(
        optId: 2,
        article: {'id': 601},
        title: 'Fail Poll',
      );
      expect(failProvider.isSubmittingVoteForPost(601), isFalse);

      final dioProvider = PollProvider(
        pollRepo: FakePollRepo(throwDio: true),
      );
      await dioProvider.executeVoteForArticle(
        optId: 2,
        article: {'id': 602},
        title: 'Dio Poll',
      );
      expect(dioProvider.isSubmittingVoteForPost(602), isFalse);
    });
  });

  group('MovieRatings & MovieReviewsScreen Widget Tests', () {
    final movieArticle = <String, dynamic>{
      'id': 1051,
      'movie_name': 'Devara',
      'genre': 'యాక్షన్',
      'certification': 'UA',
      'chotaMeter': '3.5/5',
      'release_year': '2024',
      'duration': '2h 50m',
      'description': 'Action entertainer with massive sea sequences.',
      'image_url': '',
      'externalRatings': [
        {'platform_name': 'IMDb', 'platform_rating': '7.8/10'},
        {'platform_name': 'BookMyShow', 'platform_rating': '84%'},
      ],
      'reviewCount': 48,
    };

    testWidgets('MovieRatings displays share buttons and shares review details',
        (tester) async {
      setPhoneViewport(tester);
      String? sharedText;
      bool? wasWhatsAppOnly;
      ContentShareDispatcher.debugShareOverride = ({
        required shareText,
        required subject,
        required isWhatsAppOnly,
        imagePath,
      }) async {
        sharedText = shareText;
        wasWhatsAppOnly = isWhatsAppOnly;
      };

      await tester.pumpWidget(
        wrapWidget(
          child: MovieRatings(article: movieArticle),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('DEVARA'), findsOneWidget);
      expect(
        find.byKey(const Key('movie_review_whatsapp_share_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_share_button')),
        findsNothing,
      );
      expect(find.byIcon(Icons.share_rounded), findsNothing);

      // Tap WhatsApp quick share
      await tester.tap(
        find.byKey(const Key('movie_review_whatsapp_share_button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(wasWhatsAppOnly, isTrue);
      expect(sharedText, contains('Devara'));
      expect(
        sharedText,
        contains('https://app.bigtv24x7.com/moviereviews?postId=1051'),
      );
      expect(sharedText, contains('3.5/5'));
    });

    testWidgets(
        'MovieRatings manages review editing, submission, and guest prompt via RatingProvider',
        (tester) async {
      setPhoneViewport(tester);
      final ratingProvider = RatingProvider(
        ratingRepo: FakeRatingRepo(shouldSucceed: true),
        eventTracker: (_, __) async {},
      );

      await tester.pumpWidget(
        wrapWidget(
          ratingProvider: ratingProvider,
          child: MovieRatings(article: movieArticle),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('సమీక్ష రాయండి'));
      await tester.pump();
      expect(ratingProvider.isEditingForPost(1051), isTrue);

      await tester.tap(
        find
            .byWidgetPredicate(
              (w) =>
                  w is Icon &&
                  w.icon == Icons.star_rounded &&
                  w.color == const Color(0xFF4B5563),
            )
            .last,
      );
      await tester.pump();
      expect(ratingProvider.getPostRating(1051), equals(5));

      await tester.enterText(
        find.byType(TextFormField),
        'Excellent VFX and soundtrack!',
      );
      await tester.tap(find.text('సమర్పించండి'));
      await tester.pumpAndSettle();

      expect(
        ratingProvider.getUserComment(1051),
        equals('Excellent VFX and soundtrack!'),
      );
      expect(find.text('సవరించండి'), findsOneWidget);
    });

    testWidgets('MovieRatings prompts guest user to log in before reviewing',
        (tester) async {
      setPhoneViewport(tester);
      SharedPreferences.setMockInitialValues({'loginType': ''});
      await tester.pumpWidget(
        wrapWidget(
          ratingProvider: RatingProvider(
            ratingRepo: FakeRatingRepo(),
            eventTracker: (_, __) async {},
          ),
          child: MovieRatings(article: movieArticle),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('సమీక్ష రాయండి'));
      await tester.pumpAndSettle();
      expect(find.text('లాగిన్'), findsOneWidget);
      expect(find.text('రద్దు'), findsOneWidget);

      await tester.tap(find.text('రద్దు'));
      await tester.pumpAndSettle();
      expect(find.text('లాగిన్'), findsNothing);
    });

    testWidgets('MovieRatings renders share buttons even when badges are absent',
        (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        wrapWidget(
          child: const MovieRatings(
            article: {'id': 99, 'title': 'Untitled Movie'},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('movie_review_whatsapp_share_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_share_button')),
        findsNothing,
      );
      expect(find.byIcon(Icons.share_rounded), findsNothing);
    });

    testWidgets('MovieReviewsScreen switches between swipe view and grid view',
        (tester) async {
      setPhoneViewport(tester);
      final homeProvider = TestHomeProvider()..stubReviews = [movieArticle];
      final ratingProvider = RatingProvider(ratingRepo: FakeRatingRepo());

      await tester.pumpWidget(
        wrapWidget(
          homeProvider: homeProvider,
          ratingProvider: ratingProvider,
          child: const MovieReviewsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1/1'), findsOneWidget);
      expect(
        find.byKey(const Key('movie_review_whatsapp_share_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_share_button')),
        findsNothing,
      );

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pump();
      expect(ratingProvider.isGridView, isTrue);
      expect(find.text('అన్ని సినిమా సమీక్షలు'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.view_carousel_rounded));
      await tester.pump();
      expect(ratingProvider.isGridView, isFalse);
    });

    testWidgets(
        'MovieRatings renders trailer as first carousel slide followed by image_url and gallery images',
        (tester) async {
      setPhoneViewport(tester);
      final articleWithTrailerAndGallery = <String, dynamic>{
        'id': 294,
        'title': 'రామాయణం 🚩',
        'content': 'Epic tale of dharma and devotion.',
        'image_url':
            'https://api.pravasamedia.com/api/v1/files/f1ce3a8d-22c3-4513-9ee9-2b26878d3fd4',
        'video_url':
            'https://www.youtube.com/watch?v=OZTI2Qgf1xE&list=RDXbizke4zftY&index=9',
        'video_platform': 'Youtube',
        'gallery': [
          {
            'Url':
                'https://bigtv-cms.s3.ap-south-1.amazonaws.com/cms_news_4d9b9d7e-6390-420d-b44c-ef0d2c4377eb.png'
          },
          {
            'Url':
                'https://bigtv-cms.s3.ap-south-1.amazonaws.com/cms_news_7e6860c4-73f9-4387-bf49-39ea53fae036.png'
          },
          {
            'Url':
                'https://bigtv-cms.s3.ap-south-1.amazonaws.com/cms_news_85b50499-6fbb-4d24-a8e9-c1b0f4738ec8.png'
          },
        ],
        'chotarating': '4.2/5',
        'chotaMeter': '4.2/5',
        'externalRatings': [
          {'platform_name': 'IMDb', 'platform_rating': '7.8/10'},
          {'platform_name': 'BookMyShow', 'platform_rating': '8/10'},
          {'platform_name': 'Rotten Tomatoes', 'platform_rating': '6.9/10'},
        ],
      };

      await tester.pumpWidget(
        wrapWidget(
          child: MovieRatings(article: articleWithTrailerAndGallery),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // First slide must be Trailer
      expect(
        find.byKey(const Key('movie_review_hero_carousel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_slide')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_play_button')),
        findsOneWidget,
      );
      expect(find.text('TRAILER'), findsOneWidget);

      // 5 slides total: 1 trailer + 1 image_url + 3 gallery images -> 5 dots
      final dotsRow = tester.widget<Row>(
        find.descendant(
          of: find.byKey(const Key('movie_review_carousel_dots')),
          matching: find.byType(Row),
        ),
      );
      expect(dotsRow.children.length, equals(5));

      // Swipe to slide 1 (image_url) and verify it renders
      final carouselFinder = find.byKey(const Key('movie_review_hero_carousel'));
      await tester.drag(carouselFinder, const Offset(-350, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        find.byKey(const Key('movie_review_image_slide_1')),
        findsOneWidget,
      );

      // Swipe through gallery images 2, 3, 4
      await tester.drag(carouselFinder, const Offset(-350, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        find.byKey(const Key('movie_review_image_slide_2')),
        findsOneWidget,
      );

      await tester.drag(carouselFinder, const Offset(-350, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        find.byKey(const Key('movie_review_image_slide_3')),
        findsOneWidget,
      );

      await tester.drag(carouselFinder, const Offset(-350, 0));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      expect(
        find.byKey(const Key('movie_review_image_slide_4')),
        findsOneWidget,
      );
    });

    testWidgets(
        'MovieRatings shows only unique image slides without trailer when video_url is absent',
        (tester) async {
      setPhoneViewport(tester);
      final articleImagesOnly = <String, dynamic>{
        'id': 295,
        'title': 'Gallery Only Movie',
        'image_url': 'https://example.com/poster.png',
        'video_url': '',
        'gallery': [
          {'Url': 'https://example.com/poster.png'},
          {'Url': 'https://example.com/still1.png'},
        ],
      };

      await tester.pumpWidget(
        wrapWidget(
          child: MovieRatings(article: articleImagesOnly),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('movie_review_trailer_slide')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('movie_review_image_slide_0')),
        findsOneWidget,
      );

      // Duplicate poster URL is deduplicated -> 2 slides total
      final dotsRow = tester.widget<Row>(
        find.descendant(
          of: find.byKey(const Key('movie_review_carousel_dots')),
          matching: find.byType(Row),
        ),
      );
      expect(dotsRow.children.length, equals(2));
    });

    testWidgets(
        'MovieRatings landscape layout keeps trailer button above title/dots and hides swipe header',
        (tester) async {
      tester.view.physicalSize = const Size(2400, 1080);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final landscapeReview = <String, dynamic>{
        'id': 294,
        'title': 'రామాయణం 🚩',
        'content': 'Epic tale of dharma and devotion.',
        'image_url': 'https://example.com/poster.png',
        'video_url': 'https://www.youtube.com/watch?v=OZTI2Qgf1xE',
        'gallery': [
          {'Url': 'https://example.com/still1.png'},
        ],
        'chotarating': '4.2/5',
        'externalRatings': [
          {'platform_name': 'IMDb', 'platform_rating': '7.8/10'},
        ],
      };

      final homeProvider = TestHomeProvider()..stubReviews = [landscapeReview];
      final ratingProvider = RatingProvider(ratingRepo: FakeRatingRepo());

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          builder: (_, __) => MultiProvider(
            providers: [
              ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
              ChangeNotifierProvider<RatingProvider>.value(
                value: ratingProvider,
              ),
              ChangeNotifierProvider<AuthenticationProvider>(
                create: (_) => AuthenticationProvider(),
              ),
            ],
            child: const MaterialApp(
              home: MovieReviewsScreen(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key('movie_reviews_swipe_header')),
        findsNothing,
      );

      final playRect = tester.getRect(
        find.byKey(const Key('movie_review_trailer_play_button')),
      );
      final dotsRect = tester.getRect(
        find.byKey(const Key('movie_review_carousel_dots')),
      );
      expect(playRect.bottom, lessThanOrEqualTo(dotsRect.top));
    });

    testWidgets(
        'MovieRatings trailer ignores video-surface taps, shows fullscreen/play-pause/seek-bar/close icons, and close returns to carousel',
        (tester) async {
      setPhoneViewport(tester);

      final List<dynamic> orientationHistory = [];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'SystemChrome.setPreferredOrientations') {
          orientationHistory.add(call.arguments);
        }
        return null;
      });
      addTearDown(() {
        messenger.setMockMethodCallHandler(SystemChannels.platform, null);
      });

      final reviewWithTrailer = <String, dynamic>{
        'id': 294,
        'title': 'రామాయణం 🚩',
        'content': 'Epic tale of dharma and devotion.',
        'image_url': 'https://example.com/poster.png',
        'video_url': 'https://www.youtube.com/watch?v=OZTI2Qgf1xE',
        'gallery': [
          {'Url': 'https://example.com/gallery1.png'},
        ],
        'externalRatings': [
          {'platform_name': 'IMDb', 'platform_rating': '7.8/10'},
        ],
      };

      YoutubePlayerController? capturedController;
      await tester.pumpWidget(
        wrapWidget(
          child: MovieRatings(
            article: reviewWithTrailer,
            youtubePlayerBuilder: (controller, isLandscape) {
              capturedController = controller;
              return ColoredBox(
                key: ValueKey('fake_yt_player_$isLandscape'),
                color: Colors.black,
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap Play on trailer slide
      await tester.tap(find.byKey(const Key('movie_review_trailer_play_button')));
      await tester.pump();

      expect(capturedController, isNotNull);
      capturedController!.updateValue(
        capturedController!.value.copyWith(isPlaying: true, hasPlayed: true),
      );
      await tester.pump();

      // Initially controls are hidden while trailer plays cleanly
      expect(
        find.byKey(const Key('movie_review_trailer_tap_surface')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_close_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_fullscreen_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_play_pause_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('movie_review_youtube_seek_bar')),
        findsNothing,
      );
      expect(find.byKey(const ValueKey('fake_yt_player_false')), findsOneWidget);

      // 1st tap on video screen reveals all 4 controls without pausing playback
      final trailerRect = tester.getRect(
        find.byKey(const Key('movie_review_trailer_tap_surface')),
      );
      await tester.tapAt(Offset(trailerRect.center.dx, trailerRect.top + 24));
      await tester.pump();

      expect(capturedController!.value.isPlaying, isTrue);
      expect(
        find.byKey(const Key('movie_review_trailer_close_button')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(
        find.byKey(const Key('movie_review_trailer_fullscreen_button')),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
      expect(
        find.byKey(const Key('movie_review_trailer_play_pause_button')),
        findsOneWidget,
      );
      final portraitPlayPauseIcon = tester.widget<Icon>(
        find.byIcon(Icons.pause_rounded),
      );
      expect(portraitPlayPauseIcon.size, equals(44));
      final portraitPlayPauseRect = tester.getRect(
        find.byKey(const Key('movie_review_trailer_play_pause_button')),
      );
      expect(
        (portraitPlayPauseRect.center - trailerRect.center).distance,
        lessThan(2.0),
      );
      expect(
        find.byKey(const Key('movie_review_youtube_seek_bar')),
        findsOneWidget,
      );

      // 2nd tap on screen hides all 4 controls again without pausing playback
      await tester.tapAt(Offset(trailerRect.center.dx, trailerRect.top + 24));
      await tester.pump();
      expect(capturedController!.value.isPlaying, isTrue);
      expect(
        find.byKey(const Key('movie_review_trailer_close_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_fullscreen_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_play_pause_button')),
        findsNothing,
      );
      expect(
        find.byKey(const Key('movie_review_youtube_seek_bar')),
        findsNothing,
      );

      // 3rd tap brings controls back -> verify pause state switches center icon
      await tester.tapAt(Offset(trailerRect.center.dx, trailerRect.top + 24));
      await tester.pump();
      capturedController!.updateValue(
        capturedController!.value.copyWith(isPlaying: false),
      );
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Tap customised fullscreen button -> requests landscape orientation
      await tester.tap(
        find.byKey(const Key('movie_review_trailer_fullscreen_button')),
      );
      await tester.pump();
      expect(
        orientationHistory.last,
        containsAll([
          'DeviceOrientation.landscapeLeft',
          'DeviceOrientation.landscapeRight',
        ]),
      );

      // Simulate device rotated to landscape while playing trailer
      tester.view.physicalSize = const Size(2400, 1080);
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        find.byKey(const Key('movie_review_trailer_landscape_fullscreen')),
        findsOneWidget,
      );
      final landscapePlayIcon = tester.widget<Icon>(
        find.byIcon(Icons.play_arrow_rounded),
      );
      expect(landscapePlayIcon.size, equals(52));
      expect(
        find.byKey(const Key('movie_review_trailer_close_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_play_pause_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_youtube_seek_bar')),
        findsOneWidget,
      );
      final coverFittedBox = tester.widget<FittedBox>(
        find.byKey(const Key('movie_review_trailer_landscape_cover')),
      );
      expect(coverFittedBox.fit, equals(BoxFit.cover));
      expect(find.byKey(const ValueKey('fake_yt_player_true')), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen_exit), findsOneWidget);
      expect(find.text('IMDb'), findsNothing);

      // Tapping screen in landscape hides controls; another tap brings them back
      final landscapeTapRect = tester.getRect(
        find.byKey(const Key('movie_review_trailer_tap_surface')),
      );
      await tester.tapAt(
        Offset(landscapeTapRect.center.dx, landscapeTapRect.top + 24),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('movie_review_trailer_close_button')),
        findsNothing,
      );
      await tester.tapAt(
        Offset(landscapeTapRect.center.dx, landscapeTapRect.top + 24),
      );
      await tester.pump();
      expect(
        find.byKey(const Key('movie_review_trailer_close_button')),
        findsOneWidget,
      );

      // Tap close button in landscape -> exits fullscreen and returns to carousel view
      await tester.tap(
        find.byKey(const Key('movie_review_trailer_close_button')),
      );
      await tester.pump();
      expect(
        orientationHistory.last,
        containsAll([
          'DeviceOrientation.portraitUp',
          'DeviceOrientation.portraitDown',
        ]),
      );

      setPhoneViewport(tester);
      await tester.pump();
      expect(
        find.byKey(const Key('movie_review_hero_carousel')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_carousel_dots')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_play_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('movie_review_trailer_close_button')),
        findsNothing,
      );
      expect(find.text('IMDb'), findsOneWidget);
    });

    testWidgets(
        'MovieRatings aligns hero images in 50% and all review text details in 50%',
        (tester) async {
      setPhoneViewport(tester);

      final article = <String, dynamic>{
        'id': 294,
        'title': 'రామాయణం 🚩',
        'content': 'Epic tale of dharma and devotion across generations.',
        'image_url': 'https://example.com/poster.png',
        'gallery': [
          {'Url': 'https://example.com/still1.png'},
        ],
        'chotarating': '4.2/5',
        'externalRatings': [
          {'platform_name': 'IMDb', 'platform_rating': '7.8/10'},
          {'platform_name': 'BookMyShow', 'platform_rating': '8/10'},
          {'platform_name': 'Rotten Tomatoes', 'platform_rating': '6.9/10'},
        ],
      };

      await tester.pumpWidget(
        wrapWidget(
          child: MovieRatings(article: article),
        ),
      );
      await tester.pump();

      final Rect cardRect = tester.getRect(find.byType(MovieRatings));
      final Rect heroRect =
          tester.getRect(find.byKey(const Key('movie_review_hero_section')));
      final Rect carouselRect =
          tester.getRect(find.byKey(const Key('movie_review_hero_carousel')));
      final Rect detailsRect =
          tester.getRect(find.byKey(const Key('movie_review_details_section')));

      expect(heroRect.height, closeTo(cardRect.height * 0.5, 1.0));
      expect(detailsRect.height, closeTo(cardRect.height * 0.5, 1.0));
      expect(carouselRect.height, closeTo(heroRect.height, 1.0));
      expect(heroRect.bottom, closeTo(detailsRect.top, 1.0));
      expect(find.text('BIG TV 4.2/5'), findsOneWidget);
      expect(find.text('IMDb'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    test(
        'CleanYoutubePlayer script and playerHtml hide YouTube share, suggestions, and logo safely',
        () {
      const script = CleanYoutubePlayer.youtubeHideUiUserScript;

      expect(script, contains('if (window === window.top) return;'));
      expect(script, contains('.ytp-share-button'));
      expect(script, contains('.ytp-pause-overlay'));
      expect(script, contains('.ytp-related-videos'));
      expect(script, contains('.ytp-endscreen-content'));
      expect(script, contains('.ytp-watermark'));
      expect(script, contains('.ytp-youtube-button'));
      expect(script, contains('.ytp-chrome-top'));
      expect(script, contains('.ytp-chrome-bottom'));
      expect(script, contains('.html5-video-container'));
      expect(script, contains('MutationObserver'));

      final controller = YoutubePlayerController(
        initialVideoId: 'OZTI2Qgf1xE',
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          hideControls: true,
        ),
      );
      addTearDown(controller.dispose);

      final html = CleanYoutubePlayer.buildPlayerHtml(controller);
      expect(html, contains('"OZTI2Qgf1xE"'));
      expect(html, contains("'controls': 0"));
      expect(html, contains("'rel': 0"));
      expect(html, contains("'showinfo': 0"));
      expect(html, contains("'iv_load_policy': 3"));
      expect(html, contains("'modestbranding': 1"));
      expect(html, contains("'disablekb': 1"));
      expect(html, isNot(contains("'end': null")));
    });
  });

  group('PollScreenDesign & PollsFeedScreen Widget Tests', () {
    final pollArticle = <String, dynamic>{
      'id': 1050,
      'title': 'Who will win the upcoming AP Assembly Debate?',
      'category': 'రాజకీయాలు',
      'created_at': '11 Nov 2026',
      'remaining_time': '2 రోజులు మిగిలి ఉన్నాయి',
      'content': 'Share your opinion on recent developments.',
      'image_url': '',
      'pollData': {
        'totalVotes': 1420,
        'userHasVoted': false,
        'options': [
          {'id': 1, 'text': 'Option A', 'votes': 852, 'percentage': 60.0},
          {'id': 2, 'text': 'Option B', 'votes': 568, 'percentage': 40.0},
        ],
      },
    };

    testWidgets('PollScreenDesign displays share buttons and shares poll details',
        (tester) async {
      setPhoneViewport(tester);
      String? sharedText;
      bool? wasWhatsAppOnly;
      ContentShareDispatcher.debugShareOverride = ({
        required shareText,
        required subject,
        required isWhatsAppOnly,
        imagePath,
      }) async {
        sharedText = shareText;
        wasWhatsAppOnly = isWhatsAppOnly;
      };

      final pollProvider = PollProvider(
        pollRepo: FakePollRepo(
          resultsPayload: {
            'totalVotes': 1420,
            'userHasVoted': false,
            'options': [
              {'id': 1, 'text': 'Option A', 'votes': 852, 'percentage': 60.0},
              {'id': 2, 'text': 'Option B', 'votes': 568, 'percentage': 40.0},
            ],
          },
        ),
        eventTracker: (_, __) async {},
      );

      await tester.pumpWidget(
        wrapWidget(
          pollProvider: pollProvider,
          child: PollScreenDesign(
            artical: pollArticle,
            index: 0,
            showTopBar: true,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('poll_whatsapp_share_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('poll_share_button')), findsNothing);
      expect(find.byIcon(Icons.share_rounded), findsNothing);

      // Tap WhatsApp share button
      await tester.tap(find.byKey(const Key('poll_whatsapp_share_button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(wasWhatsAppOnly, isTrue);
      expect(sharedText, contains('Option A'));
      expect(
        sharedText,
        contains('https://app.bigtv24x7.com/polls?postId=1050'),
      );
      expect(sharedText, contains('Who will win the upcoming AP Assembly Debate?'));
    });

    testWidgets('PollScreenDesign renders share buttons even when category is empty',
        (tester) async {
      setPhoneViewport(tester);
      await tester.pumpWidget(
        wrapWidget(
          child: const PollScreenDesign(
            artical: {
              'id': 88,
              'title': 'Quick Poll',
              'poll_options': [
                {'id': 1, 'text': 'Yes'},
                {'id': 2, 'text': 'No'},
              ],
            },
            index: 0,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.byKey(const Key('poll_whatsapp_share_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('poll_share_button')), findsNothing);
      expect(find.byIcon(Icons.share_rounded), findsNothing);
    });

    testWidgets('PollsFeedScreen switches between swipe view and grid view',
        (tester) async {
      setPhoneViewport(tester);
      final homeProvider = TestHomeProvider()..stubPolls = [pollArticle];
      final pollProvider = PollProvider(pollRepo: FakePollRepo());

      await tester.pumpWidget(
        wrapWidget(
          homeProvider: homeProvider,
          pollProvider: pollProvider,
          child: const PollsFeedScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('1/1'), findsOneWidget);
      expect(
        find.byKey(const Key('poll_whatsapp_share_button')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('poll_share_button')), findsNothing);

      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pump();
      expect(pollProvider.isGridView, isTrue);
      expect(find.text('అన్ని పోల్స్'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.view_carousel_rounded));
      await tester.pump();
      expect(pollProvider.isGridView, isFalse);
    });

    testWidgets(
        'PollScreenDesign submits vote via PollProvider and shows guest login dialog',
        (tester) async {
      setPhoneViewport(tester);
      final pollProvider = PollProvider(
        pollRepo: FakePollRepo(
          resultsPayload: {
            'totalVotes': 1420,
            'userHasVoted': false,
            'options': [
              {'id': 1, 'text': 'Option A', 'votes': 852, 'percentage': 60.0},
              {'id': 2, 'text': 'Option B', 'votes': 568, 'percentage': 40.0},
            ],
          },
        ),
        eventTracker: (_, __) async {},
      );

      await tester.pumpWidget(
        wrapWidget(
          pollProvider: pollProvider,
          child: PollScreenDesign(artical: pollArticle, index: 0),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();

      expect(pollProvider.userVotedOptionId, equals(1));
      expect(find.text('ఓటు నమోదు చేయబడింది'), findsOneWidget);

      // Tapping again after voting hits already-voted guard cleanly
      await tester.tap(find.text('Option B'));
      await tester.pump();
      expect(pollProvider.userVotedOptionId, equals(1));
    });

    testWidgets('PollScreenDesign prompts guest user to log in before voting',
        (tester) async {
      setPhoneViewport(tester);
      SharedPreferences.setMockInitialValues({'loginType': ''});
      final guestPollProvider = PollProvider(
        pollRepo: FakePollRepo(
          resultsPayload: {
            'totalVotes': 10,
            'userHasVoted': false,
            'options': [
              {'id': 1, 'text': 'Option A', 'votes': 5, 'percentage': 50.0},
              {'id': 2, 'text': 'Option B', 'votes': 5, 'percentage': 50.0},
            ],
          },
        ),
        eventTracker: (_, __) async {},
      );
      await tester.pumpWidget(
        wrapWidget(
          pollProvider: guestPollProvider,
          child: PollScreenDesign(artical: pollArticle, index: 0),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.text('Option A'));
      await tester.pumpAndSettle();
      expect(find.text('లాగిన్ అవ్వండి'), findsOneWidget);
    });

    testWidgets(
        'PollScreenDesign and PollsFeedScreen grid do not display total voted count text',
        (tester) async {
      setPhoneViewport(tester);
      final singleVotePoll = <String, dynamic>{
        'id': 1099,
        'title': 'Single Vote Poll Check',
        'category': 'రాజకీయాలు',
        'total_votes_display': '1 was voted',
        'total_votes': 1,
        'image_url': '',
        'pollData': {
          'totalVotes': 1,
          'userHasVoted': false,
          'options': [
            {'id': 1, 'text': 'Yes', 'votes': 1, 'percentage': 100.0},
            {'id': 2, 'text': 'No', 'votes': 0, 'percentage': 0.0},
          ],
        },
      };

      final pollProvider = PollProvider(
        pollRepo: FakePollRepo(
          resultsPayload: {
            'totalVotes': 1,
            'userHasVoted': false,
            'options': [
              {'id': 1, 'text': 'Yes', 'votes': 1, 'percentage': 100.0},
              {'id': 2, 'text': 'No', 'votes': 0, 'percentage': 0.0},
            ],
          },
        ),
        eventTracker: (_, __) async {},
      );
      final homeProvider = TestHomeProvider()
        ..stubPolls = [
          singleVotePoll,
          {
            'id': 1100,
            'title': 'Grid Poll Without Display',
            'image_url': '',
            'pollData': {'totalVotes': 1, 'options': []},
          },
        ];

      await tester.pumpWidget(
        wrapWidget(
          homeProvider: homeProvider,
          pollProvider: pollProvider,
          child: const PollsFeedScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.textContaining('మంది ఓటు వేశారు'), findsNothing);
      expect(find.textContaining('was voted'), findsNothing);
      expect(find.byIcon(Icons.people_outline_rounded), findsNothing);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.text('ఓటు నమోదు చేయబడింది'), findsOneWidget);
      expect(find.textContaining('మంది ఓటు వేశారు'), findsNothing);
      expect(find.textContaining('was voted'), findsNothing);
      expect(find.byIcon(Icons.people_outline_rounded), findsNothing);

      // Switch to grid view and verify neither total_votes_display nor fallback text appears
      await tester.tap(find.byIcon(Icons.grid_view_rounded));
      await tester.pump();
      expect(find.text('1 was voted'), findsNothing);
      expect(find.text('1.2 లక్షల మంది'), findsNothing);
      expect(find.byIcon(Icons.how_to_vote_rounded), findsNothing);
    });
  });

  group('Deep Link Routing for Movie Reviews and Polls', () {
    testWidgets('routes /moviereviews?postId=1051 and /polls?postId=1050 to target screens',
        (tester) async {
      setPhoneViewport(tester);
      final homeProvider = TestHomeProvider()
        ..isHomeScreen = true
        ..stubReviews = [
          {'id': 1051, 'movie_name': 'Devara', 'image_url': ''},
        ]
        ..stubPolls = [
          {
            'id': 1050,
            'title': 'Sample Poll',
            'image_url': '',
            'pollData': {'options': []},
          },
        ];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
              ChangeNotifierProvider<RatingProvider>(
                create: (_) => RatingProvider(ratingRepo: FakeRatingRepo()),
              ),
              ChangeNotifierProvider<PollProvider>(
                create: (_) => PollProvider(pollRepo: FakePollRepo()),
              ),
              ChangeNotifierProvider<AuthenticationProvider>(
                create: (_) => AuthenticationProvider(),
              ),
            ],
            child: MaterialApp(
              navigatorKey: mainNavigatorKey,
              home: const Scaffold(body: Text('HomeRoot')),
            ),
          ),
        ),
      );
      await tester.pump();

      await homeProvider.routeDeepLink(
        Uri.parse('https://app.bigtv24x7.com/moviereviews?postId=1051'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MovieReviewsScreen), findsOneWidget);

      await homeProvider.routeDeepLink(
        Uri.parse('https://app.bigtv24x7.com/polls?postId=1050'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PollsFeedScreen), findsOneWidget);
    });

    testWidgets('routes /moviereviews and /polls without postId to feed screens',
        (tester) async {
      setPhoneViewport(tester);
      final homeProvider = TestHomeProvider()
        ..isHomeScreen = true
        ..stubReviews = [
          {'id': 2001, 'movie_name': 'Pushpa 2', 'image_url': ''},
        ]
        ..stubPolls = [
          {
            'id': 2002,
            'title': 'Sample Poll Without ID Param',
            'image_url': '',
            'pollData': {'options': []},
          },
        ];

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
              ChangeNotifierProvider<RatingProvider>(
                create: (_) => RatingProvider(ratingRepo: FakeRatingRepo()),
              ),
              ChangeNotifierProvider<PollProvider>(
                create: (_) => PollProvider(pollRepo: FakePollRepo()),
              ),
              ChangeNotifierProvider<AuthenticationProvider>(
                create: (_) => AuthenticationProvider(),
              ),
            ],
            child: MaterialApp(
              navigatorKey: mainNavigatorKey,
              home: const Scaffold(body: Text('HomeRoot')),
            ),
          ),
        ),
      );
      await tester.pump();

      await homeProvider.routeDeepLink(
        Uri.parse('https://app.bigtv24x7.com/moviereviews'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(MovieReviewsScreen), findsOneWidget);

      await homeProvider.routeDeepLink(
        Uri.parse('https://app.bigtv24x7.com/polls'),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(PollsFeedScreen), findsOneWidget);
    });

    testWidgets('feed screens trigger fetch when initial lists are empty',
        (tester) async {
      setPhoneViewport(tester);
      final homeProvider = TestHomeProvider();

      await tester.pumpWidget(
        wrapWidget(
          homeProvider: homeProvider,
          child: const MovieReviewsScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(homeProvider.fetchReviewsCallCount, greaterThan(0));

      await tester.pumpWidget(
        wrapWidget(
          homeProvider: homeProvider,
          child: const PollsFeedScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(homeProvider.fetchPollsCallCount, greaterThan(0));
    });
  });
}
