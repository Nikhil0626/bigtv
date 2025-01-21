
abstract class HomeHandleState{}

class InitialHomeState extends HomeHandleState{}

class LoadingHomeState extends HomeHandleState{}

class ErrorHomeState extends HomeHandleState{}

class SuccessHomeState extends HomeHandleState{}

class ActiveAndInActive extends HomeHandleState{
  bool isActive = false;

  ActiveAndInActive({required this.isActive});
}


