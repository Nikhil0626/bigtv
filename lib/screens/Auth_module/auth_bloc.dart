import 'dart:developer';

import 'package:chotanews/screens/Auth_module/auth_event.dart';
import 'package:chotanews/screens/Auth_module/auth_repo.dart';
import 'package:chotanews/screens/Auth_module/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../globel_keys/global_variables_data.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(InitialScreen()) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    on<GoogleLogin>((event, emit) async {
      emit(LoadingScreen());
      try {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        String? deviceId = GlobalVariables().deviceId;
        print("Device ID: ${deviceId}");

        Map<String, dynamic> body = {
          "authType": "Google",
          "deviceId":deviceId,
          "email": googleUser!.email.toString(),
          "familyName":googleUser.displayName.toString().split(" ").first,
          "givenName": googleUser.displayName.toString().split(" ")[1],
          "id": googleUser.id.toString(),
          "name": googleUser.displayName.toString(),
          "photo": googleUser.photoUrl.toString()
        };

        log(body.toString());
        Response response = await AuthRepo().loginWithGoogle(body);
        if(response.statusCode == 200){
          emit(SuccessScreen(message: ""));
        }

      } on DioException catch (e, st) {
        emit(ErrorScreen(message: ""));
        log("Google Login dio catch error ${e.toString()}");
        log("Google Login dio catch ${st.toString()}");
      } catch (e, st) {
        emit(ErrorScreen(message: ""));
        log("Google Login catch error ${e.toString()}");
        log("Google Login catch ${st.toString()}");
      }
    });
    on<AppleLogin>((event, emit) async {
      log("Login via Apple device ");
      emit(LoadingScreen());
      try {
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        print(credential);
        log(" Apple Login Response ${credential.toString()}");
        emit(SuccessScreen(message: ""));
      } on DioException catch (e, st) {
        emit(ErrorScreen(message: ""));

        log("Apple Login dio catch error ${st.toString()}");
        log("Apple Login dio catch ${st.toString()}");
      } catch (e, st) {
        emit(ErrorScreen(message: ""));
        log("Apple Login catch error ${st.toString()}");
        log("Apple Login catch ${st.toString()}");
      }
    });

    on<SkipLogin>((event, emit) async {
      log("Login Skip ");
      emit(LoadingScreen());
      _googleSignIn.disconnect();
      emit(SuccessScreen(message: ""));
      emit(SuccessScreen(message: "Skip"));
    });
  }
}
///Device ID: UP1A.231005.007