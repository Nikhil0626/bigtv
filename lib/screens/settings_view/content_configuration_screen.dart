
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/settings_view/setting_provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';

class ContentConfigurationScreen extends StatefulWidget {
  const ContentConfigurationScreen({super.key});

  @override
  State<ContentConfigurationScreen> createState() =>
      _ContentConfigurationScreenState();
}

class _ContentConfigurationScreenState
    extends State<ContentConfigurationScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<SettingProvider>(
          builder: (_,settingScreen,__) {
            return Form(
              key: settingScreen.formKey,
              child: Padding(
                padding: EdgeInsets.all(16.0.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Age *',
                      style: fontStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    height(height: 4),
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xffD1D5DB), // Border color
                          width: 1, // Border width
                        ),
                        borderRadius:
                        BorderRadius.circular(8), // Rounded corners
                      ),
                      child: DropdownButton2(
                        hint: Text(
                          'Select Age ',
                          style: fontStyle(fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                        isExpanded: true,
                        value: settingScreen.selectedTimePeriod,
                        onChanged: (value) {
                          settingScreen.ageUpdate(value);
                        },
                        items: context.read<SettingProvider>().timePeriodList.map(
                              (timePeriod) {
                            return DropdownMenuItem<String>(
                              value: timePeriod.name.toString(),
                              child: Text(
                                timePeriod.name,
                                style: fontStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
                              ), // Display the name
                            );
                          },
                        ).toList(),
                        underline: const SizedBox.shrink(),

                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueGrey[50],
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    height(height: 16),
                    Text(
                      'Engagement Score *',
                      style: fontStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    height(height: 4),
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xffD1D5DB), // Border color
                          width: 1, // Border width
                        ),
                        borderRadius:
                        BorderRadius.circular(8), // Rounded corners
                      ),
                      child: DropdownButton2(
                        isExpanded: true,
                        hint: Text(
                          'Select Engagement Score',
                          style: fontStyle(fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                        value: settingScreen.selectedEngagement,
                        items: context.read<SettingProvider>().engageList.map(
                              (timePeriod) {
                            return DropdownMenuItem<String>(
                              value: timePeriod.name.toString(),
                              child: Text(
                                timePeriod.name,
                                style: fontStyle(
                                    fontWeight: FontWeight.w400, fontSize: 14),
                              ), // Display the name
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          settingScreen.engagementUpdate(value);
                        },

                        underline: const SizedBox.shrink(),

                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueGrey[50],
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    height(height: 16),
                    Text(
                      'Words *',
                      style: fontStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    height(height: 4),
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xffD1D5DB), // Border color
                          width: 1, // Border width
                        ),
                        borderRadius:
                        BorderRadius.circular(8), // Rounded corners
                      ),
                      child: DropdownButton2(
                        isExpanded: true,
                        hint: Text(
                          'Select Words',
                          style: fontStyle(fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                        value: settingScreen.selectedWord,
                        items: context.read<SettingProvider>().wordsList.map(
                              (timePeriod) {
                            return DropdownMenuItem<String>(
                              value: timePeriod.name.toString(),
                              child: Text(timePeriod.name,
                                  style: fontStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14)), // Display the name
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          settingScreen.wordUpdate(value);
                        },

                        underline: const SizedBox.shrink(),

                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueGrey[50],
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    height(height: 16),
                    Text(
                      'Select Words Category',
                      style: fontStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    height(height: 4),
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xffD1D5DB), // Border color
                          width: 1, // Border width
                        ),
                        borderRadius:
                        BorderRadius.circular(8), // Rounded corners
                      ),
                      child: DropdownButton2(
                        isExpanded: true,
                        hint: Text(
                          'Select Tone Words',
                          style: fontStyle(fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                        value: settingScreen.selectedTone,
                        items: context.read<SettingProvider>().tonesList.map(
                              (timePeriod) {
                            return DropdownMenuItem<String>(
                              value: timePeriod.toneName.toString(),
                              child: Text(timePeriod.toneName,
                                  style: fontStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14)), // Display the name
                            );
                          },
                        ).toList(),

                        onChanged: (value) {
                          settingScreen.toneUpdate(value);
                        },
                        underline: const SizedBox.shrink(),

                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueGrey[50],
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    height(height: 16),
                    Text(
                      'Select AI Tool',
                      style: fontStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                    ),
                    height(height: 4),
                    Container(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xffD1D5DB), // Border color
                          width: 1, // Border width
                        ),
                        borderRadius:
                        BorderRadius.circular(8), // Rounded corners
                      ),
                      child: DropdownButton2(
                        isExpanded: true,
                        hint: Text(
                          'Select AI Tool',
                          style: fontStyle(fontWeight: FontWeight.w400, fontSize: 12),
                        ),
                        value: settingScreen.selectedAi,
                        items: context.read<SettingProvider>().aiList.map(
                              (aiItem) {
                            return DropdownMenuItem<String>(
                              value: aiItem.name.toString(),
                              child: Text(aiItem.name.toString(),
                                  style: fontStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14)), // Display the name
                            );
                          },
                        ).toList(),

                        onChanged: (value) {
                          settingScreen.aiUpdate(value);
                        },
                        underline: const SizedBox.shrink(),

                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.blueGrey[50],
                            border: Border.all(
                              color: Colors.black,
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                          Expanded(
                          child:settingScreen.addUserLoading?const AppLoadingScreen(): ElevatedButton.icon(
                            onPressed: () {
                              settingScreen.updateConfigData(context);
                            },
                            label: Text(
                              'SAVE',
                              style: fontStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.appButtonColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        ));
  }
}
