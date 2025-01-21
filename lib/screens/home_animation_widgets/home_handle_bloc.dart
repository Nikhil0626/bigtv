

import 'package:chotanews/screens/home_animation_widgets/home_handle_event.dart';
import 'package:chotanews/screens/home_animation_widgets/home_handle_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeHandleBloc extends Bloc<HomeHandleEvent,HomeHandleState>{

bool isActive = false;
  HomeHandleBloc():super(InitialHomeState()){


    on<ActiveAndInactive>((event,emit)async{
      isActive = !isActive;
      emit(ActiveAndInActive(isActive: isActive));
    });
  }


}