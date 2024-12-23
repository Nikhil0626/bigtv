import 'package:flutter/cupertino.dart';

class HomeSwipeCardProvider extends ChangeNotifier {
  double offset = 0.0;
  bool isExpand = false;

  void didChangeWidget(currentSwipedIndex, index) {
    if (currentSwipedIndex != index && offset != 0) {
      offset = 0;
      notifyListeners();
    }
  }

  void handleDragEnd(
    DragEndDetails details,
    void param1,
    VoidCallback resetSwipedIndex,
  ) {
    if (offset < -40) {
      offset = -80;
      param1;
    } else if (offset > 40) {
      offset = 80;
      param1;
    } else {
      offset = 0;
      resetSwipedIndex;
    }
    notifyListeners();
  }
}
