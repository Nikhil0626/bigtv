import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String webUrl;
  final String title;
  final bool isHome;

  const InAppWebViewScreen({
    super.key,
    required this.webUrl,
    required this.title,
    this.isHome = false,
  });

  @override
  State<InAppWebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<InAppWebViewScreen> {
  late final WebViewController webViewController;
  String? pageTitle;
  var loadingPercentage = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
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

    // Android-specific settings
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
        ..setMediaPlaybackRequiresUserGesture(false)
        ..setOnPlatformPermissionRequest((request) {
          request.grant(); // Grant microphone/camera access if requested
        });
    }

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => loadingPercentage = progress);
          },
          onPageStarted: (String url) {
            setState(() => loadingPercentage = 0);
          },
          onPageFinished: (String url) async {
            setState(() => loadingPercentage = 100);
            final title = await controller.getTitle();
            if (mounted) setState(() => pageTitle = title);
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${error.description}')),
              );
            }
          },
          onNavigationRequest: (request) {
            // Allow only YouTube embed or safe domains
            if (request.url.contains('youtube.com') ||
                request.url.contains('youtube-nocookie.com') ||
                request.url.contains('youtu.be') ||
                request.url.contains('embed')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
      ..loadRequest(Uri.parse(widget.webUrl));

    webViewController = controller;
  }

  Future<bool> _handleBackButton() async {
    if (await webViewController.canGoBack()) {
      await webViewController.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackButton,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.title.isEmpty
            ? null
            : AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 23),
            onPressed: () async {
              if (await webViewController.canGoBack()) {
                await webViewController.goBack();
              } else if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
          centerTitle: false,
          title: Text(
            pageTitle ?? widget.title,
            style: TextStyle(
              color: AppColors.textColor,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () => webViewController.reload(),
            ),
          ],
        ),
        body: Column(
          children: [
            if (loadingPercentage < 100)
              LinearProgressIndicator(
                value: loadingPercentage / 100,
                color: Colors.blue,
                backgroundColor: Colors.grey[200],
              ),
            Expanded(
              child: SizedBox(
                height: widget.isHome
                    ? MediaQuery.of(context).size.height * 0.56
                    : null,
                child: WebViewWidget(
                  controller: webViewController,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

