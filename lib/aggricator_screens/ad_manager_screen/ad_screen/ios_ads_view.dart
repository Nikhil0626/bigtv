import 'package:flutter/material.dart';
import '../rate_your_app.dart';
import '../share_app.dart';
import '../recommended_news.dart';

class IosAdsWidgetScreen extends StatefulWidget {
  final dynamic article;

  const IosAdsWidgetScreen({super.key, required this.article});

  @override
  State<IosAdsWidgetScreen> createState() => _IosAdsWidgetScreenState();
}

class _IosAdsWidgetScreenState extends State<IosAdsWidgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: widget.article['adType'] == "rating card"
              ? const RateYourApp()
              : const ShareYourApp(),
        ),
        Expanded(
          child: RecommendedNews(
            rList: widget.article['homepage'] ?? [],
          ),
        )
      ],
    );
  }
}
