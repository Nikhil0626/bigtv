import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';

import 'app_colors.dart';

class ImagePostSlider extends StatelessWidget {
  final imageUrl;
  const ImagePostSlider({super.key,required this.imageUrl});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height: 750,
          child: CarouselSlider.builder(
            unlimitedMode: true,
            autoSliderTransitionTime: const Duration(milliseconds: 1000),
            autoSliderDelay: const Duration(seconds: 3),
            enableAutoSlider: true,
            slideBuilder: (index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl[index],
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.fill,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                )
              );
            },
            slideTransform: const CubeTransform(),
            slideIndicator: CircularSlideIndicator(
              padding: const EdgeInsets.only(bottom: 32),
              indicatorBackgroundColor: Colors.grey,
              currentIndicatorColor: Colors.blue,
            ),
            itemCount: imageUrl.length,
          ),
        ),
      ),
    );
  }
}
 