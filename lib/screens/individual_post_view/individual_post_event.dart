abstract class IndividualPostEvent {}

class GetSinglePost extends IndividualPostEvent{
 final String postId;
 GetSinglePost({required this.postId});
}