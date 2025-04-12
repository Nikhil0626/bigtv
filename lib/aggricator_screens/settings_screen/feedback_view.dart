import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';

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
      appBar: AppBar(
        title: Text(
          "Feedback Form",
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (_, settingsProvider, __) {
          return SingleChildScrollView(
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
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: Card(
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
                                        ? Colors.yellow
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
                                color: Colors.blue,
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
                            SizedBox(height: 8),
                            Wrap(
                              spacing: 10.w,
                              runSpacing: 10.w,
                              children: settingsProvider.feedbackList.map((category) {
                                final isSelected = settingsProvider.selectedFeedbackList
                                    .contains(category['optionText'].toString());

                                return GestureDetector(
                                  onTap: () {
                                    settingsProvider.addToSelectedEngagements(
                                        category['optionText'].toString());

                                  },
                                  child: Container(
                                    // height: 40,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 14.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.appButtonColor
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Text(
                                      category['optionText'].toString(),
                                      textAlign: TextAlign.center,
                                      style: homeScreenFontStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black87,
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
                  SizedBox(
                    width: 183,
                    height: 59,
                    child: ElevatedButton(
                      onPressed: () {
                       settingsProvider.postFeedBack(selectedStar, );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        "Submit",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white,
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
