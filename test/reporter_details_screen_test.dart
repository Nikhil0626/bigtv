import 'dart:io';

import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/core/theme/app_theme.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/reporters/data/models/reporter_model.dart';
import 'package:chotanews/features/reporters/presentation/screens/reporter_details_screen.dart';
import 'package:chotanews/services/content_share_dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingShareDispatcher extends ContentShareDispatcher {
  String? capturedShareText;
  String? capturedSubject;
  String? capturedFilePrefix;
  ScreenshotController? capturedScreenshotController;
  bool? capturedIsWhatsAppOnly;

  @override
  Future<void> shareContent({
    required BuildContext context,
    required String shareText,
    required String subject,
    required String filePrefix,
    ScreenshotController? screenshotController,
    String? fallbackImageUrl,
    bool isWhatsAppOnly = false,
  }) async {
    capturedShareText = shareText;
    capturedSubject = subject;
    capturedFilePrefix = filePrefix;
    capturedScreenshotController = screenshotController;
    capturedIsWhatsAppOnly = isWhatsAppOnly;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late Directory hiveDir;

  setUpAll(() async {
    hiveDir = await Directory.systemTemp.createTemp('reporter_details_hive');
    Hive.init(hiveDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
    }
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({'selectedLanguageCode': 'te'});
    EventRepo.eventsEnable = false;
  });

  const sampleReporter = ReporterModel(
    id: 'rep_9',
    name: 'Ramesh Kumar',
    title: 'Senior Reporter',
    location: 'Hyderabad',
    state: 'Telangana',
    category: 'Politics',
    about: 'Covering state politics and civic governance.',
    phone: '+91 9876543210',
    email: 'ramesh.kumar@bigtv.example',
    whatsapp: '+91 9876543210',
    imageUrl: '',
  );

  test('buildReporterShareMessage includes name, email, and mobile number', () {
    final msg = ReporterDetailsScreen.buildReporterShareMessage(sampleReporter);
    expect(msg, contains('Name: Ramesh Kumar'));
    expect(msg, contains('Email: ramesh.kumar@bigtv.example'));
    expect(msg, contains('Mobile: +91 9876543210'));

    const missingPhoneReporter = ReporterModel(
      id: 'rep_10',
      name: 'Sita Devi',
      title: 'Bureau Chief',
      location: 'Vijayawada',
      state: 'Andhra Pradesh',
      category: 'News',
      about: '',
      phone: '',
      email: 'null',
      whatsapp: '9123456780',
      imageUrl: '',
    );
    final fallbackMsg =
        ReporterDetailsScreen.buildReporterShareMessage(missingPhoneReporter);
    expect(fallbackMsg, contains('Name: Sita Devi'));
    expect(fallbackMsg, isNot(contains('Email:')));
    expect(fallbackMsg, contains('Mobile: 9123456780'));
  });

  testWidgets(
    'ReporterDetailsScreen renders wave backdrop behind image and shares page screenshot with name, email, and mobile',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final dispatcher = _RecordingShareDispatcher();
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (_, __) => ChangeNotifierProvider<HomeProvider>(
            create: (_) => HomeProvider(),
            child: MaterialApp(
              theme: AppTheme.darkTheme,
              home: ReporterDetailsScreen(
                reporter: sampleReporter,
                shareDispatcher: dispatcher,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.byType(Screenshot), findsOneWidget);

      // Phone & full Email rows are shown, while duplicate WhatsApp contact card is removed.
      expect(find.byKey(const Key('reporter_details_phone_row')), findsOneWidget);
      expect(find.byKey(const Key('reporter_details_email_row')), findsOneWidget);
      final emailTextWidget = tester.widget<Text>(
        find.text('ramesh.kumar@bigtv.example'),
      );
      expect(emailTextWidget.overflow, equals(TextOverflow.visible));
      expect(emailTextWidget.softWrap, isTrue);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
      expect(find.text('WhatsApp'), findsOneWidget);

      final stack = tester.widget<Stack>(
        find
            .ancestor(
              of: find.byKey(const Key('reporter_details_hero_image')),
              matching: find.byType(Stack),
            )
            .first,
      );
      final waveIdx = stack.children.indexWhere(
        (w) => w.key == const Key('reporter_details_wave_backdrop'),
      );
      final heroIdx = stack.children.indexWhere(
        (w) => w.key == const Key('reporter_details_hero_image'),
      );
      expect(waveIdx, greaterThanOrEqualTo(0));
      expect(heroIdx, greaterThan(waveIdx));

      await tester.tap(find.byKey(const Key('reporter_details_share_button')));
      await tester.pump();

      expect(dispatcher.capturedScreenshotController, isNotNull);
      expect(dispatcher.capturedFilePrefix, equals('reporter_rep_9'));
      expect(dispatcher.capturedIsWhatsAppOnly, isFalse);
      expect(dispatcher.capturedShareText, contains('Name: Ramesh Kumar'));
      expect(
        dispatcher.capturedShareText,
        contains('Email: ramesh.kumar@bigtv.example'),
      );
      expect(dispatcher.capturedShareText, contains('Mobile: +91 9876543210'));
    },
  );
}
