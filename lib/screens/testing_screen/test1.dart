import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SwipeStackView extends StatefulWidget {
  @override
  _SwipeStackViewState createState() => _SwipeStackViewState();
}

class _SwipeStackViewState extends State<SwipeStackView> {
  List<Color> cardColors = [
    Colors.orange,
    Colors.blue,
    Colors.black,
    Colors.green,
    Colors.purple,
  ];
  void _removeTopCard(int index) {
    if (cardColors.isNotEmpty && index < cardColors.length) {
      Color movedCard = cardColors[index];

      setState(() {
        cardColors.removeAt(index); // First, remove the card
      });

      // Delay adding it back to avoid "Dismissible still in tree" error
      Future.delayed(Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            cardColors.add(movedCard); // Then add it back at the end
          });
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: cardColors.isEmpty
            ? Text(
          "No more cards!",
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
        )
            : Stack(
          alignment: Alignment.center,
          children: List.generate(cardColors.length, (index) {
            double padding = index * 0.sp; // Adds spacing between stacked cards

            return Positioned(
              top: padding,
              bottom: padding,
              left: padding,
              right: padding,
              child: Dismissible(
                key: ValueKey(cardColors[index]), // Unique key for each color
                direction: DismissDirection.vertical,
                movementDuration: Duration(milliseconds: 500),
                onDismissed: (direction) {
                  _removeTopCard(index);
                },
                child: Card(
                  color: cardColors[index],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Text(
                      "Card ${index + 1}",
                      style: TextStyle(fontSize: 20.sp, color: Colors.white),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
