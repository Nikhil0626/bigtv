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
  
  String? selectedTicketId;
  int selectedTicketCount = 0;
  
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
    if (trimmed.isEmpty) {
      return "Full name is required";
    }
    if (trimmed.length < 2) {
      return "Name must be at least 2 characters";
    }
    return null;
  }

  String? _validateEmail(String val) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) {
      return "Email address is required";
    }
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(trimmed)) {
      return "Please enter a valid email address";
    }
    return null;
  }

  String? _validatePhone(String val) {
    final trimmed = val.trim();
    if (trimmed.isEmpty) {
      return "Mobile number is required";
    }
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
      debugPrint("❌ ERROR: bookingCode is null during payment success handler!");
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
      debugPrint("Payload: $verifyPayload");

      final verifyResponse = await Dio().post(
        'https://api.pravasamedia.com/api/v1/payments/verify',
        data: verifyPayload,
      );

      debugPrint("◀ [API Step 4 Response] Status: ${verifyResponse.statusCode}");
      debugPrint("Response Body: ${verifyResponse.data}");

      if (!mounted) return;
      if (verifyResponse.statusCode == 200 || verifyResponse.statusCode == 201) {
        debugPrint("✅ Payment verified and booking confirmed successfully!");
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
        debugPrint("❌ Payment verification returned status ${verifyResponse.statusCode}");
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
    debugPrint("Code: ${response.code}");
    debugPrint("Message: ${response.message}");

    if (bookingCode != null) {
      try {
        final failurePayload = {
          "bookingId": bookingCode,
          "razorpayOrderId": currentRazorpayOrderId ?? "",
          "reason": response.message ?? "User closed payment window",
        };
        debugPrint("▶ [API Payment Failure] POST https://api.pravasamedia.com/api/v1/payments/failure");
        debugPrint("Payload: $failurePayload");

        final failRes = await Dio().post(
          'https://api.pravasamedia.com/api/v1/payments/failure',
          data: failurePayload,
        );
        debugPrint("◀ [API Payment Failure Response] Status: ${failRes.statusCode}, Data: ${failRes.data}");
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
    debugPrint("=== [Razorpay SDK Callback] EXTERNAL WALLET ===");
    debugPrint("Wallet: ${response.walletName}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  Future<void> fetchTickets() async {
    if (widget.eventId.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    
    try {
      final url = 'https://api.pravasamedia.com/api/v1/events/${widget.eventId}/ticket-types?includeInactive=true';
      debugPrint("▶ [API Fetch Tickets] GET $url");
      final response = await Dio().get(url);
      debugPrint("◀ [API Fetch Tickets Response] Status: ${response.statusCode}, Data: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List data = response.data['data'];
        setState(() {
          tickets = data;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching tickets: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
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
      final selectedTicket = tickets.firstWhere((t) => t['id'] == selectedTicketId, orElse: () => null);
      if (selectedTicket != null) {
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
      debugPrint("▶ [API Step 0: Validate Coupon] GET https://api.pravasamedia.com/api/v1/coupons/validate");
      debugPrint("Params: $queryParams");

      final response = await Dio().get(
        'https://api.pravasamedia.com/api/v1/coupons/validate',
        queryParameters: queryParams,
      );

      debugPrint("◀ [API Step 0 Response] Status: ${response.statusCode}, Body: ${response.data}");

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
        "userName": _nameCtrl.text,
        "userEmail": _emailCtrl.text,
        "userPhone": _phoneCtrl.text,
        "couponCode": _couponCtrl.text.trim().isNotEmpty ? _couponCtrl.text.trim() : null,
      };

      debugPrint("▶ [API Step 1: Create Booking] POST https://api.pravasamedia.com/api/v1/bookings");
      debugPrint("Payload: $bookingPayload");

      final bookingResponse = await Dio().post(
        'https://api.pravasamedia.com/api/v1/bookings',
        data: bookingPayload,
      );

      debugPrint("◀ [API Step 1 Response] Status: ${bookingResponse.statusCode}");
      debugPrint("Response Body: ${bookingResponse.data}");

      bookingCode = bookingResponse.data['data']['bookingCode'];
      debugPrint("Generated Booking Code: $bookingCode");

      // 2. Create Razorpay Order
      final orderPayload = {
        "amount": grandTotal,
        "currency": "INR",
        "bookingId": bookingCode,
      };

      debugPrint("▶ [API Step 2: Create Order] POST https://api.pravasamedia.com/api/v1/payments/create-order");
      debugPrint("Payload: $orderPayload");

      final orderResponse = await Dio().post(
        'https://api.pravasamedia.com/api/v1/payments/create-order',
        data: orderPayload,
      );

      debugPrint("◀ [API Step 2 Response] Status: ${orderResponse.statusCode}");
      debugPrint("Response Body: ${orderResponse.data}");

      final orderData = orderResponse.data['data'];
      final String orderId = orderData['orderId'];
      final int amountPaise = orderData['amount'];
      final String keyId = orderData['keyId'];
      currentRazorpayOrderId = orderId;

      debugPrint("Opening Razorpay Modal for Order ID: $orderId, Key: $keyId, Amount (Paise): $amountPaise");

      // 3. Open Razorpay
      var options = {
        'key': keyId,
        'amount': amountPaise,
        'currency': 'INR',
        'name': 'BIG TV',
        'description': 'Booking Reference: $bookingCode',
        'order_id': orderId,
        'prefill': {
          'contact': _phoneCtrl.text,
          'email': _emailCtrl.text
        },
        'theme': {
          'color': '#E11D48' // primaryRed
        },
        'checkout': {
          'method': {
            'netbanking': '1',
            'card': '1',
            'upi': '1',
            'wallet': '1'
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
      case 1: return 'assets/images/ticket_cycle.png';
      case 2: return 'assets/images/ticket_bike.png';
      case 3: return 'assets/images/ticket_auto.png';
      case 4: return 'assets/images/ticket_car.png';
      case 5: return 'assets/images/ticket_5seater.png';
      case 6: return 'assets/images/ticket_xlcar.png';
      default: return 'assets/images/ticket_xlcar.png';
    }
  }

  Future<void> _showQuantitySelector() async {
    int resultCount = selectedTicketCount > 0 ? selectedTicketCount : 1;
    bool isCustom = false;
    final TextEditingController customCtrl = TextEditingController(
      text: selectedTicketCount > 6 ? selectedTicketCount.toString() : ""
    );

    int? result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
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
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Icon/Image Display
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      key: ValueKey<int>(isCustom ? 7 : resultCount),
                      children: [
                        isCustom
                            ? Icon(
                                Icons.directions_bus,
                                size: 80,
                                color: AppColorTokens.primaryRed,
                              )
                            : Image.asset(
                                _getVehicleAssetPath(resultCount),
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                        SizedBox(height: 8.h),
                        Text(
                          isCustom 
                              ? "Custom" 
                              : "$resultCount Ticket${resultCount > 1 ? 's' : ''}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  
                  // Content area
                  if (isCustom)
                    TextField(
                      controller: customCtrl,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        hintText: "Enter number",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColorTokens.primaryRed, width: 2),
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
                            final isSelected = resultCount == number;
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  resultCount = number;
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColorTokens.primaryRed : Colors.white,
                                  border: Border.all(
                                    color: isSelected ? AppColorTokens.primaryRed : Colors.grey.shade400,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  number.toString(),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: 24.h),
                        GestureDetector(
                          onTap: () {
                            setModalState(() {
                              isCustom = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "Custom number",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  
                  SizedBox(height: 32.h),
                  // Confirm Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isCustom) {
                          int? val = int.tryParse(customCtrl.text);
                          if (val != null && val > 0) {
                            Navigator.pop(context, val);
                          } else {
                            // If empty or invalid, just keep bottom sheet open or show error
                          }
                        } else {
                          Navigator.pop(context, resultCount);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorTokens.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Confirm",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );

    if (result != null) {
      setState(() {
        selectedTicketCount = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalTickets = selectedTicketCount;
    int ticketsTotal = 0;

    if (selectedTicketId != null && selectedTicketCount > 0) {
      final selectedTicket = tickets.firstWhere(
        (t) => t['id'] == selectedTicketId, 
        orElse: () => null
      );
      if (selectedTicket != null) {
        final price = (selectedTicket['price'] as num?)?.toInt() ?? 0;
        ticketsTotal = price * selectedTicketCount;
      }
    }

    int grandTotal = totalTickets > 0 ? (ticketsTotal - discountAmount) + bookingFee : 0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Summary
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          (widget.eventImageUrl.isNotEmpty && !widget.eventImageUrl.contains('unsplash.com/photo-1543857778-c4a1a3e0b2eb'))
                              ? (widget.eventImageUrl.startsWith('http') ? widget.eventImageUrl : 'https://api.pravasamedia.com/${widget.eventImageUrl.startsWith('/') ? widget.eventImageUrl.substring(1) : widget.eventImageUrl}')
                              : 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&q=80&w=600&h=400',
                          width: 80.w,
                          height: 60.w,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            width: 80.w,
                            height: 60.w,
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
                                  const Icon(Icons.festival_rounded, color: Colors.white, size: 20),
                                  const SizedBox(height: 2),
                                  Image.asset('assets/images/BigTvPostLogo.png', height: 10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.eventName,
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 16.sp, color: AppColorTokens.primaryRed),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.eventDateStr,
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.place_rounded, size: 16.sp, color: AppColorTokens.primaryRed),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.eventLocation,
                                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(),
                  ),
                  
                  // Tickets
                  Text(
                    "Choose your tickets",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  if (tickets.isEmpty)
                    Text("No tickets available currently.", style: TextStyle(color: Colors.grey.shade600))
                  else ...[
                    // Dropdown for ticket type
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedTicketId,
                          isExpanded: true,
                          hint: const Text("Select Ticket Type"),
                          icon: Icon(Icons.keyboard_arrow_down, color: AppColorTokens.primaryRed),
                          items: tickets.map<DropdownMenuItem<String>>((t) {
                            final name = t['name'] ?? 'Ticket';
                            final price = (t['price'] as num?)?.toInt() ?? 0;
                            return DropdownMenuItem<String>(
                              value: t['id'],
                              child: Text(
                                "$name - ₹$price",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) async {
                            setState(() {
                              selectedTicketId = value;
                              selectedTicketCount = 0; // reset count on change
                            });
                            if (value != null) {
                              await _showQuantitySelector();
                            }
                          },
                        ),
                      ),
                    ),
                    
                    // Quantity selector
                    if (selectedTicketId != null)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Quantity",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            InkWell(
                              onTap: () => _showQuantitySelector(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selectedTicketCount > 0 ? Colors.white : AppColorTokens.primaryRed,
                                  border: Border.all(color: AppColorTokens.primaryRed),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  selectedTicketCount > 0 ? "$selectedTicketCount Tickets \u270E" : "Select",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: selectedTicketCount > 0 ? AppColorTokens.primaryRed : Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Contact details
                  Text(
                    "Contact details",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    Icons.person_outline, 
                    "Full name", 
                    controller: _nameCtrl,
                    errorText: _nameError,
                    onChanged: (val) {
                      if (_nameError != null) {
                        setState(() => _nameError = _validateName(val));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    Icons.mail_outline, 
                    "you@example.com", 
                    controller: _emailCtrl, 
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailError,
                    onChanged: (val) {
                      if (_emailError != null) {
                        setState(() => _emailError = _validateEmail(val));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    Icons.phone_outlined, 
                    "+91   Mobile number", 
                    controller: _phoneCtrl, 
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    errorText: _phoneError,
                    onChanged: (val) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = _validatePhone(val));
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          Icons.local_offer_outlined, 
                          "Enter coupon code", 
                          controller: _couponCtrl,
                          errorText: _couponError,
                          onChanged: (val) {
                            if (_couponError != null) {
                              setState(() => _couponError = null);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isApplyingCoupon ? null : _applyCoupon,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorTokens.primaryRed,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: isApplyingCoupon 
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                            : const Text("Apply", style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Order summary
                  if (totalTickets > 0) ...[
                    Text(
                      "Order summary",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (selectedTicketId != null)
                      Builder(
                        builder: (context) {
                          final selectedTicket = tickets.firstWhere(
                            (t) => t['id'] == selectedTicketId, 
                            orElse: () => null
                          );
                          if (selectedTicket != null) {
                            final name = selectedTicket['name'] ?? 'Ticket';
                            final price = (selectedTicket['price'] as num?)?.toInt() ?? 0;
                            return _buildSummaryRow("$selectedTicketCount × $name", "₹${selectedTicketCount * price}");
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    if (discountAmount > 0)
                      _buildSummaryRow("Discount", "-₹$discountAmount", isDiscount: true),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "₹$grandTotal",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.mail_outline, size: 16, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          "Your tickets will be sent by email",
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: (grandTotal > 0 && !isProcessingPayment) 
                    ? () => _processBookingAndPayment(totalTickets, grandTotal) 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorTokens.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isProcessingPayment
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        grandTotal > 0 ? "Continue to payment • ₹$grandTotal \u2192" : "Select tickets",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
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
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15.sp),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey.shade300, width: hasError ? 1.5 : 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? Colors.red : AppColorTokens.primaryRed, width: 1.5),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, left: 4.0),
            child: Text(
              errorText,
              style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 15.sp, color: isDiscount ? Colors.green : Colors.grey.shade800),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: isDiscount ? Colors.green : Colors.grey.shade800),
          ),
        ],
      ),
    );
  }
}
