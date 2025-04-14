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
                                  color:  AppColors.cardBackgroundColor,
                                  height: 50.w,
                                  child: Row(
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: (){Navigator.push(context, MaterialPageRoute(
                                          builder: (context) => InAppWebViewScreen(
                                            webUrl: ePapersProvider.getAllMainPapersList[index].sourceUrl.toString(),
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
                                              ePapersProvider.getAllMainPapersList[index].logo.toString(),
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit.fill,
                                            )),
                                      ),
                                      width(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          ePapersProvider.getAllMainPapersList[index].source.toString(),
                                          style: newAppFont(
                                            color: Colors.grey.shade700,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      width(width: 16.w),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              top: 14,
                              right: 14,
                              child: GestureDetector(
                                onTap: () {
                                  context.read<SettingsProvider>().saveBookmarks(
                                    ePapersProvider.getAllMainPapersList[index].id.toString(),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.bookmark,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),

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
