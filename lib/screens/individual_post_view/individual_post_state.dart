import 'package:chotanews/screens/home_screen/home_screen_model.dart';

abstract class IndividualPostState {}


class InitialPostState extends IndividualPostState {}
class LoadingPostState extends IndividualPostState {}
class SuccessPostState extends IndividualPostState {
  final HomeScreenModel getPost;

  SuccessPostState({required this.getPost});

}
class ErrorPostState extends IndividualPostState {
  final String error;
  ErrorPostState({required this.error});
}