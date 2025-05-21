import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/papers_screen_preview.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../in_app_web_view.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../paper_provider/epapers_provider.dart';

class IndividualPaper extends StatefulWidget {
  final String paper;

  const IndividualPaper({super.key, required this.paper});

  @override
  State<IndividualPaper> createState() => _IndividualPaperState();
}

class _IndividualPaperState extends State<IndividualPaper> {
  @override
  void initState() {
    context.read<EPapersProvider>().getSinglePapersList = [];
    // context.read<EPapersProvider>().getSingleEPapers(widget.paper);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<EPapersProvider>(builder: (_, ePapersProvider, __) {
        return Padding(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, right: 10), // Adjusted for safe area
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    width(width: 20),
                    Icon(
                      Icons.arrow_back_outlined,
                      size: 24,
                    ),
                    width(width: 20),
                    Text(
                      widget.paper,
                      style: newAppFont(fontSize: 16, fontWeight: FontWeight.w600),
                    )
                  ],
                ),
              ),
              Expanded(
                child: ePapersProvider.isMainPapers
                    ? AppLoadingScreen()
                    : ListView.builder(
                        itemCount: ePapersProvider.getSinglePapersList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PapersScreenPreview(
                                      isBookmarked: ePapersProvider.getSinglePapersList[index].data!.first.isBookmarked==0?0:1 ,
                                      imageUrls: ePapersProvider.getSinglePapersList[index].data!,
                                      postId: ePapersProvider.getSinglePapersList[index].id.toString(),
                                    ),
                                  ));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(20)),
                                child: Container(
                                  color: AppColors.ePaperCardColor,
                                  height: 350.h,
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(12.sp)),
                                              child: CachedNetworkImage(
                                                imageUrl: ePapersProvider.getSinglePapersList[index].imageUrl.toString(),
                                                width: MediaQuery.of(context).size.width,
                                                height: 300,
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) => Container(
                                                  color: AppColors.borderColor.withOpacity(.2),
                                                ),
                                                errorWidget: (context, url, error) => Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 100,
                                                    color: Colors.grey.shade300,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            color: AppColors.cardBackgroundColor,
                                            height: 50.w,
                                            child: Row(
                                              // mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => InAppWebViewScreen(
                                                            webUrl: ePapersProvider.getSinglePapersList[index].sourceUrl.toString(),
                                                            title: "Advertise with us",
                                                          ),
                                                        ));
                                                  },
                                                  child: Container(
                                                      height: 60.w,
                                                      width: 60.w,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                        color: AppColors.cardBackgroundColor,
                                                      ),
                                                      padding: const EdgeInsets.all(2),
                                                      child: Image.network(
                                                        ePapersProvider.getSinglePapersList[index].logo.toString(),
                                                        height: 30,
                                                        width: 30,
                                                        fit: BoxFit.fill,
                                                      )),
                                                ),
                                                width(width: 6.h),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      ePapersProvider.getSinglePapersList[index].source.toString()??"",
                                                      style: newAppFont(
                                                        color: Colors.grey.shade800,
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                    // height(height: 1.h),
                                                    Text(
                                                      ePapersProvider.getSinglePapersList[index].editionName.toString()??"",
                                                      style: newAppFont(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w400,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                width(width: 16.w),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Positioned(
                                      //   top: 14,
                                      //   right: 14,
                                      //   child: Consumer<EPapersProvider>(builder: (_, ePapersProvider, __) {
                                      //     return GestureDetector(
                                      //       onTap: () {
                                      //         ePapersProvider.isBookMarkPost(ePapersProvider.getSinglePapersList[index], context);
                                      //       },
                                      //       child: Container(
                                      //         padding: EdgeInsets.all(7),
                                      //         decoration: BoxDecoration(
                                      //           color: (ePapersProvider.isBookMark.contains(ePapersProvider.getSinglePapersList[index].id.toString()) ||
                                      //                   ePapersProvider.getSinglePapersList[index].data!.first.isBookmarked == 1)
                                      //               ? AppColors.appButtonColor
                                      //               : Colors.black54,
                                      //           shape: BoxShape.circle,
                                      //         ),
                                      //         child: Icon(
                                      //           (ePapersProvider.isBookMark.contains(ePapersProvider.getSinglePapersList[index].id.toString()) ||
                                      //                   ePapersProvider.getSinglePapersList[index].data!.first.isBookmarked  == 1)
                                      //               ? Icons.bookmark
                                      //               : Icons.bookmark_outline,
                                      //           color: Colors.white,
                                      //           size: 20,
                                      //         ),
                                      //       ),
                                      //     );
                                      //   }),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
