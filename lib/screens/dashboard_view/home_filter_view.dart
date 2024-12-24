
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../home_screen/home_provider.dart';

class HomeFilterView extends StatelessWidget {
  const HomeFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(builder: (_, homeProvider, __) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Container(
          decoration: BoxDecoration(
              color: AppColors.wColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Age"),
                    height(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: homeProvider.ageList.map((item) {
                        final isSelected =
                            homeProvider.selectAge == item.name;
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            item.name ?? "",
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.black, // Change text color
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (value) {
                            homeProvider.updateAge(item.name);
                          },
                          selectedColor: Colors.blue.withOpacity(0.2),
                          // Background when selected
                          backgroundColor: Colors.white,
                          // Background when not selected
                          side: BorderSide(
                            color: isSelected ? Colors.blue : Colors.grey,
                            // Border color change
                            width: 1.0,
                          ),
                        );
                      }).toList(),
                    ),
                    height(height: 16),
                    _buildSectionTitle("Engagement Score"),
                    height(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          homeProvider.engagementListForDropDown.map((item) {
                        final isSelected =
                            homeProvider.selectEngagement == item.name;
                        return ChoiceChip(
                          showCheckmark: false,
                          label: Text(
                            item.name ?? "",
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.blue
                                  : Colors.black, // Change text color
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (value) {
                            homeProvider.updateEngagement(item.name);
                          },
                          selectedColor: Colors.blue.withOpacity(0.2),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: 1.0,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Divider(
                color: AppColors.borderColor,
              ),
              homeProvider.isEngageTweetsLoading
                  ? const AppLoadingScreen()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () {
                                homeProvider.filterEnable();
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: AppColors.wColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(5)),
                                      border: Border.all(
                                          color: AppColors.appButtonColor)),
                                  child: Text(
                                    "Cancel",
                                    style: fontStyle(
                                        color: AppColors.appButtonColor,
                                        fontWeight: FontWeight.w700),
                                  )),
                            ),
                          ),
                          width(width: 20),
                          Expanded(
                            child: InkWell(
                              onTap: () async{
                              await  homeProvider.getEngageTweets(filter: true);
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.appButtonColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)),
                                  ),
                                  child: Text("Apply",
                                      style: fontStyle(
                                          color: AppColors.wColor,
                                          fontWeight: FontWeight.w700))),
                            ),
                          ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
