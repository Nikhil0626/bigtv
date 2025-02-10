
import 'dart:io';

import 'package:chotanews/screens/flip_page/flipe_pannel.dart';
import 'package:flutter/material.dart';
import '../flip_page/artical_page.dart';
import '../flip_page/article_bloc_provider.dart';
import 'home_screen_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Calculate height of the page before applying the SafeArea since it removes
    // the padding from the MediaQuery and can not calculate it inside the page.
    double height = (MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom)-(Platform.isIOS?100:36);

    return Scaffold(
      body:  FlipPanel<HomeScreenModel>(waitingForRefresh: ArticleBlocProvider.of(context).isRefresh,
        itemStream: ArticleBlocProvider.of(context).articles,
        itemBuilder: <HomeScreenModel>(context, article, flipBack, height) => ArticlePage(article: article, flipBack: flipBack, height: height),
        getItemsCallback: ArticleBlocProvider.of(context).getArticles,
        height: height,
      ),



    );
  }
}


