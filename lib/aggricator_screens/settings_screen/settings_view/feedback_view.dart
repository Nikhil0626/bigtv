import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';

class FeedbackForm extends StatefulWidget {
  @override
  _FeedbackFormState createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  int selectedStar = 0;



  String get feedbackMessage {
    switch (selectedStar) {
      case 1:
        return "Poor experience";
      case 2:
        return "Not satisfied";
      case 3:
        return "Okay, Needs some improvemnet";
      case 4:
        return "Good, could be better";
      case 5:
        return "Amazing, love it";
      default:
        return "Rate us";
    }
  }

  @override
  void initState() {
    context.read<SettingsProvider>().feedbackList = [];
    context.read<SettingsProvider>().getFeedBack();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Feedback Form",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (_, settingsProvider, __) {
          return settingsProvider.isFeedbackLoading?AppLoadingScreen():SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Tell us what you think",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: AppColors.appButtonColor
                    ),
                    textAlign: TextAlign.center,
                  ),
                  height(height: 16),
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Card(
                      color: AppColors.cardBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Rate your experience with ChotaNews?",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(5, (index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedStar = index + 1;
                                    });
                                  },
                                  child: Icon(
                                    Icons.star,
                                    color: index < selectedStar
                                        ? AppColors.ratingColor
                                        : Colors.grey,
                                    size: 40,
                                  ),
                                );
                              }),
                            ),
                            SizedBox(height: 3),
                            Text(
                              feedbackMessage,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                  color: AppColors.appButtonColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                  color:     AppColors.cardBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "What should we improve?",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                            height(height: 8),
                            Wrap(
                              spacing: 10.w,
                              runSpacing: 10.w,
                              crossAxisAlignment: WrapCrossAlignment.start,
                              children: settingsProvider.feedbackList.map((category) {
                                final isSelected = settingsProvider.selectedFeedbackList
                                    .contains(category['optionText'].toString());

                                return GestureDetector(
                                  onTap: () {
                                    settingsProvider.addToSelectedEngagements(
                                        category['optionText'].toString());
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.appButtonColor
                                          : AppColors.cardBackgroundColor,
                                      borderRadius: BorderRadius.circular(15.r),
                                    ),
                                    child: Text(
                                      category['optionText'].toString(),
                                      textAlign: TextAlign.center,
                                      style: homeScreenFontStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                  if (settingsProvider.isOthersSelected)
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Please tell us more about it?",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8),
                              TextField(
                                controller: settingsProvider.feedbackController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  hintText: "Text",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 16),

                  InkWell(
                    onTap: (){
                      if(settingsProvider.selectedFeedbackList.isNotEmpty && selectedStar>0) {
                        settingsProvider.postFeedBack(selectedStar,).then((value) {
                          selectedStar = 0;setState(() {

                          });
                        },);
                      }else{
                        CustomToast.showErrorToast(msg: "Select at list one star and value field");
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 35.h,
                      // margin: EdgeInsets.only(bottom: 20.h),
                      decoration: BoxDecoration(
                        color: (settingsProvider.selectedFeedbackList.isNotEmpty && selectedStar>0)
                            ? AppColors.appButtonColor
                            : AppColors.bodyTextColor.withOpacity(.2),
                        borderRadius: BorderRadius.all(Radius.circular(8.r)),
                      ),
                      child: Center(
                        child: Text(
                          'Submit',
                          style: newAppFont(color: Colors.white, fontWeight: FontWeight.w500),
                        ),
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
}
