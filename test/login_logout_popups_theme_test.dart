import 'dart:io';

import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_repo.dart';
import 'package:chotanews/aggricator_screens/polls_screens/polls_view/polls_screen.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_repo/rating_repo.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_view/movie_reviews.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/settings_view.dart';
import 'package:chotanews/core/theme/app_theme.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/core/theme/theme_provider.dart';
import 'package:chotanews/core/theme/themed_popup_palette.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/bookmarks/presentation/providers/bookmarks_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubPollRepo extends PollRepo {
  @override
  Future submitPolls(body) async => null;

  @override
  Future getPollResults(dynamic postId, {dynamic userId}) async => null;
}

class _StubRatingRepo extends RatingRepo {
  @override
  Future getReviews(dynamic postId, [Map<String, dynamic>? queryParams]) async =>
      null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late Directory hiveDir;

  setUpAll(() async {
    hiveDir = await Directory.systemTemp.createTemp('popup_theme_test_hive');
    Hive.init(hiveDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'loginType': 'skip',
      'selectedLanguageCode': 'te',
      'app_version': '6.0.4',
    });
    EventRepo.eventsEnable = false;
  });

  Widget wrapWithTheme({
    required ThemeData theme,
    required Widget child,
    SettingsProvider? settingsProvider,
    HomeProvider? homeProvider,
  }) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      builder: (_, __) => MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<SettingsProvider>(
            create: (_) => settingsProvider ?? SettingsProvider(),
          ),
          ChangeNotifierProvider<AuthenticationProvider>(
            create: (_) => AuthenticationProvider(),
          ),
          ChangeNotifierProvider<HomeProvider>(
            create: (_) => homeProvider ?? HomeProvider(),
          ),
          ChangeNotifierProvider<BookmarksProvider>(
            create: (_) => BookmarksProvider(),
          ),
          ChangeNotifierProvider<PollProvider>(
            create: (_) => PollProvider(pollRepo: _StubPollRepo()),
          ),
          ChangeNotifierProvider<RatingProvider>(
            create: (_) => RatingProvider(ratingRepo: _StubRatingRepo()),
          ),
        ],
        child: MaterialApp(
          theme: theme,
          home: Scaffold(body: child),
        ),
      ),
    );
  }

  group('Login & Logout Popups Theme Compliance (Light & Dark Mode)', () {
    for (final bool isDark in [false, true]) {
      final modeLabel = isDark ? 'dark mode' : 'light mode';
      final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
      final expectedBg =
          isDark ? AppColorTokens.darkSurface : AppColorTokens.lightSurface;
      final expectedTitle = isDark
          ? AppColorTokens.darkTextPrimary
          : AppColorTokens.lightTextPrimary;
      final expectedBody = isDark
          ? AppColorTokens.darkTextSecondary
          : AppColorTokens.lightTextSecondary;
      final expectedAccent =
          isDark ? AppColorTokens.darkPrimaryRed : AppColorTokens.primaryRed;

      testWidgets(
        'SettingsView Logout confirmation dialog matches $modeLabel colors',
        (tester) async {
          SharedPreferences.setMockInitialValues({
            'loginType': 'login',
            'selectedLanguageCode': 'te',
            'app_version': '6.0.4',
          });
          tester.view.physicalSize = const Size(720, 1600);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final settingsProvider = SettingsProvider()
            ..isNotificationsEnabled = true
            ..appVersion = '6.0.4';

          await tester.pumpWidget(
            wrapWithTheme(
              theme: theme,
              settingsProvider: settingsProvider,
              child: const SettingsView(),
            ),
          );
          await tester.pumpAndSettle();

          await tester.ensureVisible(find.text('Logout'));
          await tester.tap(find.text('Logout'));
          await tester.pumpAndSettle();

          final dialog = tester.widget<AlertDialog>(
            find.byKey(const Key('settings_logout_confirm_dialog')),
          );
          expect(dialog.backgroundColor, equals(expectedBg));

          final titleText = tester.widget<Text>(
            find.descendant(
              of: find.byKey(const Key('settings_logout_confirm_dialog')),
              matching: find.text('Logout'),
            ).first,
          );
          expect(titleText.style?.color, equals(expectedTitle));

          final bodyText = tester.widget<Text>(
            find.text('Are you sure you want to logout from your account?'),
          );
          expect(bodyText.style?.color, equals(expectedBody));

          final confirmBtn = tester.widget<ElevatedButton>(
            find.byKey(const Key('settings_logout_confirm_button')),
          );
          expect(
            confirmBtn.style?.backgroundColor?.resolve({}),
            equals(expectedAccent),
          );

          await tester.tap(
            find.byKey(const Key('settings_logout_cancel_button')),
          );
          await tester.pumpAndSettle();
          expect(
            find.byKey(const Key('settings_logout_confirm_dialog')),
            findsNothing,
          );
        },
      );

      testWidgets(
        'BookmarksProvider.showLoginRequiredDialog matches $modeLabel colors',
        (tester) async {
          tester.view.physicalSize = const Size(720, 1600);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            wrapWithTheme(
              theme: theme,
              child: Builder(
                builder: (ctx) => Center(
                  child: ElevatedButton(
                    key: const Key('open_bookmark_login'),
                    onPressed: () {
                      BookmarksProvider.showLoginRequiredDialog(ctx);
                    },
                    child: const Text('Bookmark'),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();

          await tester.tap(find.byKey(const Key('open_bookmark_login')));
          await tester.pumpAndSettle();

          final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
          expect(dialog.backgroundColor, equals(expectedBg));

          final titleWidget = tester.widget<Text>(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.text('లాగిన్ అవ్వండి'),
            ).first,
          );
          expect(titleWidget.style?.color, equals(expectedTitle));
        },
      );

      testWidgets(
        'PollScreenDesign login dialog matches $modeLabel colors',
        (tester) async {
          tester.view.physicalSize = const Size(720, 1600);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            wrapWithTheme(
              theme: theme,
              child: const PollScreenDesign(
                artical: {
                  'id': 88,
                  'title': 'Sample Poll',
                  'pollData': {
                    'totalVotes': 10,
                    'userHasVoted': false,
                    'options': [
                      {'id': 1, 'text': 'Option A', 'votes': 6, 'percentage': 60.0},
                      {'id': 2, 'text': 'Option B', 'votes': 4, 'percentage': 40.0},
                    ],
                  },
                },
                index: 0,
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          await tester.tap(find.text('Option A'));
          await tester.pumpAndSettle();

          final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
          expect(dialog.backgroundColor, equals(expectedBg));

          final titleText = tester.widget<Text>(
            find.descendant(
              of: find.byType(AlertDialog),
              matching: find.text('లాగిన్ అవ్వండి'),
            ).first,
          );
          expect(titleText.style?.color, equals(expectedTitle));

          final cancelText = tester.widget<Text>(find.text('రద్దు'));
          expect(cancelText.style?.color, equals(expectedBody));
        },
      );

      testWidgets(
        'MovieRatings login dialog matches $modeLabel colors',
        (tester) async {
          tester.view.physicalSize = const Size(720, 1600);
          tester.view.devicePixelRatio = 2.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            wrapWithTheme(
              theme: theme,
              child: const MovieRatings(
                article: {
                  'id': 294,
                  'title': 'రామాయణం',
                  'content': 'Epic tale.',
                  'image_url': '',
                  'externalRatings': [],
                },
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          await tester.tap(find.byIcon(Icons.star_rounded).first);
          await tester.pumpAndSettle();

          final dialog = tester.widget<Dialog>(find.byType(Dialog));
          expect(dialog.backgroundColor, equals(expectedBg));

          final titleText = tester.widget<Text>(
            find.descendant(
              of: find.byType(Dialog),
              matching: find.text('లాగిన్ అవ్వండి'),
            ).first,
          );
          expect(titleText.style?.color, equals(expectedTitle));

          final cancelText = tester.widget<Text>(find.text('రద్దు'));
          expect(cancelText.style?.color, equals(expectedBody));
        },
      );
    }

    test('ThemedPopupPalette resolves distinct light and dark token sets', () {
      expect(AppColorTokens.lightSurface, isNot(equals(AppColorTokens.darkSurface)));
      expect(
        const ThemedPopupPalette(
          isDark: true,
          backgroundColor: AppColorTokens.darkSurface,
          borderColor: AppColorTokens.darkBorder,
          titleColor: AppColorTokens.darkTextPrimary,
          bodyColor: AppColorTokens.darkTextSecondary,
          accentColor: AppColorTokens.darkPrimaryRed,
        ).dialogShape().side.color,
        equals(AppColorTokens.darkBorder),
      );
    });
  });
}

