import 'package:flutter/material.dart';
import '../recommended_news.dart';
import 'ios_ads_view.dart';

class AndroidAdsView extends StatelessWidget {
  final dynamic article;
  final int index;

  const AndroidAdsView({super.key, required this.article, required this.index});

  @override
  Widget build(BuildContext context) {
    return IosAdsWidgetScreen(article: article);
  }
}
