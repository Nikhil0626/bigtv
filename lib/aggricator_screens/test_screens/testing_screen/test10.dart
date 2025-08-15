import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() => runApp(MaterialApp(home: WebViewScreen()));

class WebViewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WebView')),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('http://chota-static.s3-website-us-east-1.amazonaws.com/'),
        ),
      ),
    );
  }
}
