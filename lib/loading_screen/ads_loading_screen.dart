import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../utils/app_colors.dart';

class AdsLoadingScreen extends StatefulWidget {
  const AdsLoadingScreen({super.key});

  @override
  State<AdsLoadingScreen> createState() => _AdsLoadingScreenState();
}

class _AdsLoadingScreenState extends State<AdsLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Shimmer.fromColors(
        baseColor:Colors.white ,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
           child: Container(color: AppColors.cardBackgroundColor,),
            ),
            Expanded(flex: 1,child:Column(
              children: [
                Container(color: Colors.white, width: MediaQuery.of(context).size.width),
                Expanded(
                  child: ListView.builder(
                    itemCount: 3,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(width: 2, color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(
                                      height: 14,
                                      width: double.infinity,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          height: 16,
                                          width: 16,
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          height: 12,
                                          width: 80,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            )),
          ],
        )
      ),
    );
  }
}


class BannerAdsLoadingScreen extends StatefulWidget {
  const BannerAdsLoadingScreen({super.key});

  @override
  State<BannerAdsLoadingScreen> createState() => _BannerAdsLoadingScreenState();
}

class _BannerAdsLoadingScreenState extends State<BannerAdsLoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return  Shimmer.fromColors(
        baseColor: AppColors.cardBackgroundColor,
        highlightColor: Colors.grey[100]!,
        child: Container(color: Colors.white,)
    );
  }
}

