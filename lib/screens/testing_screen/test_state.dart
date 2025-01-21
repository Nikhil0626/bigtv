import 'package:chotanews/screens/testing_screen/test_model.dart';

abstract class TestState {}

class InitialState extends TestState {}

class Success extends TestState {
 final List<NewsPost> newPosts;

  Success({required this.newPosts});
}
