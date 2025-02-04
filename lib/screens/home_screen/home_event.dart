import 'package:flutter/cupertino.dart';

abstract class HomeScreenEvent {}

class GetAllNewsFeed extends HomeScreenEvent {}
class GetAllDistrictFeed extends HomeScreenEvent {}

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

class MenuChange extends HomeScreenEvent{}



class MenuItemClickEvent extends HomeScreenEvent{
  final String currentMenuItem;
  final BuildContext context;
  MenuItemClickEvent({required this.currentMenuItem,required this.context});
}

class CommentByPost extends HomeScreenEvent {
  final String postData;
  final String postId;
  CommentByPost({required this.postData,required this.postId,});
}

class LikeByPost extends HomeScreenEvent {
  final bool isLike;
  final String postId;
  LikeByPost({required this.isLike,required this.postId,});
}