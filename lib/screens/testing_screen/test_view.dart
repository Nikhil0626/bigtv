import 'dart:async';
import 'dart:developer';

import 'package:chotanews/screens/home_animation_widgets/collapse_widget_screen.dart';
import 'package:chotanews/screens/testing_screen/test_bloc.dart';
import 'package:chotanews/screens/testing_screen/test_event.dart';
import 'package:chotanews/screens/testing_screen/test_state.dart';
import 'package:flip_board/flip_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final _streamController = StreamController.broadcast();
  int _currentIndex = 0;
  AxisDirection _flipDirection = AxisDirection.down;
  bool _isFlipping = false; // Flag to track if a flip is in progress

  @override
  void initState() {
    super.initState();
    _streamController.add(_currentIndex);
    context.read<TestBloc>().add(TestEventOne());
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentIndex < 15 - 1 && !_isFlipping) {
      setState(() {
        _isFlipping = true; // Lock flipping
        _currentIndex++;
        _flipDirection = AxisDirection.down; // Flip downward
        _streamController.add(_currentIndex);
      });
      await Future.delayed(
          const Duration(seconds: 1)); // Shortened delay
      setState(() {
        _isFlipping = false; // Unlock flipping
      });
    }
  }

  void _previousPage() async {
    if (_currentIndex > 0 && !_isFlipping) {
      setState(() {
        _isFlipping = true; // Lock flipping
        _currentIndex--;
        _flipDirection = AxisDirection.up; // Flip upward
        _streamController.add(_currentIndex);
      });
      await Future.delayed(
          const Duration(seconds: 1)); // Shortened delay
      setState(() {
        _isFlipping = false; // Unlock flipping
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<TestBloc, TestState>(
        builder: (context, state) {
          if (state is InitialState) {
            return Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is Success) {
            return ListView.builder(
              itemCount: state.newPosts.length,
              itemBuilder: (context, index) {
                final post = state.newPosts[index];
                return GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (!_isFlipping) {
                      if (details.primaryDelta! < 0) {
                        _previousPage(); // Swiping up
                      } else if (details.primaryDelta! > 0) {
                        _nextPage(); // Swiping down
                      }
                    }
                  },
                  onVerticalDragEnd: (details) {
                    if (!_isFlipping) {
                      if (details.velocity.pixelsPerSecond.dy > 0) {
                        _nextPage();
                      } else if (details.velocity.pixelsPerSecond.dy < 0) {
                        _previousPage();
                      }
                    }
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: FlipWidget(
                      initialValue: _currentIndex,
                      flipType: FlipType.middleFlip,
                      itemStream: _streamController.stream,
                      flipDuration: Duration(seconds: 2),
                      itemBuilder: (_, index) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                post.imageUrl?.url ?? "",
                                width: double.infinity,
                                height: 350,
                                fit: BoxFit.fill,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes !=
                                          null
                                          ? loadingProgress
                                          .cumulativeBytesLoaded /
                                          (loadingProgress
                                              .expectedTotalBytes ??
                                              1)
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    "assets/chota",
                                    width: double.infinity,
                                    height: 270,
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                              addPadding(
                                child: Text(
                                  post.title ?? "",
                                  style: const TextStyle(
                                    color: AppColors.headerTextColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: addPadding(
                                  child: Text(
                                    post.content ?? "",
                                    style: fontStyle(
                                      color: AppColors.bodyTextColor,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              height(height: 8),
                            ],
                          ),
                        );
                      },
                      flipDirection: _flipDirection, // Dynamic flip direction
                    ),
                  ),
                );
              },
            );
          } else {
            // Error or other unexpected state
            return Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: Text(
                  "Something went wrong. Please try again.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  // Utility method for padding
  Widget addPadding({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
      child: child,
    );
  }
}





// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:chotanews/screens/testing_screen/test_bloc.dart';
// import 'package:chotanews/screens/testing_screen/test_event.dart';
// import 'package:chotanews/screens/testing_screen/test_state.dart';
// import 'package:flip_board/flip_widget.dart';
//
// import '../../utils/app_colors.dart';
// import '../../utils/app_fonts.dart';
// import '../../utils/app_spaces.dart';
//
// class PreviewScreen extends StatefulWidget {
//   const PreviewScreen({super.key});
//
//   @override
//   State<PreviewScreen> createState() => _PreviewScreenState();
// }
//
// class _PreviewScreenState extends State<PreviewScreen> {
//   final _streamController = StreamController.broadcast();
//   int _currentIndex = 0;
//   AxisDirection _flipDirection = AxisDirection.up;
//   bool _isFlipping = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _streamController.add(_currentIndex);
//     context.read<TestBloc>().add(TestEventOne());
//   }
//
//   @override
//   void dispose() {
//     _streamController.close();
//     super.dispose();
//   }
//
//   void _nextPage() async {
//     if (_currentIndex < 100 - 1 && !_isFlipping) {
//       setState(() {
//         _isFlipping = true; // Lock flipping
//         _currentIndex++;
//         _flipDirection = AxisDirection.up; // Flip upward
//         _streamController.add(_currentIndex);
//       });
//       print(_currentIndex);
//       await Future.delayed(const Duration(seconds: 1)); // Animation delay
//       setState(() {
//         _isFlipping = false; // Unlock flipping
//       });
//     }
//   }
//
//   void _previousPage() async {
//     if (_currentIndex > 0 && !_isFlipping) {
//       setState(() {
//         _isFlipping = true; // Lock flipping
//         _currentIndex--;
//         _flipDirection = AxisDirection.down; // Flip downward
//         _streamController.add(_currentIndex);
//       });
//       await Future.delayed(const Duration(seconds: 1)); // Animation delay
//       setState(() {
//         _isFlipping = false; // Unlock flipping
//       });
//     }
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
//             return GestureDetector(
//               onVerticalDragUpdate: (details) {
//                 if (!_isFlipping) {
//                   if (details.delta.dy > 0) {
//                     _previousPage();
//                   } else if (details.delta.dy < 0) {
//                     _nextPage();
//                   }
//                 }
//               },
//
//               onVerticalDragEnd: (details){
//                 if (!_isFlipping) {
//                   if (details.velocity.pixelsPerSecond.dy > 0) {
//                     _nextPage();
//                   } else if (details.velocity.pixelsPerSecond.dy < 0) {
//                     _previousPage();
//                   }
//                 }// Swiping down
//               },
//               child: FlipWidget(
//                 initialValue: _currentIndex,
//                 flipType: FlipType.middleFlip,
//                 itemStream: _streamController.stream,
//                 itemBuilder: (_, index) {
//                   final post = state.newPosts[index];
//                   return Container(
//                     color: Colors.blueGrey.shade300,
//                     height: MediaQuery.of(context).size.height,
//                     width: MediaQuery.of(context).size.width,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Image.network(
//                           post.imageUrl?.url ?? "",
//                           width: double.infinity,
//                           height: MediaQuery.of(context).size.height/2,
//                           fit: BoxFit.fill,
//                           loadingBuilder: (context, child, loadingProgress) {
//                             if (loadingProgress == null) return child;
//                             return Center(
//                               child: CircularProgressIndicator(
//                                 value: loadingProgress.expectedTotalBytes != null
//                                     ? loadingProgress.cumulativeBytesLoaded /
//                                     (loadingProgress.expectedTotalBytes ?? 1)
//                                     : null,
//                               ),
//                             );
//                           },
//                           errorBuilder: (context, error, stackTrace) {
//                             return Image.asset(
//                               "assets/chota",
//                               width: double.infinity,
//                               height: 270,
//                               fit: BoxFit.cover,
//                             );
//                           },
//                         ),
//                         addPadding(
//                           child: Text(
//                             post.title ?? "",
//                             style: const TextStyle(
//                               color: AppColors.headerTextColor,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: addPadding(
//                             child: Text(
//                               post.content ?? "",
//                               style: fontStyle(
//                                 color: AppColors.bodyTextColor,
//                                 fontWeight: FontWeight.normal,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ),
//                         height(height: 8),
//                       ],
//                     ),
//                   );
//                 },
//                 flipDirection: _flipDirection,
//               ),
//             );
//           } else {
//             // Error or other unexpected state
//             return Container(
//               color: Colors.grey,
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               child: const Center(
//                 child: Text(
//                   "Something went wrong. Please try again.",
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
//
//   // Utility method for padding
//   Widget addPadding({required Widget child}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
//       child: child,
//     );
//   }
// }
