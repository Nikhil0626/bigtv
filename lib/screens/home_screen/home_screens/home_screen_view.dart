
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


class HomeScreenView extends StatefulWidget {
  final String postId;
  const HomeScreenView({super.key, this.postId = ""});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
@override
  void initState() {
    // TODO: implement initState
    super.initState();

    if(widget.postId == ""){
      context.read<FlipProvider>().getArticles();

    }else{
      context.read<FlipProvider>().getIndividualPost(widget.postId);

    }
  }

  @override
  Widget build(BuildContext context) {


    double heightsInt = (MediaQuery.of(context).size.height-MediaQuery.of(context).padding.vertical);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<FlipProvider>(
        builder: (_,flipProvider,__) {
          return FlipPanel<HomeScreenModel>(
            itemStream: flipProvider.mainArticles,
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

    double heightsInt = (MediaQuery.of(context).size.height-MediaQuery.of(context).padding.vertical);


    return Scaffold(
          body: Consumer<FlipProvider>(
    builder: (_,flipProvider,__) {
      return DistrictFlipPanel<HomeScreenModel>(
        itemStream: flipProvider.districtArticles,
        itemBuilder: <HomeScreenModel>(context, article, flipBack, height) =>
            ArticlePage(article: article, flipBack: flipBack, height: heightsInt,),
        height: heightsInt,
      );
    }
          ),);
  }
}