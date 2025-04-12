
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_view/papers_screen_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
    context.read<EPapersProvider>().getSingleEPapers(widget.paper);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<EPapersProvider>(
          builder: (_,ePapersProvider,__) {
            return Padding(
              padding: EdgeInsets.only(top: 0, left: 10, right: 10), // Adjusted for safe area
              child: ListView.builder(
                itemCount: ePapersProvider.getSinglePapersList.length,
                itemBuilder: (context, index) {
                  final article = ePapersProvider.getSinglePapersList[index];

                  return ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Container(
                      height: 300,
                      margin: EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
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

                          Positioned(
                            top: 1,
                            right: 14,
                            child: GestureDetector(
                              onTap: () {
                                context.read<SettingsProvider>().saveBookmarks(
                                  ePapersProvider.getSinglePapersList[index].id.toString(),
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
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              color: Colors.white,
                              // padding: EdgeInsets.only(left: 10, bottom: 13),
                              child: Row(
                                // mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                      height: 60,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.all(2),
                                      child: Image.network(
                                        ePapersProvider.getSinglePapersList[index].logo.toString(),
                                        height: 30,
                                        width: 30,
                                        fit: BoxFit.fill,
                                      )
                                  ),
                                  width(width: 6.h),
                                  Text(
                                    ePapersProvider.getSinglePapersList[index].source.toString(),
                                    style: newAppFont(
                                      color: Colors.grey.shade700,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Spacer(),
                                  Icon(
                                    Icons.ios_share,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  width(width: 15.w),
                                ],
                              ),
                            ),
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
