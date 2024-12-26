import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CardSwipeIndicationAnimation extends StatefulWidget {
  final double maxWidth;

  const CardSwipeIndicationAnimation({Key? key, required this.maxWidth})
      : super(key: key);

  @override
  _CardSwipeIndicationAnimationState createState() =>
      _CardSwipeIndicationAnimationState();
}

class _CardSwipeIndicationAnimationState extends State<CardSwipeIndicationAnimation> {
  double _arrowPosition = 0.0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startArrowAnimation();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startArrowAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _arrowPosition += 2.0; // Adjust speed
        if (_arrowPosition > widget.maxWidth - 40) {
          _arrowPosition = 0.0; // Reset position
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(_arrowPosition, 0),
      child: Shimmer.fromColors(
        baseColor: Colors.blueAccent,
        highlightColor: Colors.lightBlueAccent,
        child: const Icon(
          Icons.double_arrow,
          size: 100,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}