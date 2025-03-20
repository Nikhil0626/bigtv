// import 'package:appinio_swiper/appinio_swiper.dart';
// import 'package:chotanews/screens/testing_screen/test_bloc.dart';
// import 'package:chotanews/screens/testing_screen/test_event.dart';
// import 'package:chotanews/screens/testing_screen/test_state.dart';
// import 'package:chotanews/utils/app_fonts.dart';
// import 'package:chotanews/utils/app_spaces.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// class NewsScreen1 extends StatefulWidget {
//   final String url;
//   const NewsScreen1({super.key,required this.url });
//
//
//
//   @override
//   _NewsScreen1State createState() => _NewsScreen1State();
// }
//
// class _NewsScreen1State extends State<NewsScreen1> {
//   final AppinioSwiperController controller = AppinioSwiperController();
//   int indexUP = 0;
//
//   @override
//   void initState() {
//     context.read<TestBloc>().add(TestEventOne());
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: BlocBuilder<TestBloc, TestState>(
//         builder: (context, state) {
//           if (state is InitialState) {
//             return Container(
//               color: Colors.grey,
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child: const Center(
//                 child: CircularProgressIndicator(),
//               ),
//             );
//           } else if (state is Success) {
//             return CupertinoPageScaffold(
//               child: AppinioSwiper(
//                 invertAngleOnBottomDrag: true,
//                 backgroundCardCount: 3,
//                 swipeOptions: SwipeOptions.only(
//                   up: indexUP == 20 ? false : true,
//                   down: true,
//                 ),
//                 controller: controller,
//                 onCardPositionChanged: (SwiperPosition position) {},
//                 onSwipeEnd: (previousIndex, targetIndex, activity) {
//                   swipeEnd(previousIndex, targetIndex, activity,
//                       state.newPosts.length);
//                 },
//                 onEnd: onEnd(state.newPosts.last),
//                 allowUnSwipe: false,
//                 loop: false,
//                 cardCount: state.newPosts.length,
//                 cardBuilder: (context, index) {
//                   if (index == 0 || index == state.newPosts.length - 1) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[200],
//                       ),
//                       child: Center(
//                         child: Text(
//                           state.newPosts[index].title ?? 'No Title',
//                           style: fontStyle(
//                               fontSize: 24, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                     );
//                   } else {
//                     return Container(
//                       decoration: const BoxDecoration(
//                         color: Colors.white,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           state.newPosts[index].imageUrl?.url.toString() != null
//                               ? Image.network(
//                                   state.newPosts[index].imageUrl!.url
//                                       .toString(),
//                                   fit: BoxFit.cover,
//                                   width: MediaQuery.of(context).size.width,
//                                   height:
//                                       MediaQuery.of(context).size.height / 2,
//                                 )
//                               : SizedBox.shrink(),
//                           Padding(
//                             padding: EdgeInsets.all(16.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   state.newPosts[index].title ?? "No Title",
//                                   style: fontStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black,
//                                   ),
//                                 ),
//                                 height(height: 16),
//                                 Text(
//                                   state.newPosts[index].content ??
//                                       "No Description",
//                                   style: fontStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[800],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }
//                 },
//               ),
//             );
//           } else {
//             return Container(
//               color: Colors.grey,
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child:  Center(
//                 child: Text(
//                   "Something went wrong. Please try again.",
//                   style: fontStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   void swipeEnd(int previousIndex, int targetIndex, SwiperActivity activity,
//       int totalPosts) {
//     if (targetIndex == 0 || targetIndex == totalPosts - 1) {
//       // Prevent swipe if it's the first or last card
//       print('Cannot swipe the first or last card.');
//       return;
//     }
//     switch (activity) {
//       case Swipe():
//         indexUP = targetIndex;
//         setState(() {});
//         print('The card was swiped to the : ${indexUP}');
//         print('previous index1: $previousIndex, target index1: $targetIndex');
//         break;
//       case Unswipe():
//         print('A ${activity.direction.name} swipe was undone.');
//         print('previous index: $previousIndex, target index: $targetIndex');
//         break;
//       case CancelSwipe():
//         print('A swipe was cancelled');
//         break;
//       case DrivenActivity():
//         print('Driven Activity');
//         break;
//     }
//   }
//
//   onEnd(data) {
//     print('end reached! $data');
//   }
// }
//
// class AnimatedNewsPage extends StatelessWidget {
//   final String title;
//   final String description;
//   final String? imageUrl;
//   final int index;
//   final PageController controller;
//
//   AnimatedNewsPage({
//     required this.title,
//     required this.description,
//     this.imageUrl,
//     required this.index,
//     required this.controller,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: controller,
//       builder: (context, child) {
//         double value = 1.0;
//         if (controller.position.haveDimensions) {
//           value = controller.page! - index;
//           value = (1 - value.abs()).clamp(0.0, 1.0);
//         }
//
//         return Transform.scale(
//           scale: value,
//           child: Opacity(
//             opacity: value,
//             child: Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   imageUrl != null
//                       ? Image.network(
//                           imageUrl!,
//                           fit: BoxFit.cover,
//                           width: MediaQuery.of(context).size.width,
//                           height: MediaQuery.of(context).size.height / 2,
//                         )
//                       : SizedBox.shrink(),
//                   Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style:fontStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black,
//                           ),
//                         ),
//                         height(height: 16),
//                         Text(
//                           description,
//                           style: fontStyle(
//                             fontSize: 16,
//                             color: Colors.grey[800],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }


