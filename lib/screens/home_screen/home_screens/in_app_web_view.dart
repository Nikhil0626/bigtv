import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebViewScreen extends StatefulWidget {
 final String webUrl;
  const InAppWebViewScreen({super.key,required this.webUrl});

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late InAppWebViewController webViewController; // Declare the controller

  @override
  Widget build(BuildContext context) {
    return InAppWebView(

      initialUrlRequest: URLRequest(url: WebUri(widget.webUrl.toString())),
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
    );
  }
}
