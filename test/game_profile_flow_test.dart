import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/core/widgets/game_profile_prompt_dialog.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';

class _FakeProfileProvider extends ProfileProvider {
  int postProfileCalls = 0;
  bool? lastShowToast;

  @override
  Future postProfile({bool showToast = true}) async {
    postProfileCalls++;
    lastShowToast = showToast;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Game Profile and App Open Sync Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('GameProfileManager.isValidPlayerName validates realistic player names', () {
      expect(GameProfileManager.isValidPlayerName(null), isFalse);
      expect(GameProfileManager.isValidPlayerName(''), isFalse);
      expect(GameProfileManager.isValidPlayerName('   '), isFalse);
      expect(GameProfileManager.isValidPlayerName('Player'), isFalse);
      expect(GameProfileManager.isValidPlayerName('player'), isFalse);
      expect(GameProfileManager.isValidPlayerName('Guest'), isFalse);
      expect(GameProfileManager.isValidPlayerName('guest123'), isFalse);
      expect(GameProfileManager.isValidPlayerName('You'), isFalse);
      expect(GameProfileManager.isValidPlayerName('User1234'), isFalse);
      expect(GameProfileManager.isValidPlayerName('user99999'), isFalse);

      expect(GameProfileManager.isValidPlayerName('Nikhil'), isTrue);
      expect(GameProfileManager.isValidPlayerName('Ramesh Kumar'), isTrue);
      expect(GameProfileManager.isValidPlayerName('BigTV Fan'), isTrue);
    });

    test('getUnifiedProfile retrieves name from local storage without hitting backend', () async {
      SharedPreferences.setMockInitialValues({
        'userName': 'Pravasa Player',
        'userPhoto': 'https://example.com/avatar.png',
      });

      final fakeProvider = _FakeProfileProvider();
      final profile = await GameProfileManager.getUnifiedProfile(profileProvider: fakeProvider);

      expect(profile.hasValidName, isTrue);
      expect(profile.name, equals('Pravasa Player'));
      expect(profile.photoUrl, equals('https://example.com/avatar.png'));
      expect(fakeProvider.postProfileCalls, equals(0));

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(GameProfileManager.keyGameProfileName), equals('Pravasa Player'));
      expect(prefs.getString('zip_puzzle_v1_player_name'), equals('Pravasa Player'));
      expect(prefs.getString('patches_puzzle_v1_player_name'), equals('Pravasa Player'));
      expect(prefs.getString('sudoku_player_display_name'), equals('Pravasa Player'));
    });

    test('getUnifiedProfile returns hasValidName: false when no profile name exists locally', () async {
      SharedPreferences.setMockInitialValues({});

      final fakeProvider = _FakeProfileProvider();
      final profile = await GameProfileManager.getUnifiedProfile(profileProvider: fakeProvider);

      expect(profile.hasValidName, isFalse);
      expect(profile.name, isEmpty);
      expect(fakeProvider.postProfileCalls, equals(0));
    });

    test('saveUnifiedProfile with updateBackend: false syncs storage keys without calling postProfile', () async {
      final fakeProvider = _FakeProfileProvider();

      await GameProfileManager.saveUnifiedProfile(
        name: 'Super Player',
        photoUrl: 'https://example.com/pic.png',
        profileProvider: fakeProvider,
        updateBackend: false, // Simulated post-game sync: DO NOT hit profile API
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(GameProfileManager.keyGameProfileName), equals('Super Player'));
      expect(prefs.getString('userName'), equals('Super Player'));
      expect(prefs.getString('zip_puzzle_v1_player_name'), equals('Super Player'));
      expect(prefs.getString('patches_puzzle_v1_player_name'), equals('Super Player'));
      expect(prefs.getString('sudoku_player_display_name'), equals('Super Player'));
      expect(prefs.getString('userPhoto'), equals('https://example.com/pic.png'));

      // Verified: Profile API is NOT hit after gameplay
      expect(fakeProvider.postProfileCalls, equals(0));
    });

    test('saveUnifiedProfile with updateBackend: true calls postProfile with showToast: false', () async {
      final fakeProvider = _FakeProfileProvider();

      await GameProfileManager.saveUnifiedProfile(
        name: 'New Player',
        photoUrl: 'https://example.com/new.png',
        profileProvider: fakeProvider,
        updateBackend: true,
        showToastOnBackendUpdate: false, // When entered in dialog after game
      );

      expect(fakeProvider.postProfileCalls, equals(1));
      expect(fakeProvider.lastShowToast, isFalse);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('userName'), equals('New Player'));
    });

    test('ProfileProvider postProfile respects showToast parameter', () async {
      final provider = _FakeProfileProvider();
      await provider.postProfile(showToast: false);
      expect(provider.postProfileCalls, equals(1));
      expect(provider.lastShowToast, isFalse);

      await provider.postProfile(showToast: true);
      expect(provider.postProfileCalls, equals(2));
      expect(provider.lastShowToast, isTrue);
    });
  });
}
