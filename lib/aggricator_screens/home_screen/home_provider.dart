
import 'package:flutter/cupertino.dart';

class HomeProvider extends ChangeNotifier{
  int selectedIndex = 0;
  bool isSwitched = false;

  void onItemTapped(int index) {
      selectedIndex = index;
      notifyListeners();
  }

  void switchChange(value) {
      isSwitched = !isSwitched;
      notifyListeners();
  }



}