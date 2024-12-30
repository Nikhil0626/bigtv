import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tweetai/utils/app_colors.dart';

class CardSwipeIndicationAnimation extends StatefulWidget {
  final double maxWidth;

  const CardSwipeIndicationAnimation({Key? key, required this.maxWidth})
      : super(key: key);

  @override
  _CardSwipeIndicationAnimationState createState() =>
      _CardSwipeIndicationAnimationState();
}

class _CardSwipeIndicationAnimationState
    extends State<CardSwipeIndicationAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(
      begin: 0 ,
      end: -100
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget? child) {
        return Transform.translate(
          offset: Offset(_animation.value, 0), // Use the animation value for horizontal movement
          child: Shimmer.fromColors(
            baseColor: AppColors.appButtonColor.withOpacity(.5),
            highlightColor: Colors.lightBlueAccent.withOpacity(.5),
            child:_animation.isCompleted?const SizedBox.shrink(): Transform.rotate(
              angle: 3.14159, // Rotate the icon by 180 degrees
              child: const Icon(
                Icons.double_arrow,
                size: 100,
                color: Colors.blueAccent,
              ),
            ),
          ),
        );
      },
    );
  }
}
