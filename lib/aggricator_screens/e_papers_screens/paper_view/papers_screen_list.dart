import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/papers_screen_preview.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../screens/home_screen/home_screens/in_app_web_view.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../../../screens/home_screen/home_provider/provider.dart';
import '../paper_provider/epapers_provider.dart';
import 'individual_paper.dart';

class PapersScreenList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<EPapersProvider>(
        builder: (_, ePapersProvider, __) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ListView.builder(
              itemCount: ePapersProvider.getAllMainPapersList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => IndividualPaper(paper:ePapersProvider.getAllMainPapersList[index].source  ,),));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      child: Container(
                        color: AppColors.cardBackgroundColor,
                        height: 350.h,
                        child: Stack(
                          children: [
                            Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(12.sp)),
                                    child: CachedNetworkImage(
                                      imageUrl: ePapersProvider.getAllMainPapersList[index].imageUrl.toString(),
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
                                  padding: EdgeInsets.only(bottom: 6.h,top: 6.h),
                                  decoration: BoxDecoration( color: AppColors.cardBackgroundColor,
                                    borderRadius: BorderRadius.circular(12),),
                                  child: Row(
                                    children: [
                                      width(width: 10),
                                      InkWell(
                                        onTap: (){Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => InAppWebViewScreen(
                                            webUrl: ePapersProvider.getAllMainPapersList[index].sourceUrl.toString(),
                                            title: "E-Paper",
                                          ),
                                        ));
                                        },
                                        child: SizedBox(
                                            height: 50,
                                            width: 50,

                                            // padding: const EdgeInsets.all(2),
                                            child: CachedNetworkImage(
                                              imageUrl:  ePapersProvider.getAllMainPapersList[index].logo.toString(),
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
                                      width(width: 6.h),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ePapersProvider.getAllMainPapersList[index].source,
                                            style: newAppFont(
                                              color: Colors.grey.shade800,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          // height(height: 1.h),
                                          Text(
                                            ePapersProvider.getAllMainPapersList[index].editionName,
                                            style: newAppFont(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      width(width: 15.w),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Positioned(
                            //   top: 14,
                            //   right: 14,
                            //   child: Consumer<EPapersProvider>(
                            //       builder: (_,ePapersProvider,__) {
                            //         return GestureDetector(
                            //           onTap: () {
                            //             ePapersProvider.isBookMarkPost(   ePapersProvider.getAllMainPapersList[index],context);
                            //
                            //           },
                            //           child:Container(
                            //             padding: EdgeInsets.all(7),
                            //             decoration: BoxDecoration(
                            //               color: (ePapersProvider.isBookMark.contains(ePapersProvider.getAllMainPapersList[index].id.toString()) || ePapersProvider.getAllMainPapersList[index].isBookmarked== 1)
                            //                   ? AppColors.appButtonColor
                            //                   : Colors.black54,
                            //               shape: BoxShape.circle,
                            //             ),
                            //             child: Icon(
                            //               (ePapersProvider.isBookMark.contains(ePapersProvider.getAllMainPapersList[index].id.toString()) || ePapersProvider.getAllMainPapersList[index].isBookmarked == 1)
                            //                   ? Icons.bookmark
                            //                   : Icons.bookmark_outline,
                            //               color: Colors.white,
                            //               size: 20,
                            //             ),
                            //           ),
                            //         );
                            //       }
                            //   ),
                            // ),

                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
