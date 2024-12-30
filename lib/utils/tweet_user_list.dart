import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/home_screen/home_provider.dart';
import 'package:tweetai/utils/app_colors.dart';

import '../screens/x_tweete_view/x_tweets_provider.dart';
import 'app_fonts.dart';
import 'app_spaces.dart';

class BottomTweetNames extends StatelessWidget {
  const BottomTweetNames({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.wColor,
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(color: AppColors.borderColor),
      ),
      width: MediaQuery.of(context).size.width - 50,
      child: Consumer<XTweetsProvider>(
        builder: (_, xTweetsProvider, __) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: xTweetsProvider.userNamesList.toSet().map((item) {
                    bool isSelected = xTweetsProvider.selectNamesList.contains(item);

                    return InkWell(
                      onTap: (){
                        xTweetsProvider.toggleSelection(item);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 15),
                        decoration: BoxDecoration(
                          color: AppColors.wColor,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          border: Border.all(color: isSelected?AppColors.appButtonColor:AppColors.borderColor),
                        ),
                        child: Text(
                          item ?? "",
                          style: TextStyle(
                            color: isSelected ? Colors.blue : Colors.black, // Change text color
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
height(height: 10),
Divider(color: AppColors.borderColor,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            context.read<HomeProvider>().filterEnable(screenName: "XTweet");
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
                            xTweetsProvider.filterNamesData().then((value){
                              context.read<HomeProvider>().filterEnable(screenName: "XTweet");
                            },);
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
          );
        },
      ),
    );
  }
}
