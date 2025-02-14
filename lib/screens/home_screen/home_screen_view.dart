
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../flip_page/artical_page.dart';
import '../flip_page/flipe_pannel.dart';
import '../testing_screen/provider.dart';
import '../testing_screen/test2.dart';
import 'home_screen_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FlipProvider>().getArticles();
    double height = (MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom)-(Platform.isIOS?100:32);
    double width = (MediaQuery.of(context).size.width -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom)-(Platform.isIOS?100:36);
    return Scaffold(

      body: Consumer<FlipProvider>(
        builder: (_,flipProvider,__) {
          return FlipPanel<HomeScreenModel>(
            itemStream: flipProvider.mainArticles,
            waitingForRefresh: flipProvider.isRefresh?true:false,
            itemBuilder: <HomeScreenModel>(context, article, flipBack, height) =>
                ArticlePage(article: article, flipBack: flipBack, height: height,),
            height: height,
          );
        }
      ),
    );
  }
}




class HomePage1 extends StatelessWidget {
  const HomePage1({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FlipProvider>().getArticles();
    double height = (MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom)-(Platform.isIOS?100:36);

    return Consumer<FlipProvider>(
      builder: (_,flipProvider,__) {
        return DistrictFlipPanel<HomeScreenModel>(

          waitingForRefresh: flipProvider.isRefresh?true:false,
          itemStream: flipProvider.districtArticles,
          itemBuilder: <HomeScreenModel>(context, article, flipBack, height) =>
              ArticlePage(article: article, flipBack: flipBack, height: height,),
          height: height,

        );
      }
    );
  }
}