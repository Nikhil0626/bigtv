import 'dart:developer';

import 'package:chotanews/screens/Auth_module/auth_event.dart';
import 'package:chotanews/screens/Auth_module/auth_repo.dart';
import 'package:chotanews/screens/Auth_module/auth_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(InitialScreen()) {
    on<GoogleLogin>((event, emit) async {
      emit(LoadingScreen());
      try{
        Response response = await AuthRepo().loginWithGoogle();
        log(" Google Login Response ${response.data}");
        emit(SuccessScreen(message: ""));

      }on DioException catch(e,st){
        emit(ErrorScreen(message: ""));

        log("Google Login dio catch error ${st.toString()}");
        log("Google Login dio catch ${st.toString()}");
      }catch(e,st){
        emit(ErrorScreen(message: ""));
        log("Google Login catch error ${st.toString()}");
        log("Google Login catch ${st.toString()}");
      }

    });
    on<AppleLogin>((event, emit) async {
      log("Login via Apple device ");
      emit(LoadingScreen());
      try{
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        print(credential);
        log(" Apple Login Response ${credential.toString()}");
        emit(SuccessScreen(message: ""));

      }on DioException catch(e,st){
        emit(ErrorScreen(message: ""));

        log("Apple Login dio catch error ${st.toString()}");
        log("Apple Login dio catch ${st.toString()}");
      }catch(e,st){
        emit(ErrorScreen(message: ""));
        log("Apple Login catch error ${st.toString()}");
        log("Apple Login catch ${st.toString()}");
      }

    });

    on<SkipLogin>((event, emit) async {
      log("Login Skip ");
      emit(SuccessScreen(message: "Skip"));

    });


  }
}
