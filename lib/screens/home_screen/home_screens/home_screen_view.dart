
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import 'artical_page.dart';
import '../../flip_page/district_flip_panel.dart';
import '../home_provider/provider.dart';
import '../../flip_page/home_flip_panel.dart';
import '../home_models/home_screen_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FlipProvider>().getArticles();
    final displayFeatures = MediaQuery.of(context).displayFeatures;
    bool isFoldable = displayFeatures.isNotEmpty;


    double heightsInt = (MediaQuery.of(context).size.height-MediaQuery.of(context).padding.vertical);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<FlipProvider>(
        builder: (_,flipProvider,__) {
          return FlipPanel<HomeScreenModel>(
            itemStream: flipProvider.mainArticles,
            // waitingForRefresh: flipProvider.isRefresh?true:false,
            itemBuilder: <HomeScreenModel>(context, article, flipBack, height) =>
                ArticlePage(article: article, flipBack: flipBack,height: heightsInt, ),
            height: heightsInt,
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
    final displayFeatures = MediaQuery.of(context).displayFeatures;
    bool isFoldable = displayFeatures.isNotEmpty;
    double heightsInt = (MediaQuery.of(context).size.height-MediaQuery.of(context).padding.vertical);


    return Scaffold(
          body: Consumer<FlipProvider>(
    builder: (_,flipProvider,__) {
      return DistrictFlipPanel<HomeScreenModel>(
        // waitingForRefresh: flipProvider.isRefresh?true:false,
        itemStream: flipProvider.districtArticles,
        itemBuilder: <HomeScreenModel>(context, article, flipBack, height) =>
            ArticlePage(article: article, flipBack: flipBack, height: heightsInt,),
        height: heightsInt,

      );
    }
          ),);
  }
}