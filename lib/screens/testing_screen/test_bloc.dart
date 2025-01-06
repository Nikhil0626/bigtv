import 'package:chotanews/screens/testing_screen/test_event.dart';
import 'package:chotanews/screens/testing_screen/test_repo.dart';
import 'package:chotanews/screens/testing_screen/test_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  TestBloc() : super(InitialState()){
    on<TestEventOne>((event,state) async{
      await TestRepo().getHomePageNews();
    });
  }
}
