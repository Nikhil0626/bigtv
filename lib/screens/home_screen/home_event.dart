import 'package:appinio_swiper/enums.dart';

abstract class HomeScreenEvent {}

class GetAllNewsFeed extends HomeScreenEvent {}

class GetFollowingNewsFeed extends HomeScreenEvent {}

class OnSwipeCard extends HomeScreenEvent {
  int? previousIndex;
  int? targetIndex;
  SwiperActivity? activity;
  int? totalPosts;

  OnSwipeCard(
      {required this.previousIndex,
      required this.targetIndex,
      required this.activity,
      required this.totalPosts});
}

class OnSwipeEndCard extends HomeScreenEvent {
  var data;
  OnSwipeEndCard({required this.data});
}
