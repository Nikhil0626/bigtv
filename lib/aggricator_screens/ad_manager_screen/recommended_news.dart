import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../individual_post_details/individual_post_view.dart';
import '../../core/theme/theme_extensions.dart';

class RecommendedNews extends StatelessWidget {
  final List rList;
  //Nikhil
  const RecommendedNews({super.key, required this.rList});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Recommended News",
            style: fontStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.textColor)),
        height(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: rList.length > 3 ? 3 : rList.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final post = rList[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IndividualPostView1(
                        postId: post['id'].toString(),
                        isComeFrom: true,
                      ),
                    ),
                  );
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    border: Border.all(width: 2, color: context.cardColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: post['image_url'].toString(),
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 50,
                            width: 50,
                            color: context.borderColor.withAlpha(51), // 0.2 * 255 approx 51
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image,
                                size: 30, color: Colors.white),
                          ),
                        ),
                      ),
                      width(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post["title"] ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: fontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: context.textColor),
                            ),
                            height(height: 2),
                            Row(
                              children: [
                                index == 0
                                    ? SvgPicture.asset("assets/svg/like.svg",
                                        height: 16, width: 16)
                                    : index == 2
                                        ? SvgPicture.asset("assets/svg/share.svg",
                                            height: 16, width: 16)
                                        : SvgPicture.asset("assets/svg/eye.svg",
                                            height: 16, width: 16),
                                width(width: 6),
                                Text(
                                  index == 0
                                      ? "టాప్ లైక్స్"
                                      : index == 2
                                          ? "టాప్ షేర్‌డ్"
                                          : "టాప్ వ్యూడ్",
                                  style: fontStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: context.textColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
