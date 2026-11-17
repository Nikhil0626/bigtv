import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/auth/presentation/screens/language_selection_screen.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  Widget wrapWithMaterial(Widget child, AuthenticationProvider authProvider) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      builder: (context, _) => ChangeNotifierProvider<AuthenticationProvider>.value(
        value: authProvider,
        child: MaterialApp(
          home: child,
        ),
      ),
    );
  }

  group('Guest Login & Back Flow Tests', () {
    test('continueAsGuest sets isGuest to true and newAppLoginStatus to language', () async {
      final provider = AuthenticationProvider();
      expect(provider.isGuest, isFalse);
      expect(provider.newAppLoginStatus, equals(NewAppLoginStatus.none));

      // Simulate continueAsGuest with mock navigator
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loginType', 'skip');
      provider.isGuest = true;
      provider.newAppLoginStatus = NewAppLoginStatus.language;

      expect(provider.isGuest, isTrue);
      expect(provider.newAppLoginStatus, equals(NewAppLoginStatus.language));
    });

    test('updateLoginStatus persists state and notifies listeners', () async {
      final provider = AuthenticationProvider();
      provider.updateLoginStatus(NewAppLoginStatus.login);
      await Future.delayed(Duration.zero);

      expect(provider.newAppLoginStatus, equals(NewAppLoginStatus.login));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('loginState'), equals(NewAppLoginStatus.login.toString()));
    });

    testWidgets('Tapping back on LanguageSelectionScreen in guest mode navigates to login, NOT otp', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = AuthenticationProvider();
      provider.isGuest = true;
      provider.newAppLoginStatus = NewAppLoginStatus.language;

      await tester.pumpWidget(wrapWithMaterial(const LanguageSelectionScreen(), provider));
      await tester.pump();

      // Find the back button (arrow_back_ios_new_rounded icon)
      final backButton = find.byIcon(Icons.arrow_back_ios_new_rounded);
      expect(backButton, findsWidgets);

      // Tap back
      await tester.tap(backButton.first);
      await tester.pumpAndSettle();

      // Verify that status changed to LOGIN, definitely NOT OTP!
      expect(provider.newAppLoginStatus, equals(NewAppLoginStatus.login));
      expect(provider.newAppLoginStatus, isNot(equals(NewAppLoginStatus.otp)));
    });

    testWidgets('PopScope in LanguageSelectionScreen handles system back to login', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final provider = AuthenticationProvider();
      provider.isGuest = true;
      provider.newAppLoginStatus = NewAppLoginStatus.language;

      await tester.pumpWidget(wrapWithMaterial(const LanguageSelectionScreen(), provider));
      await tester.pump();

      // Trigger system back pop
      final dynamic widgetsAppState = tester.state(find.byType(WidgetsApp));
      await widgetsAppState.didPopRoute();
      await tester.pumpAndSettle();

      // Verify that status changed to LOGIN, definitely NOT OTP!
      expect(provider.newAppLoginStatus, equals(NewAppLoginStatus.login));
      expect(provider.newAppLoginStatus, isNot(equals(NewAppLoginStatus.otp)));
    });
  });
}
