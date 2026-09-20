import 'package:chotanews/core/providers/web_view_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
    
    // Reset provider state on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WebViewProvider>().reset();
    });
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
            if (mounted) {
              context.read<WebViewProvider>().updateLoadingPercentage(progress);
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              context.read<WebViewProvider>().updateLoadingPercentage(0);
            }
          },
          onPageFinished: (String url) async {
            if (mounted) {
              context.read<WebViewProvider>().updateLoadingPercentage(100);
              try {
                final title = await controller.getTitle();
                if (mounted && title != null && title.isNotEmpty) {
                  context.read<WebViewProvider>().updatePageTitle(title);
                }
              } catch (_) {}
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView Error: ${error.errorCode} - ${error.description}');
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

    webViewController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await webViewController.canGoBack()) {
          await webViewController.goBack();
        } else if (context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: widget.title.isEmpty
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                leading: IconButton(
                  icon:
                      const Icon(Icons.arrow_back, color: Colors.black, size: 23),
                  onPressed: () async {
                    if (await webViewController.canGoBack()) {
                      await webViewController.goBack();
                    } else if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
                centerTitle: false,
                title: Consumer<WebViewProvider>(
                  builder: (context, webViewProvider, child) {
                    return Text(
                      webViewProvider.pageTitle ?? widget.title,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
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
            Consumer<WebViewProvider>(
              builder: (context, webViewProvider, child) {
                if (webViewProvider.loadingPercentage < 100) {
                  return LinearProgressIndicator(
                    value: webViewProvider.loadingPercentage / 100,
                    color: Colors.blue,
                    backgroundColor: Colors.grey[200],
                  );
                }
                return const SizedBox.shrink();
              },
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
