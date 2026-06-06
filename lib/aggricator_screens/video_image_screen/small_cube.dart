import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';

class SmallCube extends StatefulWidget {
  const SmallCube({super.key});

  @override
  SmallCubeState createState() => SmallCubeState();
}

class SmallCubeState extends State<SmallCube> {
  final List<Color> colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  final List<String> images = [
    "https://newspaperads.ads2publish.com/wp-content/uploads/2018/11/big-c-simple-easy-fast-ad-hyderabad-times-06-11-2018-250x399.png",
    "https://audiencereports.in/wp-content/uploads/2023/10/bigc-mobiles-unveiling-dussehra-dhamaka.jpg",
    "https://content3.jdmagicbox.com/comp/warangal/p9/9999px870.x870.140626143219.x4p9/catalogue/big-c-mobile-showroom-hanamkonda-warangal-mobile-phone-dealers-ajceri3xew.jpg",
    "https://i.ytimg.com/vi/TETMrzJcX8A/sddefault.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTBMVkHEEMycyrlN6vNq60y6U5wbD_sdRYqkM9XNP5iRbbouONKRTlnyPv4TmP77-y6Ws&usqp=CAU",
  ];

  final GlobalKey _sliderKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CarouselSlider.builder(
        key: _sliderKey,
        unlimitedMode: true,
        enableAutoSlider: true,
        autoSliderDelay: Duration(seconds: 3),
        autoSliderTransitionTime: Duration(milliseconds: 800),
        slideTransform: CubeTransform(),

        itemCount: images.length,
        slideBuilder: (index) {
          return Container(
            color: colors[index % colors.length],
            child: Image.network(
              images[index],
              fit: BoxFit.fill,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) =>
                  Icon(Icons.broken_image, size: 50),
            ),
          );
        },
      ),
    );
  }
}
