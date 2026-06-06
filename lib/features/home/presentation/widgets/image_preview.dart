import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class ImagePreview extends StatelessWidget {
  final String imageUrl;
  final String title;

  const ImagePreview({super.key, required this.imageUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: InkWell(
                   onTap: () {
                     Navigator.pop(context);
                   },
                  child: Icon(Icons.cancel_rounded,color: Colors.red,size: 24,)),
            ),
            Expanded(
              child: Center(
                child: Hero(
                  tag: imageUrl,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.white),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
              child: Text( title,style: homeScreenFontStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),),
            )
          ],

        ),
      ),
    );
  }
}