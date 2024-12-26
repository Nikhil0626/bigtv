import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_strings.dart';
import '../../utils/app_textformfield.dart';
import '../home_screen/home_provider.dart';

class NewsGenerateScreen extends StatefulWidget {
  final int tweetId;
  final String tweetText;
  final String screenType;

  const NewsGenerateScreen(
      {super.key,
      required this.tweetId,
      required this.tweetText,
      required this.screenType});

  @override
  State<NewsGenerateScreen> createState() => _NewsGenerateScreenState();
}

class _NewsGenerateScreenState extends State<NewsGenerateScreen> {
  @override
  void initState() {
    log(widget.tweetId.toString() ?? "");
    log(widget.tweetText.toString() ?? "");
    context.read<HomeProvider>().titleController.text == "";
    context.read<HomeProvider>().bodyController.text == "";
    context.read<HomeProvider>().selectedFile = null;
    context
        .read<HomeProvider>()
        .tweetGenerateByAi(widget.tweetText, widget.tweetId, context, "");
    context.read<HomeProvider>().reSetFilter();
    super.initState();
  }

  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Ai News",
            style: fontStyle(
                color: AppColors.headerTextColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
        ),
        body: Consumer<HomeProvider>(builder: (_, homeProvider, __) {
          return homeProvider.tweetGenerateLoading
              ? const AppLoadingScreen()
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  homeProvider.pickAndUploadFile(
                                      homeProvider.generateByAi['data_id']);
                                },
                                child: Container(
                                  height: 240,
                                  width: MediaQuery.of(context).size.width,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: homeProvider.selectedFile != null
                                      ? Image.file(
                                          homeProvider.selectedFile!,
                                          fit: BoxFit.cover,
                                          height: 240,
                                          width:
                                              MediaQuery.of(context).size.width,
                                        )
                                      : const Center(
                                          child: Icon(Icons.upload,
                                              size: 50, color: Colors.grey),
                                        ),
                                ),
                              ),
                            ),
                            height(height: 10),
                            homeProvider.isTitleGenLoading
                                ? const AppLoadingScreen()
                                : AppTextFormField1(
                                    prefixIcon: Icons.account_circle_outlined,
                                    textEditingController:
                                        homeProvider.titleController,
                                    isFormValid: false,
                                    label: '',
                                  ),
                            height(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Word Count | ${homeProvider.generateByAi['title'] != null ? homeProvider.generateByAi['title'].split(" ").length : 0} ",
                                  maxLines: 1,
                                  style: fontStyle(
                                      fontSize: 12,
                                      color: const Color(0xff6b7280),
                                      fontWeight: FontWeight.normal),
                                ),
                                width(width: 16),
                                InkWell(
                                    onTap: () {
                                      homeProvider.copyToClipboard(
                                          homeProvider.generateByAi['title']);
                                    },
                                    child: SvgPicture.asset(
                                      "assets/copy.svg",
                                      height: 20,
                                      width: 20,
                                      color: const Color(0xff6b7280),
                                    )),
                                width(width: 16),
                                InkWell(
                                    onTap: () {
                                      homeProvider.tweetReGenerateByAi(
                                          widget.tweetId,
                                          homeProvider.generateByAi['title'],
                                          "title");
                                    },
                                    child: SvgPicture.asset(
                                      "assets/re_load.svg",
                                      height: 20,
                                      width: 20,
                                      color: const Color(0xff6b7280),
                                    ))
                              ],
                            ),
                            height(height: 10),
                            AppTextFormField1(
                              textEditingController:
                                  homeProvider.bodyController,
                              isFormValid: false,
                              label: '',
                            ),
                            height(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "Word Count | ${homeProvider.generateByAi['text'] != null ? homeProvider.generateByAi['text'].split(" ").length : 0} ",
                                  maxLines: 1,
                                  style: fontStyle(
                                      fontSize: 12,
                                      color: const Color(0xff6b7280),
                                      fontWeight: FontWeight.normal),
                                ),
                                width(width: 16),
                                InkWell(
                                    onTap: () {
                                      homeProvider.copyToClipboard(
                                          homeProvider.generateByAi['text']);
                                    },
                                    child: SvgPicture.asset(
                                      "assets/copy.svg",
                                      height: 20,
                                      width: 20,
                                      color: const Color(0xff6b7280),
                                    )),
                                width(width: 16),
                                InkWell(
                                    onTap: () {
                                      homeProvider.tweetReGenerateByAi(
                                          widget.tweetId,
                                          homeProvider.generateByAi['text'],
                                          "body");
                                    },
                                    child: SvgPicture.asset(
                                      "assets/re_load.svg",
                                      height: 20,
                                      width: 20,
                                      color: const Color(0xff6b7280),
                                    ))
                              ],
                            ),
                            height(height: 15),
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xffD1D5DB),
                                  // Border color
                                  width: 1, // Border width
                                ),
                                borderRadius:
                                    BorderRadius.circular(8), // Rounded corners
                              ),
                              child: DropdownButton2(
                                hint: const Text('Select GPT'),
                                isExpanded: true,
                                value: homeProvider.selectGPT,
                                onChanged: (value) {
                                  homeProvider.updateGPT(value);
                                },
                                items:
                                    homeProvider.gptListForDropDown.map((item) {
                                  return DropdownMenuItem<String>(
                                    value: item.name.toString(),
                                    child: Text(
                                      item.name,
                                      style: fontStyle(
                                          color: const Color(0xff111928)),
                                    ),
                                  );
                                }).toList(),
                                underline: const SizedBox.shrink(),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    // Rounded corners for dropdown
                                    color: Colors.blueGrey[50],
                                    // Background color of the dropdown
                                    border: Border.all(
                                      color: Colors.black,
                                      // Border color for the dropdown menu
                                      width:
                                          1, // Border width for the dropdown menu
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            height(height: 15),
                            Consumer<HomeProvider>(
                                builder: (_, homeProvider, __) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xffD1D5DB),
                                          // Border color
                                          width: 1, // Border width
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            8), // Rounded corners
                                      ),
                                      child: DropdownButton2(
                                        hint: const Text('Select Tone'),
                                        isExpanded: true,
                                        value: homeProvider.toneId,
                                        onChanged: (value) {
                                          homeProvider.toneChange(value);
                                        },
                                        items: homeProvider.zonesModelList
                                            .map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item.toneName.toString(),
                                            child: Text(
                                              item.toneName,
                                              style: fontStyle(
                                                  color:
                                                      const Color(0xff111928)),
                                            ),
                                          );
                                        }).toList(),
                                        underline: const SizedBox.shrink(),
                                        dropdownStyleData: DropdownStyleData(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            // Rounded corners for dropdown
                                            color: Colors.blueGrey[50],
                                            // Background color of the dropdown
                                            border: Border.all(
                                              color: Colors.black,
                                              // Border color for the dropdown menu
                                              width:
                                                  1, // Border width for the dropdown menu
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  width(width: 10),
                                  Expanded(
                                    child: Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xffD1D5DB),
                                          // Border color
                                          width: 1, // Border width
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            8), // Rounded corners
                                      ),
                                      child: DropdownButton2(
                                        hint: const Text('Select Words'),
                                        isExpanded: true,
                                        value: homeProvider.numOfWords,
                                        onChanged: (value) {
                                          homeProvider.numOfWordsChange(value);
                                        },
                                        items:
                                            homeProvider.wordsList.map((item) {
                                          return DropdownMenuItem<String>(
                                            value: item.name.toString(),
                                            child: Text(
                                              "${item.name} Words",
                                              style: fontStyle(
                                                  color:
                                                      const Color(0xff111928)),
                                            ),
                                          );
                                        }).toList(),
                                        underline: const SizedBox.shrink(),
                                        dropdownStyleData: DropdownStyleData(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            // Rounded corners for dropdown
                                            color: Colors.blueGrey[50],
                                            // Background color of the dropdown
                                            border: Border.all(
                                              color: Colors.black,
                                              // Border color for the dropdown menu
                                              width:
                                                  1, // Border width for the dropdown menu
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                            height(height: 50),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: 15.0.sp,
                          ),
                          child: homeProvider.isEngageTweetsLoading || homeProvider.tweetGenerateLoading?AppLoadingScreen(): Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  context
                                      .read<HomeProvider>()
                                      .tweetGenerateByAi(
                                          widget.tweetText,
                                          widget.tweetId,
                                          context,
                                          "regenerate");
                                },
                                child: Container(
                                  width: 170.w,
                                  height: 40.h,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3.sp, horizontal: 10.sp),
                                  decoration: BoxDecoration(
                                      color: AppColors.wColor,
                                      border: Border.all(
                                          color: AppColors.appButtonColor,
                                          width: 1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.r))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/re_load.svg',
                                        height: 20,
                                        width: 20,
                                        color: AppColors.appButtonColor,
                                      ),
                                      Text(
                                        AppStrings.regenerate,
                                        style: fontStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.appButtonColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  // if (widget.screenType == "schedule") {
                                  //   homeProvider.publish(
                                  //     context,
                                  //     widget.tweetId.toString(),
                                  //   );
                                  // } else {
                                    homeProvider.publishTweet(
                                      context,
                                      widget.tweetId,
                                      homeProvider.generateByAi['title'],
                                      homeProvider.generateByAi['text'],
                                    );
                                  // }
                                },
                                child: Container(
                                  width: 170.w,
                                  height: 40.h,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 3.sp, horizontal: 10.sp),
                                  decoration: BoxDecoration(
                                      color: AppColors.appButtonColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.r))),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/upload.svg",
                                        width: 20,
                                        height: 20,
                                        color: Colors.white,
                                      ),
                                      Text(
                                       AppStrings.readyToPublish,
                                        style: fontStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
        }),
      ),
    );
  }
}
