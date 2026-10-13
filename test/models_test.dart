import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/features/auth/domain/models/categories_model.dart';
import 'package:chotanews/features/auth/domain/models/language_model.dart';
import 'package:chotanews/features/auth/domain/models/location_model.dart';
import 'package:chotanews/features/home/domain/models/comments_model.dart';
import 'package:chotanews/features/home/domain/models/survey_model.dart';
import 'package:chotanews/features/premium/domain/models/series_model.dart';
import 'package:chotanews/features/reels/data/models/reels_model.dart';
import 'package:chotanews/features/reporters/data/models/reporter_model.dart';
import 'package:chotanews/features/settings/data/models/bookmarks_model.dart';
import 'package:chotanews/aggricator_screens/contest_screen/contest_model.dart';

void main() {
  group('Models Serialization and Deserialization Tests', () {
    test('CategoriesModel fromJson and toJson', () {
      final json = {
        'response_time_sec': 0.12,
        'categories': {
          'categories': [
            {
              'categoryId': 1,
              'categoryName': 'Politics',
              'isFollowed': true,
              'imageUrl': 'https://example.com/politics.png',
              'isActive': true,
            }
          ]
        }
      };

      final model = CategoriesModel.fromJson(json);
      expect(model.responseTimeSec, equals(0.12));
      expect(model.categories, isNotNull);
      expect(model.categories!.categories!.length, equals(1));

      final cat = model.categories!.categories!.first;
      expect(cat.categoryId, equals(1));
      expect(cat.categoryName, equals('Politics'));
      expect(cat.isFollowed, isTrue);

      final outJson = model.toJson();
      expect(outJson['response_time_sec'], equals(0.12));
      expect(outJson['categories'], isNotNull);
    });

    test('LanguageModel fromJson, toJson and getters', () {
      final json = {
        'id': 1,
        'code': 'te',
        'name': {'en': 'Telugu', 'te': 'తెలుగు'},
        'status': true,
        'symbol': 'TE',
      };

      final model = LanguageModel.fromJson(json);
      expect(model.id, equals(1));
      expect(model.code, equals('te'));
      expect(model.status, isTrue);
      expect(model.symbol, equals('TE'));

      final outJson = model.toJson();
      expect(outJson['id'], equals(1));
      expect(outJson['code'], equals('te'));
    });

    test('LocationModel fromJson, toJson and helpers', () {
      final json = {
        'locationId': 101,
        'locationName': 'Hyderabad',
        'englishName': 'Hyderabad',
        'imageUrl': 'https://example.com/hyd.png',
        'isActive': true,
      };

      final model = LocationModel.fromJson(json);
      expect(model.stateId, equals(101));
      expect(model.stateName, equals('Hyderabad'));
      expect(model.getEnglishName(), equals('Hyderabad'));
      expect(model.imageUrl, equals('https://example.com/hyd.png'));

      final outJson = model.toJson();
      expect(outJson['stateId'], equals(101));
      expect(outJson['stateName'], equals('Hyderabad'));
    });

    test('CommentsModel and ChatUser fromJson and toJson', () {
      final json = {
        'id': 'c1',
        'postId': 100,
        'text': 'Great news',
        'createdAt': '2026-01-01T00:00:00.000Z',
        'user': {
          'id': 1,
          'name': 'John',
          'avatar': 'avatar.png',
        },
      };

      final model = CommentsModel.fromJson(json);
      expect(model.id, equals('c1'));
      expect(model.postId, equals(100));
      expect(model.text, equals('Great news'));
      expect(model.user.name, equals('John'));

      final outJson = model.toJson();
      expect(outJson['postId'], equals(100));
      expect(outJson['text'], equals('Great news'));
      expect(outJson['user']['name'], equals('John'));
    });

    test('SurveyModel fromJson and toJson', () {
      final json = {
        'choicename': 'Option A',
        'choiceid': 1,
      };

      final model = SurveyModel.fromJson(json);
      expect(model.choicename, equals('Option A'));
      expect(model.choiceid, equals(1));

      final outJson = model.toJson();
      expect(outJson['choicename'], equals('Option A'));
      expect(outJson['choiceid'], equals(1));
    });

    test('SeriesModel fromJson', () {
      final json = {
        'id': 's1',
        'title': 'Crime Series',
        'description': 'A thrill series',
        'poster': 'poster.png',
        'banner': 'banner.png',
        'genres': ['Drama'],
        'languages': ['Telugu'],
        'releaseDate': '2026-01-01',
        'rating': 4.5,
        'ageRestriction': '18+',
        'featured': true,
        'status': 'active',
        'createdAt': '2026-01-01',
        'updatedAt': '2026-01-01',
        'episodes': [
          {
            'id': 'ep1',
            'seriesId': 's1',
            'episodeNumber': 1,
            'title': 'Pilot',
            'description': 'First ep',
            'thumbnail': 'thumb.png',
            'videoUrl': 'video.mp4',
            'duration': 120,
            'createdAt': '2026-01-01',
          }
        ],
        'trailers': [],
      };

      final model = SeriesModel.fromJson(json);
      expect(model.id, equals('s1'));
      expect(model.title, equals('Crime Series'));
      expect(model.rating, equals(4.5));
      expect(model.featured, isTrue);
      expect(model.episodes.length, equals(1));
      expect(model.episodes.first.title, equals('Pilot'));
    });

    test('ReelsModel fromJson and toJson', () {
      final json = {
        'id': 'r1',
        'videoUrl': 'https://example.com/video.mp4',
        'thumbnailUrl': 'https://example.com/thumb.jpg',
        'title': 'Test Reel',
        'publisher': 'Publisher 1',
        'publisherImage': 'https://example.com/pub.png',
        'likes': 10,
        'comments': 5,
        'shares': 2,
        'duration': '30s',
        'createdAt': '2026-01-01',
        'post_name': 'test_post',
        'reportedBy': 'Admin',
        'links': ['https://example.com'],
        'content': 'Check this out',
        'isBookmarked': 1,
      };

      final model = ReelsModel.fromJson(json);
      expect(model.id, equals('r1'));
      expect(model.videoUrl, equals('https://example.com/video.mp4'));
      expect(model.content, equals('Check this out'));

      final outJson = model.toJson();
      expect(outJson['id'], equals('r1'));
      expect(outJson['content'], equals('Check this out'));
    });

    test('ReporterModel fromJson and toJson', () {
      final json = {
        'id': '1',
        'name': 'Reporter John',
        'title': 'Senior Reporter',
        'location': 'Hyderabad',
        'state': 'Telangana',
        'category': 'News',
        'about': 'Bio here',
        'phone': '1234567890',
        'email': 'john@example.com',
        'whatsapp': '1234567890',
        'imageUrl': 'https://example.com/photo.jpg',
      };

      final model = ReporterModel.fromJson(json);
      expect(model.id, equals('1'));
      expect(model.name, equals('Reporter John'));
      expect(model.fullLocation, equals('Hyderabad, Telangana'));

      final outJson = model.toJson();
      expect(outJson['id'], equals('1'));
      expect(outJson['name'], equals('Reporter John'));
    });

    test('BookmarksModel fromJson and toJson', () {
      final json = {
        'postId': 'b1',
        'isBookmarked': true,
        'created': '2026-01-01',
        'title': 'Saved Post',
        'type': 'news',
        'time': '10:00 AM',
        'imageUrl': 'https://example.com/image.png',
      };

      final model = BookmarksModel.fromJson(json);
      expect(model.postId, equals('b1'));
      expect(model.title, equals('Saved Post'));
      expect(model.isBookmarked, isTrue);

      final outJson = model.toJson();
      expect(outJson['postId'], equals('b1'));
      expect(outJson['title'], equals('Saved Post'));
    });

    test('ContestModel and submodels fromJson and toJson', () {
      final json = {
        'status': 'success',
        'message': 'Contests loaded',
        'data': [
          {
            'postId': 1,
            'userId': 10,
            'isParticipated': true,
            'userName': 'User10',
            'postUrl': 'https://example.com/post',
            'userPic': 'https://example.com/pic.png',
            'dateOfContest': '2026-01-01T00:00:00.000Z',
            'contestName': 'New Year Contest',
            'statusOfContest': 'active',
            'contestImageUrl': 'https://example.com/c.png',
          }
        ]
      };

      final model = ContestModel.fromJson(json);
      expect(model.status, equals('success'));
      expect(model.message, equals('Contests loaded'));
      expect(model.joinDataModel.length, equals(1));
      expect(model.joinDataModel.first.contestName, equals('New Year Contest'));
      expect(model.winnerDataModel.length, equals(1));
      expect(model.availableDataModel.length, equals(1));

      final outJson = model.toJson();
      expect(outJson['status'], equals('success'));
      expect(outJson['contest_winners'], isNotEmpty);
      expect(outJson['available_contests'], isNotEmpty);
      expect(outJson['joined_contests'], isNotEmpty);
    });

    test('LocationModel branch coverage for getNativeName and getEnglishName', () {
      final locTelangana = LocationModel.fromJson({'id': 1, 'name': 'Telangana'});
      expect(locTelangana.getNativeName(), equals('తెలంగాణ'));
      expect(locTelangana.getEnglishName(), equals('Telangana'));

      final locAndhra = LocationModel.fromJson({'id': 2, 'name': 'Andhra Pradesh'});
      expect(locAndhra.getNativeName(), equals('ఆంధ్రప్రదేశ్'));
      expect(locAndhra.getEnglishName(), equals('Andhra Pradesh'));

      final locKerala = LocationModel.fromJson({'id': 3, 'name': 'Kerala'});
      expect(locKerala.getNativeName(), equals('కేరళ'));
      expect(locKerala.getEnglishName(), equals('Kerala'));

      final locTamil = LocationModel.fromJson({'id': 4, 'name': 'Tamil Nadu'});
      expect(locTamil.getNativeName(), equals('తమిళనాడు'));
      expect(locTamil.getEnglishName(), equals('Tamil Nadu'));

      final locKarnataka = LocationModel.fromJson({'id': 5, 'name': 'Karnataka'});
      expect(locKarnataka.getNativeName(), equals('కర్ణాటక'));
      expect(locKarnataka.getEnglishName(), equals('Karnataka'));

      final locOther = LocationModel.fromJson({'id': 6, 'name': 'Other State'});
      expect(locOther.getNativeName(), equals('Other State'));
      expect(locOther.getEnglishName(), equals('Other State'));

      // Image extraction variations
      final locImg1 = LocationModel.fromJson({'id': 10, 'name': 'Test', 'image_url': 'https://example.com/1.png'});
      expect(locImg1.imageUrl, equals('https://example.com/1.png'));

      final locImg2 = LocationModel.fromJson({'id': 11, 'name': 'Test', 'state_image': 'https://example.com/2.png'});
      expect(locImg2.imageUrl, equals('https://example.com/2.png'));

      final locImg3 = LocationModel.fromJson({'id': 12, 'name': 'Test', 'icon': 'https://example.com/3.png'});
      expect(locImg3.imageUrl, equals('https://example.com/3.png'));

      final locImg4 = LocationModel.fromJson({'id': 13, 'name': 'Test', 'image': {'url': 'https://example.com/4.png'}});
      expect(locImg4.imageUrl, equals('https://example.com/4.png'));
    });

    test('ReporterModel branches with mediaChannel, address, and relative image', () {
      final json = {
        'id': '101',
        'name': 'Babu Rao',
        'address': {
          'city': 'Vijayawada',
          'state': 'AP',
        },
        'employment': {
          'designation': 'Chief Bureau',
          'department': 'Crime',
          'workPhone': '9876543210',
          'workEmail': 'babu@bigtv.com',
          'employeeId': 'EMP101',
        },
        'mediaChannel': {
          'name': 'BigTV News',
        },
        'profileImageUrl': '/uploads/reporters/babu.png',
        'socialMediaProfiles': {
          'twitter': '@baburao',
        },
      };

      final reporter = ReporterModel.fromJson(json);
      expect(reporter.id, equals('101'));
      expect(reporter.name, equals('Babu Rao'));
      expect(reporter.title, equals('Chief Bureau'));
      expect(reporter.location, equals('Vijayawada'));
      expect(reporter.state, equals('Andhra Pradesh'));
      expect(reporter.fullLocation, equals('Vijayawada, Andhra Pradesh'));
      expect(reporter.category, equals('Crime'));
      expect(reporter.phone, equals('9876543210'));
      expect(reporter.imageUrl, equals('https://api.pravasamedia.com/uploads/reporters/babu.png'));
      expect(reporter.mediaChannelName, equals('BigTV News'));
      expect(reporter.socialMediaProfiles!['twitter'], equals('@baburao'));
    });

    test('ReelsModel branches with nested brand, analytics, and durationSeconds', () {
      final json = {
        'id': 'reel_99',
        'videoUrl': 'https://example.com/reel.mp4',
        'title': 'Viral Reel',
        'brand': {
          'name': 'BigTV Originals',
          'logoUrl': 'https://example.com/logo.png',
        },
        'analytics': {
          'likeCount': 1200,
          'commentCount': 350,
          'shareCount': 80,
        },
        'durationSeconds': 45,
        'description': 'Description text here',
        'gallery': ['https://example.com/g1.jpg'],
      };

      final reel = ReelsModel.fromJson(json);
      expect(reel.publisher, equals('BigTV Originals'));
      expect(reel.publisherImage, equals('https://example.com/logo.png'));
      expect(reel.likes, equals(1200));
      expect(reel.comments, equals(350));
      expect(reel.shares, equals(80));
      expect(reel.duration, equals('45s'));
      expect(reel.content, equals('Description text here'));
      expect(reel.gallery!.length, equals(1));
    });
  });
}
