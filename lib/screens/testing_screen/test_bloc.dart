import 'package:chotanews/screens/testing_screen/test_event.dart';
import 'package:chotanews/screens/testing_screen/test_model.dart';
import 'package:chotanews/screens/testing_screen/test_repo.dart';
import 'package:chotanews/screens/testing_screen/test_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  List<NewsPost> getAllPosts = [];
  TestBloc() : super(InitialState()){
    on<TestEventOne>((event,emit) async{

     Response res =  await TestRepo().getHomePageNews();
      List data = res.data['posts'];
     getAllPosts = data.map((e) => NewsPost.fromJson(e),).toList();
      emit(Success(newPosts: getAllPosts));

    });
  }
}
