

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../home_screen/home_provider/home_provider.dart';

class AreLikeApp extends StatefulWidget {
  const AreLikeApp({super.key});

  @override
  State<AreLikeApp> createState() => _AreLikeAppState();
}

class _AreLikeAppState extends State<AreLikeApp> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
        builder: (_,homeProvider,__) {
          return ClipRRect(
            child: Card(
              color: AppColors.adsBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                height: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        'Are liking our app?',
                        textAlign: TextAlign.center,
                        style: newAppFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Expanded(
                        child: ListView.builder(
                          itemCount: homeProvider.getAllSurveyDataList.length,
                          itemBuilder: (context, index) {
                            return Container(height: 30,
                                decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(5)), border: Border.all(width: 1, color: AppColors.borderColor)),
                                child: Text(
                                    'Are liking our app?',
                                    textAlign: TextAlign.center,
                                    style: newAppFont(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    )));
                          },))
                  ],
                ),
              ),
            ),
          );
        }
    );
  }
}