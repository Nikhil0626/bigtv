import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class HomeScreenView extends StatelessWidget {
  final String tweetId;
  final String tweetTitle;
  final String tweetBody;
  final String tweetImage;
  final String pageType;

  const HomeScreenView(
      {super.key,
      required this.tweetId,
      required this.tweetTitle,
      required this.tweetBody,
      required this.pageType,
      required this.tweetImage});

  @override
  Widget build(BuildContext context) {
    log(tweetImage);

    String img = tweetImage.split(";").first.toString();
    log(img);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  tweetImage == "" ||
                          tweetImage == "No image" ||
                          tweetImage == "null"
                      ? Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 270,
                          child: Image.asset(
                            "assets/chota.png",
                            width: double.infinity,
                            height: 270,
                            fit: BoxFit.fill,
                          ),
                        )
                      : Image.network(
                          width: double.infinity,
                          height: 270,
                          fit: BoxFit.fill,
                          img,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              "assets/chota.png",
                              width: double.infinity,
                              height: 270,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 16),
                    child: Text(
                      tweetTitle,
                      style: const TextStyle(
                        color: AppColors.headerTextColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        tweetBody,
                        style: fontStyle(
                          color: AppColors.bodyTextColor,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  height(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {},
                              child: Container(
                                alignment: Alignment.center,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: AppColors.wColor,
                                    border: Border.all(
                                        color: AppColors.appButtonColor,
                                        width: 1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: Text(
                                  "Edit",
                                  style: fontStyle(
                                      fontSize: 14,
                                      color: AppColors.appButtonColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          width(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () {},
                              child: Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color: AppColors.appButtonColor,
                                    border: Border.all(
                                        color: AppColors.appButtonColor,
                                        width: 1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(20))),
                                child: Center(
                                  child: Text(
                                    pageType == "schedule"
                                        ? "Publish"
                                        : "Schedule",
                                    style: fontStyle(
                                        fontSize: 14,
                                        color: AppColors.wColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  height(height: 10),
                ],
              ),
              SizedBox(
                height: 100,
                width: 100,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: CircleAvatar(
                        backgroundColor: AppColors.appButtonColor,
                        child: Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
