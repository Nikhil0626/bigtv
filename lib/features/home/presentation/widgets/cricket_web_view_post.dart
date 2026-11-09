import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class CricketWebViewPost extends StatefulWidget {
  final String webUrl;

  const CricketWebViewPost({
    super.key,
    required this.webUrl,
  });

  @override
  State<CricketWebViewPost> createState() => _CricketWebViewPostState();
}

class _CricketWebViewPostState extends State<CricketWebViewPost> {
  late final WebViewController _controller;
  int _loadingPercentage = 0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnPlatformPermissionRequest((request) => request.grant());
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0C0508))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingPercentage = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _loadingPercentage = 0;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _loadingPercentage = 100;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('Cricket WebView Error: ${error.errorCode} - ${error.description}');
            if (mounted && error.isForMainFrame == true) {
              setState(() {
                _hasError = true;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
              return NavigationDecision.navigate;
            }
            if (uri != null) {
              launchUrl(uri, mode: LaunchMode.externalApplication);
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    final cleanUrl = widget.webUrl.trim();
    if (cleanUrl.isNotEmpty) {
      final uri = Uri.tryParse(cleanUrl);
      if (uri != null) {
        controller.loadRequest(uri);
      }
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF0C0508),
      child: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          children: [
            // Top Sleek Header Bar
            _buildTopBar(),

            // Loading Progress Indicator
            if (_loadingPercentage < 100)
              LinearProgressIndicator(
                value: _loadingPercentage / 100,
                color: const Color(0xFFE50914),
                backgroundColor: const Color(0xFF1E1E24),
                minHeight: 2.5.h,
              ),

            // Main WebView Area
            Expanded(
              child: _hasError
                  ? _buildErrorWidget()
                  : WebViewWidget(controller: _controller),
            ),

            // Bottom Swipe Hint Bar
            _buildBottomSwipeHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: const BoxDecoration(
        color: Color(0xFF14080E),
        border: Border(
          bottom: BorderSide(color: Color(0xFF2B141C), width: 1),
        ),
      ),
      child: Row(
        children: [
          // BIG TV Red Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE50914),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              "BIG TV",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            "|",
            style: TextStyle(
              color: Colors.white24,
              fontSize: 13.sp,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(width: 8.w),
          // Cricket title with cricket bat icon
          Expanded(
            child: Row(
              children: [
                Text(
                  "🏏",
                  style: TextStyle(fontSize: 14.sp),
                ),
                SizedBox(width: 5.w),
                Flexible(
                  child: Text(
                    "క్రికెట్ లైవ్ స్కోర్",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Reload button
          InkWell(
            onTap: () => _controller.reload(),
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: Icon(
                Icons.refresh_rounded,
                color: Colors.white70,
                size: 20.sp,
              ),
            ),
          ),

          SizedBox(width: 6.w),

          // Open in Browser button
          InkWell(
            onTap: () {
              final uri = Uri.tryParse(widget.webUrl.trim());
              if (uri != null) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.all(5.w),
              child: Icon(
                Icons.open_in_browser_rounded,
                color: Colors.white70,
                size: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 48.sp),
          SizedBox(height: 12.h),
          Text(
            "స్కోర్‌బోర్డ్ లోడ్ చేయడం విఫలమైంది",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          ElevatedButton.icon(
            onPressed: () => _controller.reload(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
            icon: Icon(Icons.refresh, size: 16.sp, color: Colors.white),
            label: Text(
              "మళ్లీ ప్రయత్నించండి",
              style: TextStyle(fontSize: 12.sp, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSwipeHint() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 6.h),
      decoration: const BoxDecoration(
        color: Color(0xFF14080E),
        border: Border(
          top: BorderSide(color: Color(0xFF2B141C), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.keyboard_double_arrow_up_rounded,
            color: const Color(0xFFE50914),
            size: 16.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            "తదుపరి వార్తల కోసం స్వైప్ చేయండి",
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

