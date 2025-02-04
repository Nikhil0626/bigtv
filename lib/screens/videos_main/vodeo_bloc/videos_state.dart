import '../videos_model/GetMenuItemModel.dart';
import '../videos_model/videos_model.dart';

abstract class VideosState{ }

class InitialState extends VideosState {}

class LoadingState extends VideosState {
}

class VideoSuccessState extends VideosState {
  List<GetAllVideosModel> getAllVideoList = [];

  VideoSuccessState({required this.getAllVideoList});

}

class MenuItemState extends VideosState {
  List<GetMenuItemModel> getAllMenuList = [];

  MenuItemState({required this.getAllMenuList});

}

class VideoErrorState extends VideosState {
  String? message;
  VideoErrorState({required this.message});
}
