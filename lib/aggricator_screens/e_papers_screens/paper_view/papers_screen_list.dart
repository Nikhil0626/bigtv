import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../../../screens/home_screen/home_provider/provider.dart';
import '../paper_provider/epapers_provider.dart';

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
                final article = ePapersProvider.getAllMainPapersList[index];

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
                            imageUrl: ePapersProvider.getAllMainPapersList[index].imageUrl,
                            width: MediaQuery.of(context).size.width,
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

                        // Bookmark Icon (Top Right)
                        Positioned(
                          top: 1,
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
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            color: Colors.white,
                            padding:  EdgeInsets.only(left: 10, bottom: 13, right: 10),
                            child: Row(
                              children: [
                                Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                  ),
                                  padding:  EdgeInsets.all(2),
                                  child: Image.network(
                                    "https://images.jdmagicbox.com/comp/vijayawada/01/0866p866std3000001/catalogue/andhra-jyothi-office-gannavaram-vijayawada-newspaper-publishers-e1n33mt0bc.jpg",
                                    height: 30,
                                    width: 30,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                width(width: 10.w),
                                Text(
                                  "AndhraJyoti",
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
        },
      ),
    );
  }
}
