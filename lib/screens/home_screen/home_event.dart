import 'package:flutter_card_swiper/flutter_card_swiper.dart';

abstract class HomeScreenEvent {}

class GetAllNewsFeed extends HomeScreenEvent {}

class GetFollowingNewsFeed extends HomeScreenEvent {}

class OnSwipeCard extends HomeScreenEvent {
 final int index;

  OnSwipeCard(
      {required this.index});
}

class OnSwipeEndCard extends HomeScreenEvent {
  var data;
  OnSwipeEndCard({required this.data});
}


class SendNewsToSocialMedia extends HomeScreenEvent{
  String id;

  SendNewsToSocialMedia({required this.id});
}