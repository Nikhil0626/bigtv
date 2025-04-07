import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../utils/date_format.dart';

class SavedArticles extends StatefulWidget {
  const SavedArticles({super.key});

  @override
  State<SavedArticles> createState() => _SavedArticlesState();
}

class _SavedArticlesState extends State<SavedArticles> {
  void initState() {
    context.read<FlipProvider>().getArticles();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
        ),
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 1),
          child: Text(
            "Bookmarks",
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Consumer<FlipProvider>(builder: (_, flipProvider, __) {
        return Padding(
          padding: EdgeInsets.all(18.0),
          child: ListView.builder(
              itemCount: flipProvider.mainArticlesData.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 140,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Container(
                        height: 136,
                        width: 311,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 120,
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(13),
                                        child: Image.network(
                                          flipProvider.mainArticlesData[index].imageUrl.url.toString(),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 3),
                                        child: Container(
                                          padding: EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.bookmark,
                                            color: Colors.lightBlue,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              width(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 6),
                                      child: InkWell(
                                        onTap: () {},
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            flipProvider.mainArticlesData[index].type.toString(),
                                            style: TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      flipProvider.mainArticlesData[index].title.toString(),
                                      // maxLines: 3,
                                      // overflow: TextOverflow.ellipsis,
                                      style: newAppFont(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                    height(height: 5),
                                    Row(
                                      children: [
                                        width(width: 7),
                                        Icon(Icons.circle, color: Colors.black, size: 8),
                                        width(width: 5),
                                        Text(
                                          " ${formatTimeDifference(flipProvider.mainArticlesData[index].created.toString())}",
                                          style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      height(height: 4),
                    ],
                  ),
                );
              }),
        );
      }),
    );
  }
}
