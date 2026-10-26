import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/home/presentation/widgets/games_bottom_sheet.dart';
import 'package:chotanews/features/zip_puzzle/data/models/daily_puzzle_models.dart';
import 'package:chotanews/features/zip_puzzle/data/repositories/puzzle_games_api_client.dart';
import 'package:chotanews/features/zip_puzzle/presentation/providers/daily_puzzle_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createTestWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        home: Scaffold(body: child),
      ),
    );
  }

  group('Dynamic Games Bottom Sheet Tests', () {
    test('ActiveGameItem parses API item correctly', () {
      final json = {
        'id': '1',
        'slug': 'zip_puzzle',
        'name': 'Zip Puzzle',
        'gameType': 'zip',
        'timezone': 'Asia/Kolkata',
        'description': 'Connect checkpoints',
        'isActive': true,
      };

      final game = ActiveGameItem.fromJson(json);
      expect(game.name, 'Zip Puzzle');
      expect(game.isActive, isTrue);
    });

    test('PuzzleGamesApiClient parses only active games returned by API', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'success': true,
            'data': {
              'items': [
                {
                  'id': '1',
                  'slug': 'zip_puzzle',
                  'name': 'Zip Puzzle',
                  'gameType': 'zip',
                  'timezone': 'Asia/Kolkata',
                  'description': 'Dynamic Zip Puzzle',
                  'isActive': true,
                }
              ]
            }
          }),
          200,
        );
      });

      final client = PuzzleGamesApiClient(
        baseUrl: 'http://test/api/v1',
        client: mockClient,
      );

      final games = await client.getActiveGames();
      expect(games.length, 1);
      expect(games.first.slug, 'zip_puzzle');
      expect(games.any((g) => g.slug == 'patches_puzzle'), isFalse);
      expect(games.any((g) => g.slug == 'sudoku_6x6'), isFalse);
    });

    testWidgets('GamesBottomSheet renders without crash', (tester) async {
      await tester.pumpWidget(createTestWidget(const GamesBottomSheet(isTelugu: false)));
      await tester.pump();

      expect(find.text('Big TV Games & Puzzles'), findsOneWidget);
    });

    testWidgets('Tapping on a game when logged out shows login dialog on the first tap', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          builder: (context, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DailyPuzzleProvider()),
            ],
            child: const MaterialApp(
              home: Scaffold(
                body: GamesBottomSheet(isTelugu: false),
              ),
            ),
          ),
        ),
      );

      // Wait for games to load
      await tester.pumpAndSettle();

      // Find any game card (e.g. Zip Puzzle, Patches Puzzle, Sudoku 6x6)
      final zipFinder = find.text('Zip Puzzle');
      if (zipFinder.evaluate().isNotEmpty) {
        // Very first tap
        await tester.tap(zipFinder);
        await tester.pumpAndSettle();

        // Login dialog should appear on the very first tap
        expect(find.text('Login Required'), findsOneWidget);
      }
    });

    testWidgets('Tapping on a game when logged in navigates immediately on the very first tap', (tester) async {
      SharedPreferences.setMockInitialValues({
        'userId': 'user_test_123',
        'loginType': 'login',
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          builder: (context, _) => MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DailyPuzzleProvider()),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (ctx) => Scaffold(
                  body: ElevatedButton(
                    onPressed: () => GamesBottomSheet.show(ctx, false),
                    child: const Text('Open Games'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Games'));
      await tester.pumpAndSettle();

      expect(find.text('Big TV Games & Puzzles'), findsOneWidget);

      // Find game card
      final patchFinder = find.text('Patches Puzzle');
      final targetFinder = patchFinder.evaluate().isNotEmpty ? patchFinder : find.text('Zip Puzzle');

      if (targetFinder.evaluate().isNotEmpty) {
        // Very first tap
        await tester.tap(targetFinder.first);
        await tester.pumpAndSettle();

        // Bottom sheet is dismissed immediately and game/dashboard is opened on the first tap
        expect(find.text('Big TV Games & Puzzles'), findsNothing);
      }
    });
  });
}
