import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;

  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  // Static method to navigate to screen resolution info
  static void showScreenResolutionInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WebViewScreen(
          url: 'http://chota-static.s3-website-us-east-1.amazonaws.com',
        ),
      ),
    );
  }

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;
  Orientation? _currentOrientation;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
            // Inject viewport meta tag after page loads
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _injectViewportMeta();
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize orientation on first call
    if (_currentOrientation == null) {
      _currentOrientation = MediaQuery.of(context).orientation;
    } else {
      final newOrientation = MediaQuery.of(context).orientation;
      if (_currentOrientation != newOrientation) {
        _currentOrientation = newOrientation;
        // Re-inject viewport meta when orientation changes
        if (!isLoading) {
          _injectViewportMeta();
        }
      }
    }
  }

  void _injectViewportMeta() {
    // Check if context is available
    if (!mounted) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    
    final viewportScript = '''
      // Set viewport meta tag
      var viewport = document.querySelector('meta[name="viewport"]');
      if (!viewport) {
        viewport = document.createElement('meta');
        viewport.name = 'viewport';
        document.head.appendChild(viewport);
      }
      viewport.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover';
      
      // Set CSS custom properties for viewport dimensions
      document.documentElement.style.setProperty('--vh', '${screenHeight}px');
      document.documentElement.style.setProperty('--vw', '${screenWidth}px');
      document.documentElement.style.setProperty('--device-pixel-ratio', '$devicePixelRatio');
      
      // Inject CSS for better viewport matching
      var style = document.createElement('style');
      style.textContent = `
        * {
          box-sizing: border-box;
        }
        
        html, body {
          width: ${screenWidth}px !important;
          height: ${screenHeight}px !important;
          margin: 0 !important;
          padding: 0 !important;
          overflow-x: hidden !important;
        }
        
        body {
          font-size: ${16 * devicePixelRatio}px;
          line-height: 1.4;
        }
        
        /* Use viewport units with fallbacks */
        .vh-100 {
          height: ${screenHeight}px !important;
          height: 100vh !important;
        }
        
        .vw-100 {
          width: ${screenWidth}px !important;
          width: 100vw !important;
        }
        
        /* Responsive text sizing */
        @media screen and (max-width: ${screenWidth}px) {
          body {
            font-size: ${14 * devicePixelRatio}px;
          }
        }
      `;
      document.head.appendChild(style);
      
      // Force viewport update
      document.body.style.width = '${screenWidth}px';
      document.body.style.height = '${screenHeight}px';
      
      // Dispatch resize event to trigger any responsive layouts
      window.dispatchEvent(new Event('resize'));
    ''';
    
    _controller.runJavaScript(viewportScript);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Screen Resolution Info'),
        leading: BackButton(),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        width: screenSize.width,
        height: screenSize.height - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
} 