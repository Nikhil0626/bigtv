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
      color: Colors.white,
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
          children: [
            Expanded(
              flex: 2,
                child: NewsCard(imageUrl:getHomeList![0].imageUrl!.url, title: getHomeList![0].title,)),
            Expanded(
             flex: 1,
              child: Row(
                children: [
                  Expanded(child: NewsCard(imageUrl:getHomeList![1].imageUrl!.url, title: getHomeList![1].title,)),
                  Expanded(child: NewsCard(imageUrl:getHomeList![2].imageUrl!.url, title: getHomeList![2].title,))
                ],
              ),
            )
          ],
        ),
    );
  }
}

class NewsCard extends StatelessWidget {
  final String imageUrl;
  final String title;

  NewsCard({required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Expanded(
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            imageBuilder: (context, imageProvider) =>
                Container(
                  height: 30,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 1,
                        color: Colors.black),
                    borderRadius: const BorderRadius.all(
                        Radius.circular(15)),
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            errorWidget: (context, url, error) => Container(
              height: 30,
              width: 30,
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
          bottom: 20,
          left: 0,
          right: 0,
          child: Text(
            title,
            style:  fontStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

      ],
    );
  }
}
