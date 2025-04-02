import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../e_papers_screens/paper_provider/epapers_provider.dart';
import '../../e_papers_screens/paper_view/individual_paper.dart';

class ReelsScreenList extends StatefulWidget {
  const ReelsScreenList({super.key});

  @override
  State<ReelsScreenList> createState() => _ReelsScreenListState();
}

class _ReelsScreenListState extends State<ReelsScreenList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<EPapersProvider>(
          builder: (_,ePapersProvider,__) {
            return Padding(
              padding: EdgeInsets.only(top: 0, left: 10, right: 10), // Adjusted for safe area
              child: GridView.builder(
                itemCount: ePapersProvider.getAllMainPapersList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IndividualPaper(paper: ePapersProvider.getAllMainPapersList[index].source,),
                          ));
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      child: Stack(
                        children: [

                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(12.r)),
                            child: CachedNetworkImage(
                              imageUrl: ePapersProvider.getAllMainPapersList[index].imageUrl,
                              fit: BoxFit.fill,
                              width: double.infinity,
                              placeholder: (context, url) => Center(child: CircularProgressIndicator()), // Loading indicator
                              errorWidget: (context, url, error) => Icon(Icons.error, color: Colors.red), // Error fallback
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackgroundColor,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12.r),
                                  bottomRight: Radius.circular(12.r),
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min, // Ensures the container fits its content
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ePapersProvider.getAllMainPapersList[index].editionName,
                                    style: fontStyle(fontWeight: FontWeight.w600, color: AppColors.textColor,fontSize: 12.sp),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4), // Adding space
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        ePapersProvider.getAllMainPapersList[index].source,
                                        style: TextStyle(fontSize: 12, color:AppColors.textColor,),
                                      ),
                                      Icon(Icons.more_vert, color: AppColors.textColor,),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                                height: 24.w,
                                width: 24.w,
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(.8),
                                    borderRadius: BorderRadius.all(Radius.circular(12.r))),
                                child: Icon(Icons.bookmark_border, color: Colors.white,size: 20.sp,)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }
      ),
    );
  }
}
