import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:chotanews/features/home/presentation/widgets/image_preview.dart';

class ImagePostSlider extends StatelessWidget {
  final List<dynamic> imageUrl;
  final bool autoPlay;
  const ImagePostSlider({super.key, required this.imageUrl, this.autoPlay = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CarouselSlider.builder(
          itemCount: imageUrl.length,
          options: CarouselOptions(
            autoPlay: autoPlay,
            aspectRatio: 1.0,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            autoPlayInterval: const Duration(seconds: 3),
            autoPlayAnimationDuration: const Duration(milliseconds: 1000),
          ),
          itemBuilder: (context, index, realIndex) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagePreview(
                      imageUrl: imageUrl[index]['Url'].toString(),
                      title: "",
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl[index]['Url'].toString(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  ),
                  errorWidget: (context, url, error) => Image.asset(
                    'assets/images/bigtv_default_post.png',
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
