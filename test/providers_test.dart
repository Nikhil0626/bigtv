import 'package:flutter_test/flutter_test.dart';
import 'package:chotanews/core/providers/web_view_provider.dart';
import 'package:chotanews/features/premium/presentation/bloc/premium_bloc.dart';
import 'package:chotanews/features/premium/presentation/bloc/premium_state.dart';
import 'package:chotanews/features/premium/presentation/bloc/premium_event.dart';
import 'package:chotanews/features/premium/data/repositories/premium_repo.dart';
import 'package:dio/dio.dart';

class FakePremiumRepo extends PremiumRepo {
  final bool shouldSucceed;
  FakePremiumRepo({this.shouldSucceed = true});

  @override
  Future<Response> getSeriesContent({String type = 'series'}) async {
    if (shouldSucceed) {
      return Response(
        requestOptions: RequestOptions(path: '/series'),
        statusCode: 200,
        data: [
          {'id': 's1', 'title': 'Test Series 1'},
          {'id': 's2', 'title': 'Test Series 2'},
        ],
      );
    } else {
      return Response(
        requestOptions: RequestOptions(path: '/series'),
        statusCode: 500,
        data: null,
      );
    }
  }
}

void main() {
  group('Providers and BLoC Tests', () {
    test('WebViewProvider manages loading percentage and page title', () {
      final provider = WebViewProvider();
      expect(provider.loadingPercentage, equals(0));
      expect(provider.pageTitle, isNull);

      provider.updateLoadingPercentage(50);
      expect(provider.loadingPercentage, equals(50));

      provider.updatePageTitle('Test Page');
      expect(provider.pageTitle, equals('Test Page'));

      provider.reset();
      expect(provider.loadingPercentage, equals(0));
      expect(provider.pageTitle, isNull);
    });

    test('PremiumBloc emits Loading and Loaded on successful FetchSeriesData', () async {
      final repo = FakePremiumRepo(shouldSucceed: true);
      final bloc = PremiumBloc(premiumRepo: repo);

      expect(bloc.state, isA<PremiumInitial>());

      bloc.add(const FetchSeriesData(type: 'all'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PremiumLoading>(),
          isA<PremiumLoaded>().having(
            (state) => state.series.length,
            'series count',
            equals(2),
          ),
        ]),
      );

      await bloc.close();
    });

    test('PremiumBloc emits Loading and Error on failed FetchSeriesData', () async {
      final repo = FakePremiumRepo(shouldSucceed: false);
      final bloc = PremiumBloc(premiumRepo: repo);

      bloc.add(const FetchSeriesData(type: 'all'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<PremiumLoading>(),
          isA<PremiumError>(),
        ]),
      );

      await bloc.close();
    });
  });
}
