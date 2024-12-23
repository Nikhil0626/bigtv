import 'package:flutter/cupertino.dart';

class ArticleProvider extends ChangeNotifier {
  double offset = 0.0;
  bool isExpand = false;



  void handleDragEnd(DragEndDetails details, void param1,
      VoidCallback resetSwipedIndex,) {
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
