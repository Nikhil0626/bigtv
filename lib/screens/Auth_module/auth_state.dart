abstract class AuthState{}

class InitialScreen extends AuthState{}
class LoadingScreen extends AuthState{}
class SuccessScreen extends AuthState{
  String message = "";
  SuccessScreen({ required this.message});
}
class ErrorScreen extends AuthState{
  String message = "";
  ErrorScreen({ required this.message});
}