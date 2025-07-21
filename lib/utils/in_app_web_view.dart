import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebViewScreen extends StatefulWidget {
  final String webUrl;
  final String title;
  final bool isHome;

  const InAppWebViewScreen({super.key, required this.webUrl,required this.title,this.isHome=false});

  @override
  State<InAppWebViewScreen> createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late InAppWebViewController webViewController; // Declare the controller
  String? pageTitle;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.title==""?null: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(onPressed: () {
          Navigator.pop(context);

        },
            icon: Icon(Icons.arrow_back,color: Colors.black,size: 23,)),
        centerTitle: false,
        title: Text(
          widget.title,
          style: TextStyle(color: AppColors.textColor, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SizedBox(
        height: widget.isHome?MediaQuery.of(context).size.height*.56:MediaQuery.of(context).size.height,
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(widget.webUrl.toString())),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
        ),
      ),
    );
  }
}
