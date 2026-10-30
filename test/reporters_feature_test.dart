import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';

import 'package:chotanews/features/reporters/data/models/reporter_model.dart';
import 'package:chotanews/features/reporters/data/repositories/reporter_repository.dart';
import 'package:chotanews/features/reporters/presentation/providers/reporters_provider.dart';
import 'package:chotanews/features/reporters/presentation/screens/reporters_screen.dart';
import 'package:chotanews/features/reporters/presentation/screens/reporter_details_screen.dart';
import 'package:chotanews/core/theme/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  const sampleReporter = ReporterModel(
    id: 'rep_1',
    name: 'Ravi Kumar',
    title: 'Senior Correspondent',
    location: 'Hyderabad',
    state: 'Telangana',
    category: 'Politics',
    about: 'Experienced journalist covering state politics.',
    phone: '9876543210',
    email: 'ravi.kumar@example.com',
    whatsapp: '9876543210',
    imageUrl: 'https://example.com/ravi.jpg',
    bureau: 'Central Bureau',
    employeeId: 'EMP001',
    mediaChannelName: 'Big TV News',
  );

  const sampleReporterAP = ReporterModel(
    id: 'rep_2',
    name: 'Suresh Varma',
    title: 'Special Reporter',
    location: 'Vijayawada',
    state: 'Andhra Pradesh',
    category: 'Current Affairs',
    about: 'Covering Andhra Pradesh governance and local stories.',
    phone: '9876543211',
    email: 'suresh.varma@example.com',
    whatsapp: '9876543211',
    imageUrl: 'https://example.com/suresh.jpg',
    bureau: 'Coastal Bureau',
    employeeId: 'EMP002',
    mediaChannelName: 'Big TV News',
  );

  group('ReporterRepository Tests', () {
    test('getReporters parses Map response with data list', () async {
      final repo = ReporterRepository();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.resolve(
              Response(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'data': [
                    {
                      '_id': '1',
                      'name': 'Ravi Kumar',
                      'title': 'Senior Correspondent',
                      'location': 'Hyderabad',
                      'state': 'Telangana',
                      'category': 'Politics',
                      'about': 'Details',
                      'phone': '9876543210',
                      'email': 'ravi@test.com',
                      'whatsapp': '9876543210',
                      'profileImage': 'https://example.com/1.jpg',
                    }
                  ]
                },
              ),
            );
          },
        ),
      );

      final reporters = await repo.getReporters();
      expect(reporters.length, equals(1));
      expect(reporters.first.name, equals('Ravi Kumar'));
      expect(reporters.first.state, equals('Telangana'));
    });

    test('getReporters handles error by returning empty list', () async {
      final repo = ReporterRepository();
      repo.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                error: 'Network Error',
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );

      final reporters = await repo.getReporters();
      expect(reporters, isEmpty);
    });
  });

  group('ReportersProvider Tests', () {
    test('filters reporters by state correctly', () {
      final provider = ReportersProvider();
      provider.allReporters.clear();
      provider.allReporters.addAll([sampleReporter, sampleReporterAP]);

      expect(provider.availableFilters, containsAll(['All', 'Telangana', 'Andhra Pradesh']));
      expect(provider.selectedStateFilter, equals('All'));
      expect(provider.filteredReporters.length, equals(2));

      provider.setStateFilter('Telangana');
      expect(provider.selectedStateFilter, equals('Telangana'));
      expect(provider.filteredReporters.length, equals(1));
      expect(provider.filteredReporters.first.id, equals('rep_1'));

      provider.setStateFilter('Andhra Pradesh');
      expect(provider.filteredReporters.length, equals(1));
      expect(provider.filteredReporters.first.id, equals('rep_2'));

      provider.setStateFilter('All');
      expect(provider.filteredReporters.length, equals(2));
    });

    test('filters reporters by search query across multiple fields', () {
      final provider = ReportersProvider();
      provider.allReporters.clear();
      provider.allReporters.addAll([sampleReporter, sampleReporterAP]);

      provider.setSearchQuery('Suresh');
      expect(provider.filteredReporters.length, equals(1));
      expect(provider.filteredReporters.first.name, equals('Suresh Varma'));

      provider.setSearchQuery('Vijayawada');
      expect(provider.filteredReporters.length, equals(1));
      expect(provider.filteredReporters.first.name, equals('Suresh Varma'));

      provider.setSearchQuery('Politics');
      expect(provider.filteredReporters.length, equals(1));
      expect(provider.filteredReporters.first.name, equals('Ravi Kumar'));

      provider.clearSearch();
      expect(provider.searchQuery, isEmpty);
      expect(provider.filteredReporters.length, equals(2));
    });
  });

  group('Reporter Details & Screen Widget Tests', () {
    testWidgets('ReporterDetailsScreen renders reporter data, contacts, and badges', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(
            home: ReporterDetailsScreen(reporter: sampleReporter),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ravi Kumar'), findsWidgets);
      expect(find.text('Senior Correspondent'), findsWidgets);
      expect(find.text('Hyderabad, Telangana'), findsWidgets);
      expect(find.text('Politics'), findsWidgets);
      expect(find.text('Call reporter'), findsOneWidget);
      expect(find.text('WhatsApp'), findsWidgets);
      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('ReportersScreen renders header, search bar, and filter chips', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final provider = _TestReportersProvider([sampleReporter, sampleReporterAP]);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider<ReportersProvider>.value(value: provider),
              ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
            ],
            child: const MaterialApp(
              home: ReportersScreen(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('REPORTERS'), findsOneWidget);
      expect(find.text('Reporters'), findsWidgets);
      expect(find.text('Search name or location'), findsOneWidget);
      expect(find.text('Telangana'), findsWidgets);
      expect(find.text('Andhra Pradesh'), findsWidgets);
      expect(find.text('Ravi Kumar'), findsOneWidget);
      expect(find.text('Suresh Varma'), findsOneWidget);

      // Tap filter chip
      await tester.tap(find.text('Telangana').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(provider.selectedStateFilter, equals('Telangana'));
    });
  });
}

class _TestReportersProvider extends ReportersProvider {
  _TestReportersProvider(List<ReporterModel> mockReporters) {
    allReporters.clear();
    allReporters.addAll(mockReporters);
  }

  @override
  Future<void> loadReporters({bool force = false, String? languageCode}) async {}

  @override
  bool get isLoading => false;
}
