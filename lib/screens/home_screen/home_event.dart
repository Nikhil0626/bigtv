import 'package:flutter_card_swiper/flutter_card_swiper.dart';

abstract class HomeScreenEvent {}

class GetAllNewsFeed extends HomeScreenEvent {}

class GetFollowingNewsFeed extends HomeScreenEvent {}

class OnSwipeCard extends HomeScreenEvent {
 final int previousIndex;
  final  int currentIndex;
  CardSwiperDirection direction;

  OnSwipeCard(
      {required this.previousIndex,
      required this.currentIndex,
      required this.direction});
}

class OnSwipeEndCard extends HomeScreenEvent {
  var data;
  OnSwipeEndCard({required this.data});
}
