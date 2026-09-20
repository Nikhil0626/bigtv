import 'dart:convert';
import 'dart:io';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/events/presentation/screens/payment_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share_plus/share_plus.dart';

class TicketDetailScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const TicketDetailScreen({super.key, required this.booking});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  int currentTicketIndex = 0;
  final PageController _pageController = PageController();
  late Map<String, dynamic> currentBooking;
  bool isLoadingDetails = false;
  bool isRetryingPayment = false;
  late Razorpay _razorpay;
  String? activeRazorpayOrderId;

  @override
  void initState() {
    super.initState();
    currentBooking = Map<String, dynamic>.from(widget.booking);
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    fetchBookingDetails();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  Future<void> fetchBookingDetails() async {
    final String bookingIdOrCode = currentBooking['id'] ?? currentBooking['bookingCode'] ?? '';
    if (bookingIdOrCode.isEmpty) return;

    setState(() => isLoadingDetails = true);
    try {
      final url = 'https://api.pravasamedia.com/api/v1/bookings/$bookingIdOrCode';
      debugPrint("▶ [API Get Booking] GET $url");
      final response = await Dio().get(url);
      debugPrint("◀ [API Get Booking Response] Status: ${response.statusCode}, Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        if (!mounted) return;
        setState(() {
          currentBooking = Map<String, dynamic>.from(response.data['data']);
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching booking details: $e");
    } finally {
      if (mounted) setState(() => isLoadingDetails = false);
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final bCode = currentBooking['bookingCode'];
    if (bCode == null) return;

    try {
      final verifyPayload = {
        "razorpayOrderId": response.orderId,
        "razorpayPaymentId": response.paymentId,
        "razorpaySignature": response.signature,
        "bookingId": bCode,
      };

      final verifyResponse = await Dio().post(
        'https://api.pravasamedia.com/api/v1/payments/verify',
        data: verifyPayload,
      );

      if (!mounted) return;
      if (verifyResponse.statusCode == 200 || verifyResponse.statusCode == 201) {
        final updatedData = (verifyResponse.data != null && verifyResponse.data['data'] != null)
            ? verifyResponse.data['data']
            : currentBooking;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(booking: Map<String, dynamic>.from(updatedData)),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Verification error: $e");
    } finally {
      if (mounted) setState(() => isRetryingPayment = false);
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    final bCode = currentBooking['bookingCode'];
    if (bCode != null) {
      try {
        final failurePayload = {
          "bookingId": bCode,
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
    setState(() => isRetryingPayment = false);
    fetchBookingDetails();
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  Future<void> _retryPayment() async {
    final bCode = currentBooking['bookingCode'];
    if (bCode == null) return;

    setState(() => isRetryingPayment = true);
    try {
      final response = await Dio().post(
        'https://api.pravasamedia.com/api/v1/payments/retry-order',
        data: {"bookingId": bCode},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final orderData = response.data['data'];
        final String orderId = orderData['orderId'];
        final int amountPaise = orderData['amount'];
        final String keyId = orderData['keyId'] ?? "rzp_test_TThQ1dclehkMIs";

        activeRazorpayOrderId = orderId;

        var options = {
          'key': keyId,
          'amount': amountPaise,
          'currency': 'INR',
          'name': 'BIG TV',
          'description': 'Retry Payment for Booking: $bCode',
          'order_id': orderId,
          'prefill': {
            'contact': currentBooking['userPhone'] ?? '',
            'email': currentBooking['userEmail'] ?? ''
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
          SnackBar(content: Text(response.data['message'] ?? "Failed to create retry order")),
        );
        setState(() => isRetryingPayment = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error retrying payment: $e")),
      );
      setState(() => isRetryingPayment = false);
    }
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

  Future<void> _downloadTickets() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text("Generating ticket PDF..."),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final pdf = pw.Document();

      final event = currentBooking['event'] ?? {};
      final String eventName = event['name'] ?? currentBooking['eventName'] ?? "Folk Night 2026";
      final String location = event['location'] ?? currentBooking['eventLocation'] ?? "Hyderabad";
      final String dateStr = _formatEventDate(event['date'] ?? currentBooking['date']);
      final String bookingCode = currentBooking['bookingCode'] ?? currentBooking['id'] ?? "BK-0001";
      final String userName = currentBooking['userName'] ?? currentBooking['name'] ?? "Guest";
      final String userPhone = currentBooking['userPhone'] ?? currentBooking['phone'] ?? "";
      final num totalAmount = currentBooking['totalAmount'] ?? currentBooking['amount'] ?? 0;
      
      final List tickets = currentBooking['tickets'] is List ? currentBooking['tickets'] : [];
      Uint8List? qrBytes;
      if (tickets.isNotEmpty) {
        final firstTicket = tickets.first;
        qrBytes = _getQrImageBytes(firstTicket['qrCode']);
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(24),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.all(16),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.red800,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          "BIGTV EVENTS - TICKET",
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          bookingCode,
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 15,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 24),
                  pw.Text(
                    eventName,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.black,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text("Date & Time: $dateStr", style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 6),
                  pw.Text("Location: $location", style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 6),
                  pw.Text("Guest Name: $userName ($userPhone)", style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 6),
                  pw.Text("Total Paid: Rs. $totalAmount", style: const pw.TextStyle(fontSize: 14)),
                  pw.SizedBox(height: 24),
                  pw.Divider(thickness: 1, color: PdfColors.grey400),
                  pw.SizedBox(height: 20),
                  if (qrBytes != null)
                    pw.Center(
                      child: pw.Column(
                        children: [
                          pw.Image(pw.MemoryImage(qrBytes), width: 180, height: 180),
                          pw.SizedBox(height: 8),
                          pw.Text("Scan QR Code at Event Entrance", style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                        ],
                      ),
                    ),
                  pw.Spacer(),
                  pw.Center(
                    child: pw.Text(
                      "Thank you for booking with BIG TV News! Present this ticket at entry.",
                      style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      String targetPath = "${directory.path}/Ticket_$bookingCode.pdf";
      try {
        if (Platform.isAndroid) {
          final downloadDir = Directory('/storage/emulated/0/Download');
          if (await downloadDir.exists()) {
            targetPath = "${downloadDir.path}/Ticket_$bookingCode.pdf";
          }
        }
        final file = File(targetPath);
        await file.writeAsBytes(await pdf.save());
      } catch (e) {
        final file = File(targetPath);
        await file.writeAsBytes(await pdf.save());
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ticket saved to $targetPath"),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: "View",
            onPressed: () {
              _showTicketViewModal(context);
            },
          ),
        ),
      );

      await Share.shareXFiles([XFile(targetPath)], text: "Ticket for $eventName");
    } catch (e, st) {
      debugPrint("Error downloading ticket PDF: $e\n$st");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to download ticket: $e")),
        );
      }
    }
  }

  void _showTicketViewModal(BuildContext context) {
    final event = currentBooking['event'] ?? {};
    final String eventName = event['name'] ?? currentBooking['eventName'] ?? "Folk Night 2026";
    final String location = event['location'] ?? currentBooking['eventLocation'] ?? "Hyderabad";
    final String dateStr = _formatEventDate(event['date'] ?? currentBooking['date']);
    final String bookingCode = currentBooking['bookingCode'] ?? currentBooking['id'] ?? "BK-0001";
    final List tickets = currentBooking['tickets'] is List ? currentBooking['tickets'] : [];
    Uint8List? qrBytes;
    if (tickets.isNotEmpty) {
      final firstTicket = tickets.first;
      qrBytes = _getQrImageBytes(firstTicket['qrCode']);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Ticket Preview",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColorTokens.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "BIGTV PASS",
                                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    bookingCode,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              eventName,
                              style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text("📅 $dateStr", style: const TextStyle(color: Colors.white70)),
                            Text("📍 $location", style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (qrBytes != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            children: [
                              Image.memory(qrBytes, width: 200, height: 200),
                              const SizedBox(height: 12),
                              Text(
                                "Show this QR code at the entrance",
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _downloadTickets();
                  },
                  icon: const Icon(Icons.download_rounded, color: Colors.white),
                  label: const Text("Download PDF Ticket", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorTokens.primaryRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Uint8List? _getQrImageBytes(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      String cleanStr = base64Str;
      if (cleanStr.contains(',')) {
        cleanStr = cleanStr.split(',').last;
      }
      return base64Decode(cleanStr);
    } catch (e) {
      debugPrint("Error decoding base64 QR: $e");
      return null;
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

  @override
  Widget build(BuildContext context) {
    final booking = currentBooking;
    final event = (booking['event'] as Map<String, dynamic>?) ?? {};
    final ticketType = (booking['ticketType'] as Map<String, dynamic>?) ?? {};

    final String eventName = event['name'] ?? "BIGTV Folk Night Patala Jathara 2026";
    final String eventDate = _formatEventDate(event['date']);
    final String eventLocation = event['location'] ?? "Gachibowli Stadium, Hyderabad";
    String? validEventImg;
    if (event['images'] != null && (event['images'] as List).isNotEmpty) {
      final candidate = event['images'][0]?.toString();
      if (candidate != null && candidate.isNotEmpty && !candidate.contains('unsplash.com')) {
        validEventImg = candidate;
      }
    }
    if (validEventImg == null && booking['eventImageUrl'] != null) {
      final candidate = booking['eventImageUrl'].toString();
      if (candidate.isNotEmpty && !candidate.contains('unsplash.com')) {
        validEventImg = candidate;
      }
    }
    if (validEventImg == null && event['image'] != null) {
      final candidate = event['image'].toString();
      if (candidate.isNotEmpty && !candidate.contains('unsplash.com')) {
        validEventImg = candidate;
      }
    }
    final String eventImg = validEventImg ?? '';

    final int quantity = (booking['quantity'] as num?)?.toInt() ?? 1;
    final String ticketTypeName = ticketType['name'] ?? "VIP Pass";
    final String bookingCode = booking['bookingCode'] ?? "BTV246810";
    
    final String bStatus = (booking['bookingStatus'] ?? "").toString().toUpperCase();
    final String pStatus = (booking['paymentStatus'] ?? "").toString().toUpperCase();

    final bool isConfirmed = bStatus == "CONFIRMED" || pStatus == "PAID";
    final bool isCompleted = bStatus == "COMPLETED";
    final bool isFailed = pStatus == "FAILED";
    final bool isPending = (bStatus == "PENDING" || pStatus == "PENDING") && !isFailed;
    final bool isCancelled = bStatus == "CANCELLED" || pStatus == "REFUNDED";

    final String? qrBase64Str = booking['qrCodeBase64'];
    final Uint8List? qrImageBytes = _getQrImageBytes(qrBase64Str);
    final String verifyUrl = booking['verifyUrl'] ?? 'https://api.pravasamedia.com/api/v1/bookings/verify-qr/$bookingCode';

    // Badge styling
    Color badgeBg = const Color(0xFFFEF3C7);
    Color badgeFg = const Color(0xFFD97706);
    IconData badgeIcon = Icons.access_time_rounded;
    String badgeText = "Booking pending";

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

    return Scaffold(
      backgroundColor: Colors.white,
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
          onPressed: () => Navigator.pop(context, true),
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
      body: isLoadingDetails
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      children: [
                        // Retry Payment Banner if Pending or Failed
                        if ((isFailed || isPending) && !isCancelled) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    isFailed
                                        ? "Payment failed. Retry to activate ticket."
                                        : "Payment pending. Retry to activate ticket.",
                                    style: TextStyle(fontSize: 11.sp, color: const Color(0xFF991B1B)),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: isRetryingPayment ? null : _retryPayment,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColorTokens.primaryRed,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: isRetryingPayment
                                      ? SizedBox(width: 12.w, height: 12.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Text("Retry Pay", style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],

                        // Single Ticket Card - Fills available vertical space
                        Expanded(
                          child: _buildSingleTicketCard(
                            totalQuantity: quantity,
                            ticketTypeName: ticketTypeName,
                            ticketCode: bookingCode,
                            qrImageBytes: qrImageBytes,
                            verifyUrl: verifyUrl,
                            isCompleted: isCompleted,
                            isValid: isConfirmed || isCompleted,
                            eventName: eventName,
                            eventDate: eventDate,
                            eventLocation: eventLocation,
                            eventImg: eventImg,
                            badgeBg: badgeBg,
                            badgeFg: badgeFg,
                            badgeIcon: badgeIcon,
                            badgeText: badgeText,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        // Gate Entrance Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 14, color: Colors.grey.shade600),
                            SizedBox(width: 4.w),
                            Text(
                              "Show QR at entrance.",
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                      ],
                    ),
                  ),
                ),

              ],
            ),
    );
  }

  Widget _buildSingleTicketCard({
    required int totalQuantity,
    required String ticketTypeName,
    required String ticketCode,
    required Uint8List? qrImageBytes,
    required String verifyUrl,
    required bool isCompleted,
    required bool isValid,
    required String eventName,
    required String eventDate,
    required String eventLocation,
    required String eventImg,
    required Color badgeBg,
    required Color badgeFg,
    required IconData badgeIcon,
    required String badgeText,
  }) {
    final Color themeBorderColor = const Color(0xFFE11D48);
    final Color topBgColor = Colors.white;
    final Color bottomBgColor = const Color(0xFFFFF1F2);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ConcertTicketCard(
        topBackgroundColor: topBgColor,
        bottomBackgroundColor: bottomBgColor,
        borderColor: themeBorderColor,
        dividerRatio: 0.28,
        topSection: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _buildEventImageWidget(eventImg, 65.w, 65.w),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      eventName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 11, color: AppColorTokens.primaryRed),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            eventDate,
                            style: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 11, color: AppColorTokens.primaryRed),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            eventLocation,
                            style: TextStyle(fontSize: 10.5.sp, color: Colors.grey.shade700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 11, color: badgeFg),
                          SizedBox(width: 4.w),
                          Text(
                            badgeText,
                            style: TextStyle(
                              color: badgeFg,
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomSection: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColorTokens.primaryRed.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "CONCERT PASS",
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorTokens.primaryRed,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  Text(
                    totalQuantity > 1 ? "$totalQuantity Tickets" : "1 Ticket",
                    style: TextStyle(fontSize: 11.sp, color: AppColorTokens.primaryRed, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    ticketTypeName,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "General Admission • Adult",
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                  ),
                ],
              ),
              if (isCompleted) ...[
                Container(
                  width: 125.w,
                  height: 125.w,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_clock_rounded, size: 40, color: Colors.grey),
                      SizedBox(height: 4.h),
                      Text(
                        "Already Used",
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ] else if (qrImageBytes != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    qrImageBytes,
                    width: 125.w,
                    height: 125.w,
                    fit: BoxFit.contain,
                    errorBuilder: (c, e, s) => QrImageView(
                      data: verifyUrl,
                      version: QrVersions.auto,
                      size: 125.w,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ] else ...[
                QrImageView(
                  data: verifyUrl,
                  version: QrVersions.auto,
                  size: 125.w,
                  backgroundColor: Colors.white,
                ),
              ],
              Column(
                children: [
                  Text(
                    isCompleted
                        ? "Checked In at Venue"
                        : isValid
                            ? "Official Digital Ticket QR"
                            : "Payment Pending • Invalid QR",
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? Colors.blue.shade700
                          : isValid
                              ? Colors.green.shade700
                              : Colors.orange.shade800,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Divider(color: Colors.grey.shade300, height: 1),
                  SizedBox(height: 6.h),
                  Text(
                    "Ticket ID: $ticketCode",
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF334155),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConcertTicketCard extends StatelessWidget {
  final Widget topSection;
  final Widget bottomSection;
  final Color topBackgroundColor;
  final Color bottomBackgroundColor;
  final Color borderColor;
  final double dividerRatio;

  const ConcertTicketCard({
    super.key,
    required this.topSection,
    required this.bottomSection,
    this.topBackgroundColor = Colors.white,
    this.bottomBackgroundColor = const Color(0xFFFFF1F2),
    this.borderColor = const Color(0xFFE11D48),
    this.dividerRatio = 0.30,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ConcertTicketPainter(
        dividerRatio: dividerRatio,
        borderColor: borderColor,
        borderWidth: 1.8,
      ),
      child: ClipPath(
        clipper: ConcertTicketClipper(dividerRatio: dividerRatio),
        child: Column(
          children: [
            Expanded(
              flex: (dividerRatio * 100).round(),
              child: Container(
                width: double.infinity,
                color: topBackgroundColor,
                child: topSection,
              ),
            ),
            Expanded(
              flex: ((1 - dividerRatio) * 100).round(),
              child: Container(
                width: double.infinity,
                color: bottomBackgroundColor,
                child: bottomSection,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConcertTicketClipper extends CustomClipper<Path> {
  final double dividerRatio;
  final double notchRadius;
  final double punchRadius;
  final int punchCount;

  ConcertTicketClipper({
    this.dividerRatio = 0.34,
    this.notchRadius = 12.0,
    this.punchRadius = 7.0,
    this.punchCount = 3,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    final double w = size.width;
    final double h = size.height;
    final double dividerY = h * dividerRatio;
    final double r = 16.0;

    // 1. Start top-left
    path.moveTo(r, 0);

    // 2. Straight top edge
    path.lineTo(w - r, 0);
    path.quadraticBezierTo(w, 0, w, r);

    // 3. Right edge down to right notch at dividerY
    path.lineTo(w, dividerY - notchRadius);
    path.arcToPoint(
      Offset(w, dividerY + notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false, // inward cutout
    );
    path.lineTo(w, h - r);
    path.quadraticBezierTo(w, h, w - r, h);

    // 4. Straight bottom edge
    path.lineTo(r, h);
    path.quadraticBezierTo(0, h, 0, h - r);

    // 5. Left edge up to left notch at dividerY
    path.lineTo(0, dividerY + notchRadius);
    path.arcToPoint(
      Offset(0, dividerY - notchRadius),
      radius: Radius.circular(notchRadius),
      clockwise: false, // inward cutout
    );
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant ConcertTicketClipper oldDelegate) => true;
}

class ConcertTicketPainter extends CustomPainter {
  final double dividerRatio;
  final double notchRadius;
  final Color borderColor;
  final double borderWidth;

  ConcertTicketPainter({
    this.dividerRatio = 0.34,
    this.notchRadius = 12.0,
    required this.borderColor,
    this.borderWidth = 1.8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double dividerY = h * dividerRatio;

    // Draw outer outline border along clipped path
    final path = ConcertTicketClipper(
      dividerRatio: dividerRatio,
      notchRadius: notchRadius,
    ).getClip(size);

    final strokePaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // Draw horizontal wave divider line connecting left and right notches
    final wavePaint = Paint()
      ..color = borderColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final wavePath = Path();
    final double startX = notchRadius;
    final double endX = w - notchRadius;
    final double waveLen = endX - startX;
    final int cycles = 14;
    final double cycleW = waveLen / cycles;

    wavePath.moveTo(startX, dividerY);
    for (int i = 0; i < cycles; i++) {
      final double x1 = startX + cycleW * i + cycleW * 0.25;
      final double x2 = startX + cycleW * i + cycleW * 0.75;
      final double xEnd = startX + cycleW * (i + 1);
      final double waveAmp = (i % 2 == 0) ? 3.0 : -3.0;
      wavePath.cubicTo(
        x1, dividerY + waveAmp,
        x2, dividerY + waveAmp,
        xEnd, dividerY,
      );
    }

    canvas.drawPath(wavePath, wavePaint);
  }

  @override
  bool shouldRepaint(covariant ConcertTicketPainter oldDelegate) => true;
}

