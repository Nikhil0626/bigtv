import 'dart:math' as math;
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/events/presentation/screens/my_tickets_screen.dart';
import 'package:chotanews/features/events/presentation/screens/ticket_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FolkNightBookingScreen extends StatefulWidget {
  final String eventId;
  final String eventName;
  final String eventDateStr;
  final String eventLocation;
  final String eventImageUrl;

  const FolkNightBookingScreen({
    super.key,
    this.eventId = "",
    this.eventName = "Folk Night",
    this.eventDateStr = "24 Oct • 6:00 PM",
    this.eventLocation = "Hyderabad • Open Air Auditorium",
    this.eventImageUrl = "",
  });

  @override
  State<FolkNightBookingScreen> createState() => _FolkNightBookingScreenState();
}

class _FolkNightBookingScreenState extends State<FolkNightBookingScreen> {
  bool isLoading = true;
  List<dynamic> tickets = [];

  String _selectedZoneKey = "VIP";
  String? selectedTicketId;
  int selectedTicketCount = 1;

  final int bookingFee = 0;
  int discountAmount = 0;
  String? bookingCode;
  String? currentRazorpayOrderId;
  bool isProcessingPayment = false;
  bool isApplyingCoupon = false;

  late Razorpay _razorpay;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _couponCtrl = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _couponError;

  String? _validateName(String val) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) return "Full name is required";
    if (trimmed.length < 2) return "Name must be at least 2 characters";
    return null;
  }

  String? _validateEmail(String val) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) return "Email address is required";
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(trimmed)) return "Please enter a valid email address";
    return null;
  }

  String? _validatePhone(String val) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) return "Mobile number is required";
    if (trimmed.length != 10 || !RegExp(r"^[6-9]\d{9}$").hasMatch(trimmed)) {
      return "Please enter a valid 10-digit mobile number";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    fetchTickets();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _couponCtrl.dispose();
    super.dispose();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint("=== [Razorpay SDK Callback] PAYMENT SUCCESS ===");
    debugPrint("Payment ID: ${response.paymentId}");
    debugPrint("Order ID: ${response.orderId}");
    debugPrint("Signature: ${response.signature}");
    debugPrint("Stored Booking Code: $bookingCode");

    if (bookingCode == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: Booking code not found.")),
      );
      return;
    }

    try {
      final verifyPayload = {
        "razorpayOrderId": response.orderId,
        "razorpayPaymentId": response.paymentId,
        "razorpaySignature": response.signature,
        "bookingId": bookingCode,
      };

      debugPrint("▶ [API Step 4: Verify Payment] POST https://api.pravasamedia.com/api/v1/payments/verify");
      final verifyResponse = await Dio().post(
        'https://api.pravasamedia.com/api/v1/payments/verify',
        data: verifyPayload,
      );

      if (!mounted) return;
      if (verifyResponse.statusCode == 200 || verifyResponse.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment Successful & Booking Confirmed!")),
        );
        final bookingData = (verifyResponse.data != null && verifyResponse.data['data'] != null)
            ? verifyResponse.data['data']
            : {
                "bookingCode": bookingCode,
                "bookingStatus": "CONFIRMED",
                "paymentStatus": "PAID",
                "event": {
                  "name": widget.eventName,
                  "date": widget.eventDateStr,
                  "location": widget.eventLocation,
                  "images": [widget.eventImageUrl],
                },
              };
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailScreen(booking: Map<String, dynamic>.from(bookingData)),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment verification failed")),
        );
      }
    } catch (e) {
      debugPrint("❌ Exception in Payment Verification API: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification error: $e")),
      );
    }
  }

  Future<void> _handlePaymentError(PaymentFailureResponse response) async {
    debugPrint("=== [Razorpay SDK Callback] PAYMENT ERROR ===");
    if (bookingCode != null) {
      try {
        final failurePayload = {
          "bookingId": bookingCode,
          "razorpayOrderId": currentRazorpayOrderId ?? "",
          "reason": response.message ?? "User closed payment window",
        };
        await Dio().post(
          'https://api.pravasamedia.com/api/v1/payments/failure',
          data: failurePayload,
        );
      } catch (e) {
        debugPrint("❌ Exception in Payment Failure API: $e");
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  static final List<dynamic> defaultTickets = <dynamic>[
    {"id": "vip-001", "name": "VIP", "price": 5000},
    {"id": "plat-002", "name": "Platinum", "price": 2000},
    {"id": "gold-003", "name": "Gold", "price": 1000},
    {"id": "silv-004", "name": "Silver", "price": 500},
  ];

  dynamic _findTicket(String? query) {
    if (query == null || query.isEmpty) return null;
    final effective = tickets.isNotEmpty ? tickets : defaultTickets;
    for (final t in effective) {
      if (t != null && t is Map) {
        final id = (t['id'] ?? '').toString();
        final name = (t['name'] ?? '').toString().toUpperCase();
        if (id == query || name == query.toUpperCase() || name.contains(query.toUpperCase())) {
          return t;
        }
      }
    }
    return null;
  }

  Future<void> fetchTickets() async {
    if (widget.eventId.isEmpty) {
      setState(() {
        tickets = defaultTickets;
        selectedTicketId = defaultTickets[0]['id'];
        _selectedZoneKey = "VIP";
        isLoading = false;
      });
      return;
    }

    try {
      final url = 'https://api.pravasamedia.com/api/v1/events/${widget.eventId}/ticket-types?includeInactive=true';
      final response = await Dio().get(url);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'] ?? [];
        setState(() {
          tickets = data.isNotEmpty ? data : defaultTickets;
          final vip = _findTicket("VIP") ?? (tickets.isNotEmpty ? tickets.first : defaultTickets.first);
          selectedTicketId = vip['id'];
          _syncZoneFromTicketName(vip['name'] ?? 'VIP');
        });
      } else {
        setState(() {
          tickets = defaultTickets;
          selectedTicketId = defaultTickets[0]['id'];
          _selectedZoneKey = "VIP";
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching tickets: $e");
      setState(() {
        tickets = defaultTickets;
        selectedTicketId = defaultTickets[0]['id'];
        _selectedZoneKey = "VIP";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _syncZoneFromTicketName(String name) {
    final upper = name.toUpperCase();
    if (upper.contains("VIP")) {
      _selectedZoneKey = "VIP";
    } else if (upper.contains("PLATINUM")) {
      _selectedZoneKey = "PLATINUM";
    } else if (upper.contains("GOLD")) {
      _selectedZoneKey = "GOLD";
    } else if (upper.contains("SILVER")) {
      _selectedZoneKey = "SILVER";
    }
  }

  void _selectZone(String zoneKey) {
    setState(() {
      _selectedZoneKey = zoneKey;
      final match = _findTicket(zoneKey) ?? (tickets.isNotEmpty ? tickets.first : defaultTickets.first);
      if (match != null && match is Map) {
        selectedTicketId = match['id'];
      }
    });
  }

  Future<void> _applyCoupon() async {
    final code = _couponCtrl.text.trim();
    if (code.isEmpty) {
      setState(() => _couponError = "Please enter a coupon code");
      return;
    } else {
      setState(() => _couponError = null);
    }
    if (widget.eventId.isEmpty) return;

    int ticketsTotal = 0;
    if (selectedTicketId != null && selectedTicketCount > 0) {
      final selectedTicket = _findTicket(selectedTicketId);
      if (selectedTicket != null && selectedTicket is Map) {
        final price = (selectedTicket['price'] as num?)?.toInt() ?? 0;
        ticketsTotal = price * selectedTicketCount;
      }
    }

    if (ticketsTotal == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select tickets first")));
      return;
    }

    setState(() => isApplyingCoupon = true);
    try {
      final queryParams = {
        'code': code,
        'eventId': widget.eventId,
        'amount': ticketsTotal,
      };

      final response = await Dio().get(
        'https://api.pravasamedia.com/api/v1/coupons/validate',
        queryParameters: queryParams,
      );

      if (!mounted) return;
      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          discountAmount = (response.data['data']['discountAmount'] as num).toInt();
          _couponError = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coupon applied successfully")));
      } else {
        final msg = response.data['message'] ?? "Invalid coupon";
        setState(() => _couponError = msg);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      debugPrint("❌ Exception in Coupon Validation API: $e");
      if (!mounted) return;
      setState(() => _couponError = "Failed to apply coupon");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to apply coupon")));
    } finally {
      setState(() => isApplyingCoupon = false);
    }
  }

  Future<void> _processBookingAndPayment(int totalTickets, int grandTotal) async {
    final nameErr = _validateName(_nameCtrl.text);
    final emailErr = _validateEmail(_emailCtrl.text);
    final phoneErr = _validatePhone(_phoneCtrl.text);

    if (nameErr != null || emailErr != null || phoneErr != null) {
      setState(() {
        _nameError = nameErr;
        _emailError = emailErr;
        _phoneError = phoneErr;
      });
      final firstError = nameErr ?? emailErr ?? phoneErr ?? "Please fill all contact details correctly";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(firstError)));
      return;
    }

    setState(() => isProcessingPayment = true);

    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String userId = sp.getString("userId") ?? "USR-1001";

      // 1. Create Booking
      final bookingPayload = {
        "eventId": widget.eventId,
        "ticketTypeId": selectedTicketId,
        "quantity": totalTickets,
        "userId": userId,
        "userName": _nameCtrl.text.trim(),
        "userEmail": _emailCtrl.text.trim(),
        "userPhone": _phoneCtrl.text.trim(),
        "couponCode": _couponCtrl.text.trim().isNotEmpty ? _couponCtrl.text.trim() : null,
      };

      debugPrint("▶ [API Step 1: Create Booking] POST https://api.pravasamedia.com/api/v1/bookings");
      final bookingResponse = await Dio().post(
        'https://api.pravasamedia.com/api/v1/bookings',
        data: bookingPayload,
      );

      bookingCode = bookingResponse.data['data']['bookingCode'];

      // 2. Create Razorpay Order
      final orderPayload = {
        "amount": grandTotal,
        "currency": "INR",
        "bookingId": bookingCode,
      };

      debugPrint("▶ [API Step 2: Create Order] POST https://api.pravasamedia.com/api/v1/payments/create-order");
      final orderResponse = await Dio().post(
        'https://api.pravasamedia.com/api/v1/payments/create-order',
        data: orderPayload,
      );

      final orderData = orderResponse.data['data'];
      final String orderId = orderData['orderId'];
      final int amountPaise = orderData['amount'];
      final String keyId = orderData['keyId'];
      currentRazorpayOrderId = orderId;

      // 3. Open Razorpay
      var options = {
        'key': keyId,
        'amount': amountPaise,
        'currency': 'INR',
        'name': 'BIG TV',
        'description': 'Booking Reference: $bookingCode',
        'order_id': orderId,
        'prefill': {
          'contact': _phoneCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
        },
        'theme': {
          'color': '#E11D48',
        },
        'checkout': {
          'method': {
            'netbanking': '1',
            'card': '1',
            'upi': '1',
            'wallet': '1',
          }
        }
      };

      _razorpay.open(options);
    } catch (e) {
      debugPrint("❌ Exception in Booking & Payment Process: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isProcessingPayment = false);
    }
  }

  String _getVehicleAssetPath(int count) {
    switch (count) {
      case 1:
        return 'assets/images/ticket_cycle.png';
      case 2:
        return 'assets/images/ticket_bike.png';
      case 3:
        return 'assets/images/ticket_auto.png';
      case 4:
        return 'assets/images/ticket_car.png';
      case 5:
        return 'assets/images/ticket_5seater.png';
      case 6:
        return 'assets/images/ticket_xlcar.png';
      default:
        return 'assets/images/ticket_xlcar.png';
    }
  }

  Future<void> _showQuantitySelector() async {
    int resultCount = selectedTicketCount > 0 ? selectedTicketCount : 1;
    bool isCustom = selectedTicketCount > 6;
    final TextEditingController customCtrl = TextEditingController(
      text: selectedTicketCount > 6 ? selectedTicketCount.toString() : "",
    );

    int? result = await showModalBottomSheet<int>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "How many tickets?",
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Column(
                      key: ValueKey<int>(isCustom ? 99 : resultCount),
                      children: [
                        isCustom
                            ? Icon(
                                Icons.directions_bus,
                                size: 70.sp,
                                color: AppColorTokens.primaryRed,
                              )
                            : Image.asset(
                                _getVehicleAssetPath(resultCount),
                                height: 70.h,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.confirmation_number_outlined,
                                  size: 60.sp,
                                  color: AppColorTokens.primaryRed,
                                ),
                              ),
                        SizedBox(height: 8.h),
                        Text(
                          isCustom ? "Custom Count" : "$resultCount Ticket${resultCount > 1 ? 's' : ''}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.h),
                  if (isCustom)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: TextField(
                        controller: customCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: "Enter number",
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(color: Color(0xFFE11D48), width: 1.5),
                          ),
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: List.generate(6, (index) {
                            final number = index + 1;
                            final isSelected = (!isCustom && resultCount == number);
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  isCustom = false;
                                  resultCount = number;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                width: 42.w,
                                height: 42.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? const Color(0xFFE11D48) : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFFE11D48) : Colors.grey.shade300,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  number.toString(),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 16.h),
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              isCustom = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Custom number",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isCustom) {
                          int? val = int.tryParse(customCtrl.text);
                          if (val != null && val > 0) {
                            Navigator.pop(bottomSheetContext, val);
                          }
                        } else {
                          Navigator.pop(bottomSheetContext, resultCount);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorTokens.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && result > 0) {
      setState(() {
        selectedTicketCount = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalTickets = selectedTicketCount;
    int ticketsTotal = 0;
    dynamic selectedTicket;
    if (selectedTicketId != null && selectedTicketCount > 0) {
      selectedTicket = _findTicket(selectedTicketId) ?? _findTicket(_selectedZoneKey);
      if (selectedTicket != null) {
        final price = (selectedTicket['price'] as num?)?.toInt() ?? 0;
        ticketsTotal = price * selectedTicketCount;
      }
    }

    int grandTotal = totalTickets > 0 ? (ticketsTotal - discountAmount) + bookingFee : 0;
    if (grandTotal < 0) grandTotal = 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColorTokens.primaryRed,
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Book Tickets",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyTicketsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.confirmation_number_outlined, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Event Banner Card
                        _buildEventSummaryCard(),

                        SizedBox(height: 14.h),

                        // Amphitheater Seating Visualizer
                        _buildAmphitheaterSection(),

                        SizedBox(height: 14.h),

                        // 2x2 Ticket Category Grid
                        _buildTicketGrid(),

                        SizedBox(height: 16.h),

                        // Quantity Selector Section
                        _buildQuantitySection(),

                        SizedBox(height: 18.h),

                        // Contact Details Form
                        _buildContactDetailsSection(),

                        SizedBox(height: 18.h),

                        // Coupon Code Section
                        _buildCouponSection(),

                        SizedBox(height: 18.h),

                        // Order Summary Section
                        if (totalTickets > 0 && selectedTicket != null)
                          _buildOrderSummarySection(selectedTicket, totalTickets, ticketsTotal, grandTotal),

                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),

                // Fixed Bottom Bar for Payment
                Container(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 12.h,
                    bottom: MediaQuery.of(context).padding.bottom + 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        offset: const Offset(0, -4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: (grandTotal > 0 && !isProcessingPayment && selectedTicketId != null)
                          ? () => _processBookingAndPayment(totalTickets, grandTotal)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorTokens.primaryRed,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 2,
                      ),
                      child: isProcessingPayment
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  grandTotal > 0
                                      ? "Continue to payment • ₹$grandTotal"
                                      : "Select tickets",
                                  style: TextStyle(
                                    color: grandTotal > 0 ? Colors.white : Colors.grey.shade600,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (grandTotal > 0) ...[
                                  SizedBox(width: 8.w),
                                  const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEventSummaryCard() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.network(
              (widget.eventImageUrl.isNotEmpty &&
                      !widget.eventImageUrl.contains('unsplash.com/photo-1543857778-c4a1a3e0b2eb'))
                  ? (widget.eventImageUrl.startsWith('http')
                      ? widget.eventImageUrl
                      : 'https://api.pravasamedia.com/${widget.eventImageUrl.startsWith('/') ? widget.eventImageUrl.substring(1) : widget.eventImageUrl}')
                  : 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&q=80&w=600&h=400',
              width: 74.w,
              height: 56.w,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: 74.w,
                height: 56.w,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFF9F1239)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.festival_rounded, color: Colors.white, size: 24.sp),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.eventName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 12.sp, color: Colors.grey.shade600),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        widget.eventDateStr,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 12.sp, color: Colors.grey.shade600),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        widget.eventLocation,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
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
    );
  }

  Widget _buildAmphitheaterSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "STAGE VIEW",
            style: TextStyle(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w700,
              fontSize: 11.sp,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 36.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF26384C),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF26384C).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              "STAGE",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                letterSpacing: 1.8,
              ),
            ),
          ),
          SizedBox(height: 6.h),
          SizedBox(
            height: 255.h,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    _handleCanvasTap(details.localPosition, constraints.biggest);
                  },
                  child: CustomPaint(
                    size: Size(constraints.maxWidth, 255.h),
                    painter: _AmphitheaterSeatingCanvas(
                      selectedZoneKey: _selectedZoneKey,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleCanvasTap(Offset localPos, Size size) {
    final cx = size.width / 2.0;
    final cy = -10.0;
    final dx = localPos.dx - cx;
    final dy = localPos.dy - cy;

    if (dy < 0) return;

    final dist = math.sqrt(dx * dx + dy * dy);
    if (dist < 40.0) return; // Top above stage

    String clickedZone;
    if (dist < 120.0) {
      clickedZone = "VIP";
    } else if (dist < 170.0) {
      clickedZone = "PLATINUM";
    } else if (dist < 220.0) {
      clickedZone = "GOLD";
    } else {
      clickedZone = "SILVER";
    }

    _selectZone(clickedZone);
  }

  Widget _buildTicketGrid() {
    final zones = [
      {"key": "VIP", "name": "VIP", "price": 5000, "color": const Color(0xFFF87171), "swatch": const Color(0xFFFCA5A5)},
      {"key": "PLATINUM", "name": "Platinum", "price": 2000, "color": const Color(0xFF818CF8), "swatch": const Color(0xFFDDD6FE)},
      {"key": "GOLD", "name": "Gold", "price": 1000, "color": const Color(0xFFFBBF24), "swatch": const Color(0xFFFEF08A)},
      {"key": "SILVER", "name": "Silver", "price": 500, "color": const Color(0xFF94A3B8), "swatch": const Color(0xFFE2E8F0)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Ticket category",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 10.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: zones.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final zone = zones[index];
            final key = zone["key"] as String;
            final name = zone["name"] as String;
            final price = zone["price"] as int;
            final swatch = zone["swatch"] as Color;

            final ticketItem = _findTicket(key);

            final actualPrice = (ticketItem != null && ticketItem['price'] != null)
                ? (ticketItem['price'] as num).toInt()
                : price;

            final isSelected = _selectedZoneKey == key;

            return GestureDetector(
              onTap: () {
                _selectZone(key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFFF1F2) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFE11D48) : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: const Color(0xFFE11D48).withValues(alpha: 0.12),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: swatch,
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: (zone["color"] as Color).withValues(alpha: 0.6),
                          width: 1.0,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "₹$actualPrice",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? const Color(0xFFE11D48) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? const Color(0xFFE11D48) : const Color(0xFF94A3B8),
                          width: isSelected ? 1.5 : 1.2,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 12.sp,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuantitySection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColorTokens.primaryRed.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.people_alt_outlined,
                  color: AppColorTokens.primaryRed,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quantity",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "$selectedTicketCount Ticket${selectedTicketCount > 1 ? 's' : ''}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          InkWell(
            onTap: _showQuantitySelector,
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: const Color(0xFFEF4444)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Change",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE11D48),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFFE11D48), size: 16.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetailsSection() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Contact Details",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),
          _buildTextField(
            Icons.person_outline,
            "Full name",
            controller: _nameCtrl,
            errorText: _nameError,
            onChanged: (val) {
              if (_nameError != null) setState(() => _nameError = _validateName(val));
            },
          ),
          SizedBox(height: 10.h),
          _buildTextField(
            Icons.email_outlined,
            "Email address",
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: (val) {
              if (_emailError != null) setState(() => _emailError = _validateEmail(val));
            },
          ),
          SizedBox(height: 10.h),
          _buildTextField(
            Icons.phone_outlined,
            "Mobile number",
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            errorText: _phoneError,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            onChanged: (val) {
              if (_phoneError != null) setState(() => _phoneError = _validatePhone(val));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCouponSection() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Have a Coupon?",
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _couponCtrl,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "Enter coupon code",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    prefixIcon: Icon(Icons.local_offer_outlined, size: 18.sp, color: Colors.grey.shade600),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Color(0xFFE11D48)),
                    ),
                    errorText: _couponError,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                height: 44.h,
                child: ElevatedButton(
                  onPressed: isApplyingCoupon ? null : _applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: isApplyingCoupon
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text("Apply", style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummarySection(
    dynamic selectedTicket,
    int totalTickets,
    int ticketsTotal,
    int grandTotal,
  ) {
    final ticketName = selectedTicket['name'] ?? 'Ticket';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order summary",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 12.h),
          _buildSummaryRow("$totalTickets × $ticketName", "₹$ticketsTotal"),
          if (discountAmount > 0)
            _buildSummaryRow("Discount", "-₹$discountAmount", isDiscount: true),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: const Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                "₹$grandTotal",
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColorTokens.primaryRed,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.mail_outline, size: 14.sp, color: Colors.grey.shade600),
              SizedBox(width: 6.w),
              Text(
                "Your tickets will be sent by email",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    IconData icon,
    String hint, {
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? errorText,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    final hasError = errorText != null && errorText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: hasError ? Colors.red : AppColorTokens.primaryRed),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: hasError ? Colors.red : Colors.grey.shade300,
                width: hasError ? 1.5 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppColorTokens.primaryRed,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 4.w),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red, fontSize: 11.sp, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14.sp, color: isDiscount ? Colors.green : Colors.grey.shade800),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: isDiscount ? Colors.green : Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Amphitheater Painter with Prominent Realistic Stadium Pod Seats
class _AmphitheaterSeatingCanvas extends CustomPainter {
  final String selectedZoneKey;

  _AmphitheaterSeatingCanvas({
    required this.selectedZoneKey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2.0;
    final cy = -10.0;
    final center = Offset(cx, cy);

    final isVipSelected = selectedZoneKey == "VIP";
    final isPlatSelected = selectedZoneKey == "PLATINUM";
    final isGoldSelected = selectedZoneKey == "GOLD";
    final isSilverSelected = selectedZoneKey == "SILVER";

    const startAngle = math.pi * 0.16;
    const sweepAngle = math.pi * 0.68;
    const aisleHalfAngle = 0.055;

    // Radius ranges with generous breathing space
    final vipIn = 66.0;
    final vipOut = 118.0;
    final platIn = 119.0;
    final platOut = 168.0;
    final goldIn = 169.0;
    final goldOut = 218.0;
    final silverIn = 219.0;
    final silverOut = 264.0;

    // 1. Draw subtle background zone highlight arcs if selected
    if (isVipSelected) _drawZoneHighlight(canvas, center, vipIn, vipOut, startAngle, sweepAngle, const Color(0xFFFCA5A5));
    if (isPlatSelected) _drawZoneHighlight(canvas, center, platIn, platOut, startAngle, sweepAngle, const Color(0xFFDDD6FE));
    if (isGoldSelected) _drawZoneHighlight(canvas, center, goldIn, goldOut, startAngle, sweepAngle, const Color(0xFFFEF08A));
    if (isSilverSelected) _drawZoneHighlight(canvas, center, silverIn, silverOut, startAngle, sweepAngle, const Color(0xFFE2E8F0));

    // 2. Draw Center Aisle with ladder rungs
    _drawCenterAisle(canvas, center, vipIn - 4, silverOut + 4, aisleHalfAngle);

    // 3. Draw Large Stadium Pod Seats for each Zone
    // VIP ZONE (2 Rows)
    _drawZoneSeats(
      canvas: canvas,
      center: center,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      aisleHalfAngle: aisleHalfAngle,
      rowRadii: [80.0, 104.0],
      fillColor: isVipSelected ? const Color(0xFFF87171) : const Color(0xFFFFA4A4),
      strokeColor: isVipSelected ? const Color(0xFFB91C1C) : const Color(0xFFEF4444),
      isSelected: isVipSelected,
    );

    // PLATINUM ZONE (2 Rows)
    _drawZoneSeats(
      canvas: canvas,
      center: center,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      aisleHalfAngle: aisleHalfAngle,
      rowRadii: [130.0, 154.0],
      fillColor: isPlatSelected ? const Color(0xFFA78BFA) : const Color(0xFFDDD6FE),
      strokeColor: isPlatSelected ? const Color(0xFF6D28D9) : const Color(0xFF8B5CF6),
      isSelected: isPlatSelected,
    );

    // GOLD ZONE (2 Rows)
    _drawZoneSeats(
      canvas: canvas,
      center: center,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      aisleHalfAngle: aisleHalfAngle,
      rowRadii: [180.0, 204.0],
      fillColor: isGoldSelected ? const Color(0xFFFACC15) : const Color(0xFFFEF08A),
      strokeColor: isGoldSelected ? const Color(0xFFB45309) : const Color(0xFFF59E0B),
      isSelected: isGoldSelected,
    );

    // SILVER ZONE (2 Rows)
    _drawZoneSeats(
      canvas: canvas,
      center: center,
      startAngle: startAngle,
      sweepAngle: sweepAngle,
      aisleHalfAngle: aisleHalfAngle,
      rowRadii: [230.0, 252.0],
      fillColor: isSilverSelected ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
      strokeColor: isSilverSelected ? const Color(0xFF334155) : const Color(0xFF64748B),
      isSelected: isSilverSelected,
    );

    // 4. Draw Zone Labels on Central Aisle
    _drawAisleLabel(canvas, center, (vipIn + vipOut) / 2, "VIP", const Color(0xFFB91C1C));
    _drawAisleLabel(canvas, center, (platIn + platOut) / 2, "PLATINUM", const Color(0xFF6D28D9));
    _drawAisleLabel(canvas, center, (goldIn + goldOut) / 2, "GOLD", const Color(0xFFB45309));
    _drawAisleLabel(canvas, center, (silverIn + silverOut) / 2, "SILVER", const Color(0xFF334155));
  }

  void _drawZoneHighlight(
    Canvas canvas,
    Offset center,
    double innerR,
    double outerR,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final path = Path()
      ..arcTo(
        Rect.fromCircle(center: center, radius: outerR + 2),
        startAngle - 0.02,
        sweepAngle + 0.04,
        false,
      )
      ..arcTo(
        Rect.fromCircle(center: center, radius: innerR - 2),
        startAngle + sweepAngle + 0.02,
        -(sweepAngle + 0.04),
        false,
      )
      ..close();

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, bgPaint);

    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawPath(path, borderPaint);
  }

  void _drawCenterAisle(
    Canvas canvas,
    Offset center,
    double innerR,
    double outerR,
    double aisleHalfAngle,
  ) {
    const centerAngle = math.pi * 0.5;
    final leftAngle = centerAngle - aisleHalfAngle;
    final rightAngle = centerAngle + aisleHalfAngle;

    final rungPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.7)
      ..strokeWidth = 1.2;

    for (double r = innerR + 4; r <= outerR; r += 12.0) {
      final x1 = center.dx + r * math.cos(leftAngle);
      final y1 = center.dy + r * math.sin(leftAngle);
      final x2 = center.dx + r * math.cos(rightAngle);
      final y2 = center.dy + r * math.sin(rightAngle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), rungPaint);
    }
  }

  void _drawZoneSeats({
    required Canvas canvas,
    required Offset center,
    required double startAngle,
    required double sweepAngle,
    required double aisleHalfAngle,
    required List<double> rowRadii,
    required Color fillColor,
    required Color strokeColor,
    required bool isSelected,
  }) {
    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 1.4 : 1.1;

    const centerAngle = math.pi * 0.5;

    for (final radius in rowRadii) {
      final arcLen = radius * sweepAngle;
      const seatWidth = 13.0;
      const seatGap = 4.8;
      final numSeats = (arcLen / (seatWidth + seatGap)).round().clamp(8, 26);
      final angleStep = sweepAngle / (numSeats + 1);

      for (int s = 1; s <= numSeats; s++) {
        final angle = startAngle + angleStep * s;

        // Leave clearance for central aisle
        if ((angle - centerAngle).abs() < (aisleHalfAngle + 0.04)) continue;

        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle + math.pi * 0.5);

        // Realistic Large Theater / Stadium Chair:
        // 1. Backrest (Upper/Outer part)
        final backrestRRect = RRect.fromRectAndCorners(
          const Rect.fromLTWH(-5.4, 0.8, 10.8, 4.4),
          topLeft: const Radius.circular(1.0),
          topRight: const Radius.circular(1.0),
          bottomLeft: const Radius.circular(2.4),
          bottomRight: const Radius.circular(2.4),
        );

        // 2. Seat Cushion (Front/Inner part towards stage)
        final cushionRRect = RRect.fromRectAndCorners(
          const Rect.fromLTWH(-4.8, -4.8, 9.6, 4.6),
          topLeft: const Radius.circular(2.2),
          topRight: const Radius.circular(2.2),
          bottomLeft: const Radius.circular(1.0),
          bottomRight: const Radius.circular(1.0),
        );

        // 3. Armrests (Left and Right)
        final leftArmrest = RRect.fromRectAndRadius(
          const Rect.fromLTWH(-6.2, -4.0, 1.4, 8.0),
          const Radius.circular(0.7),
        );
        final rightArmrest = RRect.fromRectAndRadius(
          const Rect.fromLTWH(4.8, -4.0, 1.4, 8.0),
          const Radius.circular(0.7),
        );

        // Draw chair components
        canvas.drawRRect(cushionRRect, fillPaint);
        canvas.drawRRect(backrestRRect, fillPaint);
        canvas.drawRRect(leftArmrest, fillPaint);
        canvas.drawRRect(rightArmrest, fillPaint);

        canvas.drawRRect(cushionRRect, strokePaint);
        canvas.drawRRect(backrestRRect, strokePaint);
        canvas.drawRRect(leftArmrest, strokePaint);
        canvas.drawRRect(rightArmrest, strokePaint);

        canvas.restore();
      }
    }
  }

  void _drawAisleLabel(
    Canvas canvas,
    Offset center,
    double radius,
    String label,
    Color color,
  ) {
    const angle = math.pi * 0.5;
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);

    final bgRect = Rect.fromCenter(
      center: Offset(x, y),
      width: label.length * 7.5 + 12,
      height: 16.0,
    );

    final bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(4)), bgPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const Radius.circular(4)), borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    tp.paint(canvas, Offset(x - tp.width / 2, y - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _AmphitheaterSeatingCanvas oldDelegate) {
    return oldDelegate.selectedZoneKey != selectedZoneKey;
  }
}
