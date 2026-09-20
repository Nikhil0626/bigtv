import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/events/presentation/screens/payment_success_screen.dart';
import 'package:chotanews/features/events/presentation/screens/ticket_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  bool isLoading = true;
  List<dynamic> userBookings = [];
  String? activeBookingCode;
  String? activeRazorpayOrderId;
  String? retryingBookingCode;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    fetchUserBookings();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("=== [Razorpay Retry] PAYMENT SUCCESS ===");
    debugPrint("Payment ID: ${response.paymentId}, Order ID: ${response.orderId}, Signature: ${response.signature}");

    if (activeBookingCode == null) return;

    try {
      final verifyPayload = {
        "razorpayOrderId": response.orderId,
        "razorpayPaymentId": response.paymentId,
        "razorpaySignature": response.signature,
        "bookingId": activeBookingCode,
      };

      final verifyResponse = await Dio().post(
        'https://api.pravasamedia.com/api/v1/payments/verify',
        data: verifyPayload,
      );

      if (!mounted) return;
      if (verifyResponse.statusCode == 200 || verifyResponse.statusCode == 201) {
        final bookingData = (verifyResponse.data != null && verifyResponse.data['data'] != null)
            ? verifyResponse.data['data']
            : {"bookingCode": activeBookingCode};
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(booking: Map<String, dynamic>.from(bookingData)),
          ),
        );
        fetchUserBookings();
      }
    } catch (e) {
      debugPrint("❌ Verification error: $e");
    } finally {
      setState(() {
        retryingBookingCode = null;
      });
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    debugPrint("=== [Razorpay Retry] PAYMENT ERROR ===");
    if (activeBookingCode != null) {
      try {
        final failurePayload = {
          "bookingId": activeBookingCode,
          "razorpayOrderId": activeRazorpayOrderId ?? "",
          "reason": response.message ?? "User closed payment window",
        };
        await Dio().post(
          'https://api.pravasamedia.com/api/v1/payments/failure',
          data: failurePayload,
        );
      } catch (e) {
        debugPrint("❌ Failure report error: $e");
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
    setState(() {
      retryingBookingCode = null;
    });
    fetchUserBookings();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> _retryPayment(Map<String, dynamic> booking) async {
    final bCode = booking['bookingCode'];
    if (bCode == null || bCode.toString().isEmpty) return;

    setState(() {
      retryingBookingCode = bCode;
    });

    try {
      final retryUrl = 'https://api.pravasamedia.com/api/v1/payments/retry-order';
      debugPrint("▶ [API Retry Order] POST $retryUrl with bookingId: $bCode");

      final response = await Dio().post(
        retryUrl,
        data: {"bookingId": bCode},
      );

      debugPrint("◀ [API Retry Order Response] Status: ${response.statusCode}, Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final orderData = response.data['data'];
        final String orderId = orderData['orderId'];
        final int amountPaise = orderData['amount'];
        final String keyId = orderData['keyId'] ?? "rzp_test_TThQ1dclehkMIs";

        activeBookingCode = bCode;
        activeRazorpayOrderId = orderId;

        var options = {
          'key': keyId,
          'amount': amountPaise,
          'currency': 'INR',
          'name': 'BIG TV',
          'description': 'Retry Payment for Booking: $bCode',
          'order_id': orderId,
          'prefill': {
            'contact': booking['userPhone'] ?? '',
            'email': booking['userEmail'] ?? ''
          },
          'theme': {'color': '#E11D48'},
          'checkout': {
            'method': {'netbanking': '1', 'card': '1', 'upi': '1', 'wallet': '1'}
          }
        };

        _razorpay.open(options);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? "Unable to initiate retry order")),
        );
        setState(() => retryingBookingCode = null);
      }
    } catch (e) {
      debugPrint("❌ Exception in Retry Payment: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to retry payment: $e")),
      );
      setState(() => retryingBookingCode = null);
    }
  }

  Future<void> fetchUserBookings() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId") ?? "79833";
      if (userId.isEmpty || userId == "guest") {
        userId = "79833";
      }

      final url = 'https://api.pravasamedia.com/api/v1/bookings?userId=$userId&page=1&limit=10';
      debugPrint("Fetching bookings API: GET $url");

      final response = await Dio().get(url);
      debugPrint("Bookings response status: ${response.statusCode}");
      debugPrint("Bookings response data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        setState(() {
          userBookings = data;
        });
      }
    } catch (e) {
      debugPrint("Error fetching user bookings: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildEventImageWidget(String? rawUrl, double width, double height) {
    String? formattedUrl;
    if (rawUrl != null && rawUrl.trim().isNotEmpty && !rawUrl.contains('unsplash.com/photo-1543857778-c4a1a3e0b2eb')) {
      final str = rawUrl.trim();
      if (str.startsWith('http')) {
        formattedUrl = str;
      } else if (str.startsWith('/')) {
        formattedUrl = "https://api.pravasamedia.com$str";
      } else {
        formattedUrl = "https://api.pravasamedia.com/$str";
      }
    }

    Widget fallback = Image.network(
      'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&q=80&w=600&h=400',
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.festival_rounded, color: Colors.white, size: 24),
              const SizedBox(height: 2),
              Image.asset('assets/images/BigTvPostLogo.png', height: 12),
            ],
          ),
        ),
      ),
    );

    if (formattedUrl == null) {
      return fallback;
    }

    return Image.network(
      formattedUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => fallback,
    );
  }

  String _formatEventDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "Fri, 25 Dec 2026 • 06:00 PM";
    try {
      final DateTime dt = DateTime.parse(rawDate);
      final String formattedDate = DateFormat('EEE, d MMM yyyy').format(dt);
      final String formattedTime = DateFormat('hh:mm a').format(dt);
      return "$formattedDate • $formattedTime";
    } catch (e) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColorTokens.primaryRed,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "My tickets",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: fetchUserBookings,
        color: AppColorTokens.primaryRed,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : userBookings.isEmpty
                ? _buildEmptyState()
                : _buildTicketsList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no_tickets.png',
              width: 180.w,
              height: 180.w,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => Icon(
                Icons.confirmation_number_outlined,
                size: 100.w,
                color: Colors.red.shade300,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              "No tickets found",
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              "Your booked tickets will appear here.\nFind an event and make a plan!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: userBookings.length,
      itemBuilder: (context, index) {
        final booking = userBookings[index];
        final event = (booking['event'] as Map<String, dynamic>?) ?? {};
        final ticketType = (booking['ticketType'] as Map<String, dynamic>?) ?? {};

        final String eventName = event['name'] ?? "BIGTV Folk Night Patala Jathara 2026";
        final String eventDate = _formatEventDate(event['date']);
        final String eventLocation = event['location'] ?? "Gachibowli Stadium, Hyderabad";
        String? validEventImg;
        if (event['images'] != null) {
          if (event['images'] is List && (event['images'] as List).isNotEmpty) {
            validEventImg = (event['images'] as List)[0]?.toString();
          } else if (event['images'] is String) {
            validEventImg = event['images'].toString();
          }
        }
        validEventImg ??= booking['eventImageUrl']?.toString();
        validEventImg ??= event['image']?.toString();
        validEventImg ??= event['imageUrl']?.toString();

        final int quantity = (booking['quantity'] as num?)?.toInt() ?? 1;
        final int totalAmount = (booking['totalAmount'] as num?)?.toInt() ?? 0;
        final String ticketTypeName = ticketType['name'] ?? "VIP Pass";
        final String bookingCode = booking['bookingCode'] ?? "BKS-000000";
        
        final String bStatus = (booking['bookingStatus'] ?? "").toString().toUpperCase();
        final String pStatus = (booking['paymentStatus'] ?? "").toString().toUpperCase();

        final bool isConfirmed = bStatus == "CONFIRMED" || pStatus == "PAID";
        final bool isCompleted = bStatus == "COMPLETED";
        final bool isFailed = pStatus == "FAILED";
        final bool isPending = (bStatus == "PENDING" || pStatus == "PENDING") && !isFailed;
        final bool isCancelled = bStatus == "CANCELLED" || pStatus == "REFUNDED";

        final bool canRetry = (isFailed || isPending) && !isCancelled;
        final bool isRetryingThis = retryingBookingCode == bookingCode;

        // Badge styling
        Color badgeBg = const Color(0xFFFEF3C7);
        Color badgeFg = const Color(0xFFD97706);
        IconData badgeIcon = Icons.access_time_rounded;
        String badgeText = "Payment Pending";

        if (isCompleted) {
          badgeBg = const Color(0xFFE0F2FE);
          badgeFg = const Color(0xFF0284C7);
          badgeIcon = Icons.verified_user_rounded;
          badgeText = "Checked in";
        } else if (isConfirmed) {
          badgeBg = const Color(0xFFE6F4EA);
          badgeFg = const Color(0xFF1E8E3E);
          badgeIcon = Icons.check_circle_rounded;
          badgeText = "Booking confirmed";
        } else if (isFailed) {
          badgeBg = const Color(0xFFFEE2E2);
          badgeFg = const Color(0xFFDC2626);
          badgeIcon = Icons.error_outline_rounded;
          badgeText = "Payment failed";
        } else if (isCancelled) {
          badgeBg = const Color(0xFFF1F5F9);
          badgeFg = const Color(0xFF64748B);
          badgeIcon = Icons.cancel_rounded;
          badgeText = "Cancelled";
        }

        return Card(
          color: const Color(0xFFFFF7F7),
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 2,
          shadowColor: AppColorTokens.primaryRed.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColorTokens.primaryRed.withValues(alpha: 0.15)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketDetailScreen(booking: booking),
                ),
              );
              if (result == true) {
                fetchUserBookings();
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildEventImageWidget(validEventImg, 80.w, 80.w),
                      ),
                      SizedBox(width: 12.w),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              eventName,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 13, color: AppColorTokens.primaryRed),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    eventDate,
                                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 3.h),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 13, color: AppColorTokens.primaryRed),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    eventLocation,
                                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 12.h),
                  Divider(color: Colors.grey.shade200, height: 1),
                  SizedBox(height: 12.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(badgeIcon, size: 13, color: badgeFg),
                                  SizedBox(width: 4.w),
                                  Text(
                                    badgeText,
                                    style: TextStyle(
                                      color: badgeFg,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              "$quantity ${quantity > 1 ? 'Tickets' : 'Ticket'} • $ticketTypeName • ₹$totalAmount",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF334155),
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              "Code: $bookingCode",
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          if (canRetry) ...[
                            ElevatedButton(
                              onPressed: isRetryingThis ? null : () => _retryPayment(booking),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColorTokens.primaryRed,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: isRetryingThis
                                  ? SizedBox(
                                      width: 14.w,
                                      height: 14.w,
                                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(
                                      "Retry Pay",
                                      style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                            ),
                            SizedBox(width: 8.w),
                          ],
                          // View QR Button
                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TicketDetailScreen(booking: booking),
                                ),
                              );
                              if (result == true) {
                                fetchUserBookings();
                              }
                            },
                            child: Container(
                              width: 52.w,
                              height: 52.w,
                              decoration: BoxDecoration(
                                color: AppColorTokens.primaryRed.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColorTokens.primaryRed.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.qr_code_2_rounded,
                                    color: AppColorTokens.primaryRed,
                                    size: 26.w,
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    "View QR",
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColorTokens.primaryRed,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

