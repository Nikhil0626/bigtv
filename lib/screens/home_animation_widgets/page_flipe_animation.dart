import 'dart:async';

import 'package:flutter/material.dart';

class PageFlipAnimation extends StatefulWidget {
  final Widget bodyCard;
  final int length;
  const PageFlipAnimation({super.key, required this.bodyCard,required this.length});

  @override
  State<PageFlipAnimation> createState() => _PageFlipAnimationState();
}

class _PageFlipAnimationState extends State<PageFlipAnimation> {

  final StreamController<int> _streamController = StreamController<int>();
  int _currentIndex = 0;
  AxisDirection _flipDirection = AxisDirection.down;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _streamController.add(_currentIndex);
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  void _nextPage() async {
    if (_currentIndex < widget.length - 1 && !_isFlipping) {
      setState(() {
        _isFlipping = true; // Lock flipping
        _currentIndex++;
        _flipDirection = AxisDirection.down; // Flip downward
        _streamController.add(_currentIndex);
      });
      await Future.delayed(const Duration(milliseconds: 2000)); // Wait for flip animation
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
      await Future.delayed(const Duration(milliseconds: 5000)); // Wait for flip animation
      setState(() {
        _isFlipping = false; // Unlock flipping
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (!_isFlipping) {
            if (details.delta.dy < 0) {
              _previousPage(); // Swiping up
            }
          }
        },
        onVerticalDragEnd: (details){
          if (!_isFlipping) {
            if (details.velocity.pixelsPerSecond.dy > 0) {
              _nextPage();
            } else if (details.velocity.pixelsPerSecond.dy < 0) {
              _previousPage();
            }
          }// Swiping down
        },
        child: Center(
          // child: FlipWidget(
          //   initialValue: _currentIndex,
          //   flipType: FlipType.middleFlip,
          //   itemStream: _streamController.stream,
          //   itemBuilder: (_, index) => widget.bodyCard,
          //   flipDirection: _flipDirection, // Dynamic flip direction
          // ),
        ),
      ),
    );
  }


}
