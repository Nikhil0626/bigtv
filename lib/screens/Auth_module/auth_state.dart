abstract class AuthState{}

class InitialScreen extends AuthState{}

class LoadingScreen extends AuthState{}

class SuccessScreen extends AuthState{
  String message = "";
  String otp ;
  SuccessScreen({ required this.message, this.otp="",});
}

class ErrorScreen extends AuthState{
  String message = "";
  ErrorScreen({ required this.message});
}

class MobileNumberValid extends AuthState {}

class MobileNumberInvalid extends AuthState {
  final String errorMessage;

  MobileNumberInvalid(this.errorMessage);
}
