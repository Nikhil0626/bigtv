
import 'package:chotanews/screens/home_screen/home_screen_model.dart';

abstract class HomeScreenState{}


class InitialHomeScreenState extends HomeScreenState{}
class LoadingHomeScreenState extends HomeScreenState{}



class SuccessHomeScreenState extends HomeScreenState{
  List<HomeScreenModel> getAllHomeScreenNews = [];
  final String pageType;
  final int firstIndex;
  final bool isLike;
  final bool isShare;
  bool isChange;

  SuccessHomeScreenState({required this.getAllHomeScreenNews, required this.pageType,required this.firstIndex , this.isLike = false, this.isShare=false,required this.isChange});

}
class ErrorHomeScreenState extends HomeScreenState{
  String getHomeScreenError = "";
  ErrorHomeScreenState({required this.getHomeScreenError});

}


///Card Swipe End
 class OnSwipeForwardHomeState extends HomeScreenState{


 }
 class MenuChangeState extends HomeScreenState{
   bool isChange;
   MenuChangeState({required this.isChange});
 }

 class CurrentMenuItemState extends HomeScreenState{
   final String currentMenuItem;
   CurrentMenuItemState({required this.currentMenuItem});
 }
