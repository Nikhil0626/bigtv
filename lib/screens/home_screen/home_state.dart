
import 'package:chotanews/screens/home_screen/home_screen_model.dart';

abstract class HomeScreenState{}


class InitialHomeScreenState extends HomeScreenState{}
class LoadingHomeScreenState extends HomeScreenState{}
class SuccessHomeScreenState extends HomeScreenState{
  List<HomeScreenModel> getAllHomeScreenNews = [];
  final String pageType;
  SuccessHomeScreenState({required this.getAllHomeScreenNews, required this.pageType});

}
class ErrorHomeScreenState extends HomeScreenState{
  String getHomeScreenError = "";
  ErrorHomeScreenState({required this.getHomeScreenError});

}


///Card Swipe End
 class OnSwipeForwardHomeState extends HomeScreenState{


 }