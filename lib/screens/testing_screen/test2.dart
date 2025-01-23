// import 'dart:developer';
// import 'dart:math';
// import 'package:appinio_swiper/appinio_swiper.dart';
// import 'package:chotanews/screens/testing_screen/test1.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class Example extends StatefulWidget {
//   const Example({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<Example> createState() => _ExamplePageState();
// }
//
// class _ExamplePageState extends State<Example> {
//   final AppinioSwiperController controller = AppinioSwiperController();
//
//   @override
//   void initState() {
//     Future.delayed(const Duration(seconds: 1)).then((_) {
//       _shakeCard();
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: CupertinoPageScaffold(
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height,
//           child: AppinioSwiper(
//             invertAngleOnBottomDrag: false,
//             backgroundCardCount: 3,
//             swipeOptions:
//                 const SwipeOptions.symmetric(horizontal: false, vertical: true),
//             controller: controller,
//             onCardPositionChanged: (
//               SwiperPosition position,
//             ) {},
//             onSwipeEnd: _swipeEnd,
//             onEnd: _onEnd,
//             cardCount: 10,
//             cardBuilder: (BuildContext context, int index) {
//               return AnimatedNewsPage(
//                 title: state.newPosts[index].title ?? "No Title",
//                 description: state.newPosts[index].content ?? "No Description",
//                 imageUrl: state.newPosts[index].imageUrl?.url.toString(),
//                 index: index,
//                 controller: _pageController,
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   // Animates the card back and forth to teach the user that it is swipable.
//   Future<void> _shakeCard() async {
//     const double distance = 30;
//     // We can animate back and forth by chaining different animations.
//     await controller.animateTo(
//       const Offset(-distance, 0),
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeInOut,
//     );
//     await controller.animateTo(
//       const Offset(distance, 0),
//       duration: const Duration(milliseconds: 400),
//       curve: Curves.easeInOut,
//     );
//     // We need to animate back to the center because `animateTo` does not center
//     // the card for us.
//     await controller.animateTo(
//       const Offset(0, 0),
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeInOut,
//     );
//   }
// }
//
// Color getRandomColor() {
//   Random random = Random();
//   return Color.fromRGBO(
//     random.nextInt(256), // Random Red value between 0-255
//     random.nextInt(256), // Random Green value between 0-255
//     random.nextInt(256), // Random Blue value between 0-255
//     1, // Opacity (1 means fully opaque)
//   );
// }
// void swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity) {
//   switch (activity) {
//     case Swipe():
//       print('The card was swiped to the : ${activity.direction}');
//       print('previous index: $previousIndex, target index: $targetIndex');
//       break;
//     case Unswipe():
//       print('A ${activity.direction.name} swipe was undone.');
//       print('previous index: $previousIndex, target index: $targetIndex');
//       break;
//     case CancelSwipe():
//       print('A swipe was cancelled');
//       break;
//     case DrivenActivity():
//       print('Driven Activity');
//       break;
//   }
// }
//
// void onEnd() {
//   print('end reached!');
// }