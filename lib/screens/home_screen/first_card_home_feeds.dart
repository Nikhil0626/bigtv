import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';

import '../../utils/app_loading_screen.dart';

class FirstCardHomeFeeds extends StatelessWidget {

 final List<Article>? getHomeList;
  const FirstCardHomeFeeds({super.key,required this.getHomeList});

  @override
  Widget build(BuildContext context) {
    return     Container(
      padding: const EdgeInsets.all(4),
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
          children: [
            Expanded(
              flex: 2,
                child: NewsCard(imageUrl:getHomeList![0].imageUrl!.url, title: getHomeList![0].title,isMainCard:true)),
            const Divider(height: 4,color: Colors.white,),
            Expanded(
             flex: 1,
              child: Row(
                children: [
                  Expanded(child: NewsCard(imageUrl:getHomeList![1].imageUrl!.url, title: getHomeList![1].title,isMainCard:false)),
                  Container(color: Colors.white,width: 4,),
                  Expanded(child: NewsCard(imageUrl:getHomeList![2].imageUrl!.url, title: getHomeList![2].title,isMainCard:false))
                ],
              ),
            ),
            const Divider(height:4,color: Colors.white,),
          ],
        ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final bool isMainCard;

  NewsCard({required this.imageUrl, required this.title, required this.isMainCard});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Expanded(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) =>
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            errorWidget: (context, url, error) => Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                      Radius.circular(32)),
                  border: Border.all(
                      width: 1,
                      color:  Colors.black)),
              child: Center(
                child: Text(
                  "H",
                  style: fontStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 8,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Container(
              decoration:  BoxDecoration(
                  color: Colors.white.withOpacity(.5),

                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              padding: const EdgeInsets.symmetric(horizontal:14.0,vertical: 8),
              child: Text(
                title,
                style:  fontStyle(
                  fontSize: isMainCard?20:14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),

      ],
    );
  }
}
