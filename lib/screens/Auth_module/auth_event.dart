import 'package:flutter/src/widgets/framework.dart';

abstract class AuthEvent {}

class GoogleLogin extends AuthEvent {}

class AppleLogin extends AuthEvent {}

class SkipLogin extends AuthEvent {}

class SendOtp extends AuthEvent {
  final String phoneNumber;

  SendOtp({required this.phoneNumber});
}

class SendReferralCode extends AuthEvent{
  final String referralCodeNumber;
  final String mobileNumber;
  final BuildContext context;
  SendReferralCode({required this.referralCodeNumber,required this.mobileNumber, required this.context});
}


class VerificationOtp extends AuthEvent {
  final String Otp;
  final String mobileNumber;
  final BuildContext context;
  VerificationOtp({required this.Otp,required this.mobileNumber, required this.context});
}


class UserDetailsSave extends AuthEvent {
  final String userDetails;
  final String firstName;
  final String lastName;
  final String email;

  UserDetailsSave({required this.userDetails,
    required this.firstName,
    required this.lastName,
    required this.email,
  });
}


class MobileNumberChanged extends AuthEvent {
  final String mobileNumber;

  MobileNumberChanged(this.mobileNumber);
}
