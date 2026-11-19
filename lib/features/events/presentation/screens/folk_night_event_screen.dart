import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/core/theme/themed_popup_palette.dart';
import 'package:chotanews/features/events/presentation/screens/folk_night_booking_screen.dart';
import 'package:chotanews/features/events/presentation/screens/my_tickets_screen.dart';
import 'package:chotanews/features/home/presentation/widgets/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:chotanews/services/content_share_dispatcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/globel_keys/globel_keys.dart';
import 'package:chotanews/main.dart';

class FolkNightEventScreen extends StatefulWidget {
  final String? eventId;
  final bool initialLoading;
  final bool autoFetch;
  const FolkNightEventScreen({
    super.key,
    this.eventId,
    this.initialLoading = true,
    this.autoFetch = true,
  });

  @override
  State<FolkNightEventScreen> createState() => _FolkNightEventScreenState();
}

class _FolkNightEventScreenState extends State<FolkNightEventScreen> {
  late bool isLoading;
  String eventId = "e4d962de-5393-4541-a792-4c23f1429f9c";
  String name = "Folk Night";
  String description = "Experience the rich cultural heritage of Telangana and Andhra Pradesh with captivating folk music, dance and live performances by renowned artists.\n\nA celebration of our roots, our people and timeless traditions.";
  String dateStr = "Sat, 24 Oct • 6:00 PM";
  String location = "Hyderabad • Open Air Auditorium";
  String postUrl = "";
  List<String> images = [];
  List<dynamic> eventCoupons = [];
  int currentImageIndex = 0;

  late PageController _pageController;
  Timer? _carouselTimer;
  CancelToken? _dioCancelToken;

  @override
  void initState() {
    super.initState();
    isLoading = widget.initialLoading;
    if (widget.eventId != null && widget.eventId!.isNotEmpty) {
      eventId = widget.eventId!;
    }
    _pageController = PageController();
    if (widget.autoFetch) {
      fetchEventData();
    }
  }

  bool _hasCleanedUp = false;

  void _cleanupAndRestoreHome([HomeProvider? provider]) {
    if (_hasCleanedUp) return;
    _hasCleanedUp = true;

    if (Platform.isAndroid) {
      try {
        const MethodChannel("com.chotanews/whatsapp").invokeMethod("clearInitialIntent");
      } catch (_) {}
    }

    try {
      HomeProvider? hp = provider;
      if (hp == null && mounted) {
        try {
          hp = context.read<HomeProvider>();
        } catch (_) {}
      }
      hp ??= mainNavigatorKey.currentContext?.read<HomeProvider>();

      if (hp != null) {
        hp.handleReturnFromFolkNight();
      }
    } catch (e) {
      debugPrint("Error in _cleanupAndRestoreHome in FolkNightEventScreen: $e");
    }
  }

  void _handleBack() {
    HomeProvider? hp;
    try {
      hp = context.read<HomeProvider>();
    } catch (_) {}

    _cleanupAndRestoreHome(hp);

    final nav = Navigator.of(context);
    final mainNav = mainNavigatorKey.currentState;

    if (nav.canPop()) {
      nav.pop();
    } else if (mainNav != null && mainNav.canPop()) {
      mainNav.pop();
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
        (route) => false,
      );
    }
  }

  @override
  void dispose() {
    _dioCancelToken?.cancel('Screen disposed');
    _carouselTimer?.cancel();
    _pageController.dispose();
    _cleanupAndRestoreHome();
    super.dispose();
  }

  void _startAutoScroll() {
    _carouselTimer?.cancel();
    if (images.length <= 1) return;
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && images.isNotEmpty) {
        final nextPage = (currentImageIndex + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> fetchEventData() async {
    try {
      _dioCancelToken?.cancel();
      _dioCancelToken = CancelToken();
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      Response response;
      try {
        response = await dio.get(
          'https://api.pravasamedia.com/api/v1/events/$eventId',
          cancelToken: _dioCancelToken,
        );
      } catch (_) {
        if (_dioCancelToken?.isCancelled ?? false) return;
        response = await dio.get(
          'https://api.pravasamedia.com/api/v1/events?city=Hyderabad&type=Concert&page=1&limit=10',
          cancelToken: _dioCancelToken,
        );
      }
      if (_dioCancelToken?.isCancelled ?? false) return;
      if (response.statusCode == 200 && response.data['success'] == true) {
        final dynamic raw = response.data['data'];
        final Map<String, dynamic>? event = raw is List
            ? (raw.isNotEmpty ? Map<String, dynamic>.from(raw.first as Map) : null)
            : (raw is Map ? Map<String, dynamic>.from(raw) : null);
        if (event != null && mounted) {
          setState(() {
            eventId = event['id'] ?? eventId;
            name = event['name'] ?? name;
            description = event['description'] ?? description;
            postUrl = event['postUrl']?.toString() ?? postUrl;
            
            if (event['images'] != null && event['images'].isNotEmpty) {
              images = List<String>.from(event['images']);
            }
            if (event['coupons'] != null && event['coupons'] is List) {
              eventCoupons = List<dynamic>.from(event['coupons']);
            }

            String dStr = "";
            if (event['date'] != null) {
              try {
                DateTime dt = DateTime.parse(event['date']);
                dStr = DateFormat('EEE, d MMM').format(dt);
              } catch (e) {
                // ignore
              }
            }
            if (event['time'] != null) {
              dStr += " • ${event['time']}";
            }
            if (dStr.isNotEmpty) {
              dateStr = dStr;
            }

            String locStr = "";
            if (event['location'] != null) {
              locStr = event['location'];
            }
            if (locStr.isNotEmpty) {
              location = locStr;
            }
          });
          _startAutoScroll();
        }
      }
    } catch (e) {
      debugPrint("Error fetching events: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _startAutoScroll();
      }
    }
  }

  bool _isSharing = false;

  Future<void> _shareEvent() async {
    if (_isSharing) return;
    setState(() {
      _isSharing = true;
    });

    try {
      final String shareLink = postUrl.isNotEmpty
          ? postUrl
          : "https://app.bigtv24x7.com/events?eventId=$eventId";
      final String shareText = "$name\n📍 $location\n📅 $dateStr\n\n$shareLink";
      final String? imageUrl = images.isNotEmpty ? images.first : null;

      await ContentShareDispatcher().shareContent(
        context: context,
        shareText: shareText,
        subject: name,
        filePrefix: 'event_share',
        fallbackImageUrl: imageUrl,
        isWhatsAppOnly: false,
      );
    } catch (e) {
      debugPrint("Error sharing event via ContentShareDispatcher: $e");
      try {
        final Size size = MediaQuery.of(context).size;
        final Rect shareOrigin =
            Rect.fromLTWH(0, 0, size.width, size.height / 2);
        final String shareLink = postUrl.isNotEmpty
            ? postUrl
            : "https://app.bigtv24x7.com/events?eventId=$eventId";
        final String shareText =
            "$name\n📍 $location\n📅 $dateStr\n\n$shareLink";
        await Share.share(
          shareText,
          subject: name,
          sharePositionOrigin: shareOrigin,
        );
      } catch (err) {
        debugPrint("Final share fallback failed: $err");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Widget _buildShimmerView() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250.h,
              color: Colors.white,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 220.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 280.w,
                    height: 16.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 180.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 240.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 90.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _cleanupAndRestoreHome();
      },
      child: Scaffold(
      backgroundColor: Colors.white,
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
          onPressed: _handleBack,
        ),
        title: Text(
          "Folk Night",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
          ? _buildShimmerView()
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 80.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image Auto-Scroll Carousel
                      Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1600 / 971,
                            child: images.isNotEmpty
                                ? PageView.builder(
                                    controller: _pageController,
                                    itemCount: images.length,
                                    onPageChanged: (index) {
                                      setState(() {
                                        currentImageIndex = index;
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      final imageUrl = images[index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ImagePreview(
                                                imageUrl: imageUrl,
                                                title: name,
                                              ),
                                            ),
                                          );
                                        },
                                        child: Hero(
                                          tag: imageUrl,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              // Blurred background for differing aspect ratios
                                              CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit: BoxFit.cover,
                                                errorWidget: (c, u, e) => const SizedBox(),
                                              ),
                                              ClipRect(
                                                child: BackdropFilter(
                                                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                                  child: Container(
                                                    color: Colors.black.withValues(alpha: 0.25),
                                                  ),
                                                ),
                                              ),
                                              // Fully visible crisp image without any clipping/cropping
                                              Center(
                                                child: CachedNetworkImage(
                                                  imageUrl: imageUrl,
                                                  fit: BoxFit.contain,
                                                  placeholder: (context, url) => Shimmer.fromColors(
                                                    baseColor: Colors.grey.shade300,
                                                    highlightColor: Colors.grey.shade100,
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      color: Colors.grey.shade300,
                                                    ),
                                                  ),
                                                  errorWidget: (c, u, e) => const Icon(
                                                    Icons.image_not_supported,
                                                    color: Colors.white54,
                                                    size: 48,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : AspectRatio(
                                    aspectRatio: 1600 / 971,
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&q=80&w=800&h=600',
                                      width: double.infinity,
                                      fit: BoxFit.contain,
                                      placeholder: (context, url) => Container(
                                        color: Colors.black12,
                                        child: const Center(
                                          child: Icon(Icons.event, color: Colors.white54, size: 48),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.black12,
                                        child: const Center(
                                          child: Icon(Icons.event, color: Colors.white54, size: 48),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: AppColorTokens.primaryRed.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.circle, color: Colors.white, size: 7),
                                  const SizedBox(width: 5),
                                  Text(
                                    "LIVE EVENT",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (images.length > 1)
                            Positioned(
                              bottom: 8,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      images.length,
                                      (index) => _buildDot(index == currentImageIndex),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: GoogleFonts.poppins(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "An evening of music, dance & tradition",
                              style: GoogleFonts.poppins(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Date & Location
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColorTokens.primaryRed.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.calendar_today_rounded,
                                    color: AppColorTokens.primaryRed,
                                    size: 20.sp,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    dateStr,
                                    style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColorTokens.primaryRed.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.place_rounded,
                                    color: AppColorTokens.primaryRed,
                                    size: 20.sp,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Divider(),
                            ),
                            
                            // About
                            Text(
                              "About the event",
                              style: GoogleFonts.poppins(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: GoogleFonts.poppins(
                                fontSize: 15.sp,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Tags
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _buildTagBadge(Icons.music_note, "Live music"),
                                _buildTagBadge(Icons.directions_walk, "Folk dance"),
                                _buildTagBadge(Icons.family_restroom, "Family friendly"),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Static Floating Book Tickets & Share Buttons
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: () async {
                              SharedPreferences sp = await SharedPreferences.getInstance();
                              bool isGuest = sp.getString("loginType") != "login";

                              if (!context.mounted) return;
                              if (isGuest) {
                                showDialog(
                                  context: context,
                                  builder: (dialogCtx) {
                                    final palette = ThemedPopupPalette.of(dialogCtx);
                                    return AlertDialog(
                                      backgroundColor: palette.backgroundColor,
                                      shape: palette.dialogShape(14),
                                      contentPadding: const EdgeInsets.all(24),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Guest User",
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: palette.titleColor,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            "You are using the app as a guest user. Please login with your mobile number to continue.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: palette.bodyColor,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: palette.accentColor,
                                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () {
                                                try {
                                                  dialogCtx.read<HomeProvider>().isPlayingYoutube(false);
                                                } catch (_) {}
                                                try {
                                                  dialogCtx.read<VideoProvider>().pauseVideo();
                                                } catch (_) {}
                                                Navigator.pop(dialogCtx); // close dialog
                                                Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginBackgroundView()));
                                              },
                                              child: const FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Text(
                                                  "Login with mobile number",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FolkNightBookingScreen(
                                      eventId: eventId,
                                      eventName: name,
                                      eventDateStr: dateStr,
                                      eventLocation: location,
                                      eventImageUrl: images.isNotEmpty ? images.first : '',
                                      initialCoupons: eventCoupons,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColorTokens.primaryRed,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              "Book tickets \u2192",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 50.h,
                        width: 50.h,
                        child: ElevatedButton(
                          key: const Key('folk_night_share_button'),
                          onPressed: _isSharing ? null : _shareEvent,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorTokens.primaryRed,
                            elevation: 4,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSharing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.share,
                                  color: Colors.white,
                                  size: 22,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTagBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.shade50.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColorTokens.primaryRed),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade800,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
