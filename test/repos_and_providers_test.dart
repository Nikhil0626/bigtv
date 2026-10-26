import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:chotanews/aggricator_screens/contest_screen/contest_repo.dart';
import 'package:chotanews/aggricator_screens/contest_screen/contest_provider.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_repo.dart';
import 'package:chotanews/aggricator_screens/referral_screen/referral_repo/referral_repo.dart';
import 'package:chotanews/aggricator_screens/rating_screen/rating_repo/rating_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'userId': 'usr_999',
      'app_version': '6.0.3+3052',
      'loginType': 'login',
    });
  });

  group('ContestRepo and AdsContestProvider Tests', () {
    test('ContestRepo getContestList dispatches request', () async {
      final repo = ContestRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'all_contests': [],
                  'contest_winners': [],
                },
              ),
            );
          },
        ),
      );

      final resp = await repo.getContestList('usr_999');
      expect(resp.statusCode, equals(200));
      expect(resp.data['all_contests'], isList);
    });

    test('AdsContestProvider initializes with default state', () {
      final provider = AdsContestProvider();
      expect(provider.isLoading, isFalse);
      expect(provider.joinedContestsList, isEmpty);
      expect(provider.contestWinnersList, isEmpty);
    });
  });

  group('PollRepo Tests', () {
    test('submitPolls and getAllPollComments', () async {
      final repo = PollRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'status': 'ok'},
              ),
            );
          },
        ),
      );

      final submitResp = await repo.submitPolls({'poll_id': 'p1', 'option': 'A'});
      expect(submitResp.statusCode, equals(200));

      final getResp = await repo.getAllPollComments('p1');
      expect(getResp.statusCode, equals(200));
    });
  });

  group('ReferralRepo Tests', () {
    test('dispatches referral API calls properly', () async {
      final repo = ReferralRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'success': true},
              ),
            );
          },
        ),
      );

      final stats = await repo.getReferralStats('usr_999');
      expect(stats.statusCode, equals(200));

      final rewards = await repo.getAvailableRewards();
      expect(rewards.statusCode, equals(200));

      final claimed = await repo.getClaimedRewards({'user_id': 'usr_999'});
      expect(claimed.statusCode, equals(200));

      final postClaim = await repo.postClaimedRewards({'reward_id': 'r1'});
      expect(postClaim.statusCode, equals(200));

      final providers = await repo.getAllProvidersNames();
      expect(providers.statusCode, equals(200));

      final process = await repo.postProcessReferral({'code': 'REF123'});
      expect(process.statusCode, equals(200));
    });
  });

  group('RatingRepo Tests', () {
    test('postSubmitRating and getReviews dispatch correctly', () async {
      final repo = RatingRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'data': []},
              ),
            );
          },
        ),
      );

      final postResp = await repo.postSubmitRating({'rating': 5, 'post_id': '10'});
      expect(postResp.statusCode, equals(200));

      final reviewsResp = await repo.getReviews('10', {'skip': 0});
      expect(reviewsResp.statusCode, equals(200));
    });
  });

  group('SettingsRepo Tests', () {
    test('bookmark, like, feedback, and profile operations', () async {
      final repo = SettingsRepo();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {'status': 'success'},
              ),
            );
          },
        ),
      );

      final bm = await repo.bookMarks({'user_id': 'usr_999'});
      expect(bm.statusCode, equals(200));

      final saveBm = await repo.saveBookMarks({'user_id': 'usr_999', 'post_id': 'p1'});
      expect(saveBm.statusCode, equals(200));

      final liked = await repo.liked({'user_id': 'usr_999', 'post_id': 'p1'});
      expect(liked.statusCode, equals(200));

      final postFb = await repo.postFeedBack({'feedback': 'Great app'});
      expect(postFb.statusCode, equals(200));

      final getFb = await repo.getFeedBack({'user_id': 'usr_999'});
      expect(getFb.statusCode, equals(200));

      final postProf = await repo.postProfile({'name': 'John Doe'});
      expect(postProf.statusCode, equals(200));

      final delAcc = await repo.deleteAccount({'user_id': 'usr_999'});
      expect(delAcc.statusCode, equals(200));

      final getProf = await repo.getProfile({'user_id': 'usr_999'});
      expect(getProf.statusCode, equals(200));
    });
  });

  group('SettingsProvider and ProfileProvider Tests', () {
    test('SettingsProvider updates feedback stars and retrieves preferences', () async {
      final provider = SettingsProvider();

      expect(provider.selectedStar, equals(0));
      provider.setSelectedStar(4);
      expect(provider.selectedStar, equals(4));

      provider.feedbackController.text = 'Very useful';
      provider.selectedFeedbackList.add('Speed');
      provider.resetFeedback();
      expect(provider.selectedStar, equals(0));
      expect(provider.feedbackController.text, isEmpty);
      expect(provider.selectedFeedbackList, isEmpty);

      await provider.getLoginDetails();
      expect(provider.appVersion, equals('6.0.3+3052'));
      expect(provider.isNotificationsEnabled, isTrue);
    });

    test('ProfileProvider manages input controllers and default state', () {
      final provider = ProfileProvider();

      expect(provider.nameController, isNotNull);
      expect(provider.phoneController, isNotNull);
      expect(provider.dayController, isNotNull);
      expect(provider.monthController, isNotNull);
      expect(provider.yearController, isNotNull);
      expect(provider.isMainLoading, isFalse);
      expect(provider.isButtonEnabled, isFalse);

      provider.nameController.text = 'User Name';
      expect(provider.nameController.text, equals('User Name'));
    });
  });
}
