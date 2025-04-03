import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String webUrl;
  final String title;

  const InAppWebViewScreen({super.key, required this.webUrl,required this.title});

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late InAppWebViewController webViewController; // Declare the controller
  String? pageTitle;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {
          Navigator.pop(context);

        },
            icon: Icon(Icons.arrow_back,color: Colors.black,size: 23,)),
        centerTitle: true,
        title: Text(
          " ",
          style: TextStyle(color: Colors.lightBlue, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(widget.webUrl.toString())),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
      ),
    );
  }
}
