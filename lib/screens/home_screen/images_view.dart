// import 'package:chotanews/screens/home_screen/home_screen_model.dart';
// import 'package:flutter/material.dart';
// import 'package:introduction_screen/introduction_screen.dart';
//
// class CarouselScreen extends StatelessWidget {
//    List<GalleryImage>? imageList;
//
//    CarouselScreen({super.key, required this.imageList});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20.0),
//       child: IntroductionScreen(
//         globalBackgroundColor: Colors.white,
//         allowImplicitScrolling: true,
//         pages: imageList!.map((image) {
//           return PageViewModel(
//             title:  "", // Assuming `GalleryImage` has a `title` property
//             body:
//                 "",
//             image: _buildFullscreenImage(image.url),
//             decoration: const PageDecoration(
//               titlefontStyle: fontStyle(
//                 fontSize: 24.0,
//                 fontWeight: FontWeight.bold,
//               ),
//               bodyfontStyle: fontStyle(fontSize: 16.0),
//               contentMargin: EdgeInsets.symmetric(horizontal: 16),
//               fullScreen: true,
//               bodyFlex: 2,
//               imageFlex: 3,
//             ),
//           );
//         }).toList(),
//         onDone: () => _onIntroEnd(context),
//         onSkip: () => _onIntroEnd(context),
//         showSkipButton: false,
//         showBackButton: false,
//         showDoneButton: false,
//         showNextButton: false,
//         skip: const Text('Skip', style: fontStyle(fontWeight: FontWeight.w600)),
//         next: const Icon(Icons.arrow_forward),
//         done: const Text('Done', style: fontStyle(fontWeight: FontWeight.w600)),
//
//         dotsDecorator: const DotsDecorator(
//           size: Size(10.0, 10.0),
//           color: Color(0xFFBDBDBD),
//
//           activeSize: Size(22.0, 10.0),
//           activeShape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(25.0)),
//           ),
//         ),
//         dotsContainerDecorator: const ShapeDecoration(
//           color: Colors.black87,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8.0)),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFullscreenImage(String imageUrl) {
//     return Center(
//       child: Image.network(
//         imageUrl,
//         fit: BoxFit.cover,
//         width: double.infinity,
//         height: double.infinity,
//       ),
//     );
//   }
//
//   void _onIntroEnd(BuildContext context) {
//     Navigator.of(context).pop(); // Example action: Close the screen
//   }
// }


import 'package:flutter/material.dart';

import 'home_screen_model.dart';

class CarouselScreen extends StatelessWidget {
    List<GalleryImage> imageList =[];

  CarouselScreen({super.key, required this.imageList});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              return _buildImageCard(imageList[index]);
            },
          ),

          Align(
              alignment: Alignment.bottomCenter,
              child: _buildDotIndicator(imageList!.length)),
        ],
      ),
    );
  }

  Widget _buildImageCard(GalleryImage image) {
    return ClipRRect(
      child: Image.network(
        image.url,
        fit: BoxFit.fill,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  }

  Widget _buildDotIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            margin: const EdgeInsets.symmetric(vertical: 50.0),
            width: 12.0,
            height: 12.0,
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}

