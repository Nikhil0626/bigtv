
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_spaces.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String screenName;

  const CommonAppbar({
    super.key,
    required this.screenName,
  });

  @override
  Widget build(BuildContext context) {
    return  Container(
        color: Colors.white,
        height: preferredSize.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            height(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
              child: Row(
                children: [
                  width(width: 10),
                  Text(
                    screenName,
                    textAlign: TextAlign.center,
                    style: fontStyle(
                      fontSize: 18,
                      color: const Color(0xff111928),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  width(width: 10),
                  const Spacer(),
                  if(screenName == "XTweet")
                    InkWell(
                        onTap: () {
                        },
                        child: SvgPicture.asset(
                          "assets/settings",
                          width: 20,
                          height: 20,
                        )),
                  if (screenName == "Viral Tweets")
                    InkWell(
                        onTap: () {
                        },
                        child: SvgPicture.asset(
                          "assets/settings",
                          width: 20,
                          height: 20,
                        )),
                  width(width: 10),

                ],
              ),
            ),
            height(height: 10),
            Divider(
              height: 1,
              color: AppColors.borderColor,
            )
          ],
        ),
      );

  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
