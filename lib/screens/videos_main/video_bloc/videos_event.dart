abstract class VideosEvent{}

class GetAllVideos extends VideosEvent{
  String? type;
  GetAllVideos({required this.type});
}

class GetAllMenu extends VideosEvent{

}