import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chotanews/features/events/presentation/screens/folk_night_booking_screen.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';

class _MockHomeProvider extends HomeProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Amphitheater painter renders with FANPIT selected', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 255,
              child: CustomPaint(
                painter: AmphitheaterSeatingCanvas(
                  selectedZoneKey: 'FANPIT',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('Amphitheater painter renders with EARLY BIRD selected', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 255,
              child: CustomPaint(
                painter: AmphitheaterSeatingCanvas(
                  selectedZoneKey: 'EARLY BIRD',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('Amphitheater painter renders with REGULAR selected', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, _) => MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 255,
              child: CustomPaint(
                painter: AmphitheaterSeatingCanvas(
                  selectedZoneKey: 'REGULAR',
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('Ticket category cards and horizontal coupon cards render cleanly without overflow',
      (tester) async {
    // Test on a narrow screen (320px width - e.g. iPhone SE / compact Android)
    tester.view.physicalSize = const Size(320 * 2.0, 700 * 2.0);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final mockTickets = [
      {
        'id': 'fanpit-1',
        'name': 'Fanpit',
        'description': 'Front stage seating closest to the artists and dance floor',
        'price': 3000,
        'isActive': true,
      },
      {
        'id': 'earlybird-1',
        'name': 'Early Bird',
        'description': 'Earlybird Tickets with premium stage visibility',
        'price': 1000,
        'isActive': true,
      },
      {
        'id': 'regular-1',
        'name': 'Regular',
        'description': 'Regular seating with great amphitheater acoustics',
        'price': 500,
        'isActive': true,
      },
    ];

    final mockCoupons = [
      {
        'code': 'BIGTVFN30',
        'discountType': 'PERCENTAGE',
        'discountValue': 30,
        'minOrderAmount': 350,
        'maxDiscount': 500,
        'isActive': true,
      },
      {
        'code': 'FN300',
        'discountType': 'FLAT',
        'discountValue': 300,
        'minOrderAmount': 500,
        'maxDiscount': 300,
        'isActive': true,
      },
    ];

    await tester.pumpWidget(
      ChangeNotifierProvider<HomeProvider>(
        create: (_) => _MockHomeProvider(),
        child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            home: FolkNightBookingScreen(
              initialTickets: mockTickets,
              initialCoupons: mockCoupons,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Verify tickets are displayed
    expect(find.text('Select Ticket Category'), findsOneWidget);
    expect(find.text('Early Bird'), findsOneWidget);
    expect(find.text('ROWS 3-4 • BEST VALUE'), findsOneWidget);
    expect(find.text('Fanpit'), findsOneWidget);
    expect(find.text('Regular'), findsOneWidget);

    // Verify coupons are displayed in horizontal scroll
    expect(find.text('Available Coupons'), findsOneWidget);
    expect(find.text('BIGTVFN30'), findsOneWidget);
    expect(find.text('FN300'), findsOneWidget);

    // No overflow exception should have been thrown during rendering
    expect(tester.takeException(), isNull);
  });
}
