import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/feedback_view.dart'
    as legacy_feedback;
import 'package:chotanews/core/theme/app_theme.dart';
import 'package:chotanews/features/settings/presentation/screens/feedback_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _StubSettingsProvider extends SettingsProvider {
  final List<dynamic> apiOptions;
  int? lastSubmittedRating;
  String? lastSubmittedComment;

  _StubSettingsProvider({this.apiOptions = const []});

  @override
  Future getFeedBack() async {
    feedbackList = List<dynamic>.from(apiOptions);
    isFeedbackLoading = false;
    notifyListeners();
  }

  @override
  Future postFeedBack(rating) async {
    lastSubmittedRating = rating as int?;
    lastSubmittedComment = feedbackController.text;
    isFeedbackLoading = false;
    notifyListeners();
  }
}

Widget _buildFeedbackHarness({
  required SettingsProvider settingsProvider,
  Widget child = const FeedbackForm(),
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (context, _) => ChangeNotifierProvider<SettingsProvider>.value(
      value: settingsProvider,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  setUp(() {
    SharedPreferences.setMockInitialValues({'userId': 'u1', 'deviceId': 'd1'});
  });

  group('FeedbackForm Anything else visibility', () {
    testWidgets(
      'hides Anything else text box until Other checkbox is tapped, and hides on untap',
      (tester) async {
        final settingsProvider = _StubSettingsProvider();

        await tester.pumpWidget(
          _buildFeedbackHarness(settingsProvider: settingsProvider),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('feedback_other_comment_section')),
          findsNothing,
        );
        expect(
          find.byKey(const Key('feedback_other_text_field')),
          findsNothing,
        );

        // Tapping another option keeps "Anything else?" hidden.
        await tester.ensureVisible(find.text('Local news'));
        await tester.tap(find.text('Local news'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('feedback_other_text_field')),
          findsNothing,
        );

        // Tapping "Other" reveals "Anything else?" and its text field.
        await tester.ensureVisible(find.text('Other'));
        await tester.tap(find.text('Other'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('feedback_other_comment_section')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('feedback_other_text_field')),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const Key('feedback_other_text_field')),
          'Need offline reading mode',
        );
        await tester.pump();
        expect(find.text('Need offline reading mode'), findsOneWidget);

        // Unchecking "Other" hides the box and clears previously typed text.
        await tester.ensureVisible(find.text('Other'));
        await tester.tap(find.text('Other'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('feedback_other_text_field')),
          findsNothing,
        );

        await tester.ensureVisible(find.text('Other'));
        await tester.tap(find.text('Other'));
        await tester.pumpAndSettle();

        final textField = tester.widget<TextField>(
          find.byKey(const Key('feedback_other_text_field')),
        );
        expect(textField.controller?.text, isEmpty);
      },
    );

    testWidgets(
      'works with API option named Others and legacy import alias, submitting custom comment',
      (tester) async {
        final settingsProvider = _StubSettingsProvider(
          apiOptions: const [
            {'optionId': '1', 'optionText': 'App speed'},
            {'optionId': '2', 'optionText': 'Others'},
          ],
        );

        await tester.pumpWidget(
          _buildFeedbackHarness(
            settingsProvider: settingsProvider,
            child: const legacy_feedback.FeedbackForm(),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('feedback_other_text_field')),
          findsNothing,
        );

        await tester.ensureVisible(find.text('Others'));
        await tester.tap(find.text('Others'));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('feedback_other_text_field')),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const Key('feedback_other_text_field')),
          'Add dark widget support',
        );
        await tester.pump();

        await tester.ensureVisible(find.text('Submit feedback'));
        await tester.tap(find.text('Submit feedback'));
        await tester.pumpAndSettle();

        expect(settingsProvider.lastSubmittedRating, equals(4));
        expect(
          settingsProvider.lastSubmittedComment,
          equals('Add dark widget support'),
        );
      },
    );
  });
}

