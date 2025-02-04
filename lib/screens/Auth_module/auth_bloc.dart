import 'dart:developer';

import 'package:chotanews/screens/Auth_module/auth_event.dart';
import 'package:chotanews/screens/Auth_module/auth_repo.dart';
import 'package:chotanews/screens/Auth_module/auth_state.dart';
import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_state.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../globel_keys/global_variables_data.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(InitialScreen()) {
     // Firebase.initializeApp();
    // final FirebaseAuth _auth = FirebaseAuth.instance;
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
          String? loginId = googleUser.id.toString();
          GlobalVariables().loginId = loginId;
          SharedPreferences preferences = await SharedPreferences.getInstance();

          preferences.setString("loginId",  googleUser.id.toString());
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
        log('Apple Sign-in Successful: ${credential}');
        String? deviceId = GlobalVariables().deviceId;
        log("Device ID: $deviceId");
        log(" Apple Login Response ${credential.toString()}");

        Map<String, dynamic> body = {
          "authType": "Apple",
          "deviceId": deviceId,
          "email": credential.email ?? "N/A", // Use stored email if null
          "familyName": credential.familyName ?? "N/A",
          "givenName": credential.givenName ?? "N/A",
          "id": credential.userIdentifier ?? "N/A",
          "name": credential.familyName ?? "N/A",
          "photo": null
        };

        log(body.toString());
        Response response = await AuthRepo().loginWithGoogle(body);
        if(response.statusCode == 200){
          String? loginId =  credential.userIdentifier.toString();
          GlobalVariables().loginId = loginId;
          SharedPreferences preferences = await SharedPreferences.getInstance();

          preferences.setString("loginId",  credential.userIdentifier.toString());
          emit(SuccessScreen(message: ""));
        }

      } on DioException catch (e, st) {
        emit(ErrorScreen(message: ""));

        log("Apple Login dio catch error ${e.toString()}");
        log("Apple Login dio catch ${st.toString()}");
      } catch (e, st) {
        emit(ErrorScreen(message: ""));
        log("Apple Login catch error ${e.toString()}");
        log("Apple Login catch ${st.toString()}");
      }
    });

    on<SkipLogin>((event, emit) async {
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

      sharedPreferences.setString("loginId", "Skip");
      log("Login Skip ");
      GlobalVariables().loginId = "Skip";
      log("Login Skip ${GlobalVariables().loginId}");

      emit(SuccessScreen(message: "Skip"));
    });

    on<SendOtp>((event, emit) async {
     emit(LoadingScreen());
     try{
     }catch(e,st) {

     }
    });


    on<MobileNumberChanged>((event, emit) async {
      if (event.mobileNumber.isEmpty) {
        emit(MobileNumberInvalid("Please enter your mobile number"));
      } else if (event.mobileNumber.length != 10) {
        emit(MobileNumberInvalid("Please enter a valid 10-digit mobile number"));
      } else {
        emit(MobileNumberValid());
      }
    });

  }
}


///Device ID: UP1A.231005.007
///
///
/// <dict>
// 	<key>CFBundleDevelopmentRegion</key>
// 	<string>$(DEVELOPMENT_LANGUAGE)</string>
// 	<key>CFBundleDisplayName</key>
// 	<string>Chotanews</string>
// 	<key>CFBundleExecutable</key>
// 	<string>$(EXECUTABLE_NAME)</string>
// 	<key>CFBundleIdentifier</key>
// 	<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
// 	<key>CFBundleInfoDictionaryVersion</key>
// 	<string>6.0</string>
// 	<key>CFBundleName</key>
// 	<string>chotanews</string>
// 	<key>CFBundlePackageType</key>
// 	<string>APPL</string>
// 	<key>CFBundleShortVersionString</key>
// 	<string>$(FLUTTER_BUILD_NAME)</string>
// 	<key>CFBundleSignature</key>
// 	<string>????</string>
// 	<key>CFBundleVersion</key>
// 	<string>$(FLUTTER_BUILD_NUMBER)</string>
// 	<key>LSRequiresIPhoneOS</key>
// 	<true/>
// 	<key>UILaunchStoryboardName</key>
// 	<string>LaunchScreen</string>
// 	<key>UIMainStoryboardFile</key>
// 	<string>Main</string>
// 	<key>UISupportedInterfaceOrientations</key>
// 	<array>
// 		<string>UIInterfaceOrientationPortrait</string>
// 		<string>UIInterfaceOrientationLandscapeLeft</string>
// 		<string>UIInterfaceOrientationLandscapeRight</string>
// 	</array>
// 	<key>UISupportedInterfaceOrientations~ipad</key>
// 	<array>
// 		<string>UIInterfaceOrientationPortrait</string>
// 		<string>UIInterfaceOrientationPortraitUpsideDown</string>
// 		<string>UIInterfaceOrientationLandscapeLeft</string>
// 		<string>UIInterfaceOrientationLandscapeRight</string>
// 	</array>
// 	<key>CADisableMinimumFrameDurationOnPhone</key>
// 	<true/>
// 	<key>UIApplicationSupportsIndirectInputEvents</key>
// 	<true/>
//
// 	<key>CFBundleURLTypes</key>
//     <array>
//       <dict>
//         <key>CFBundleTypeRole</key>
//         <string>Editor</string>
//         <key>CFBundleURLSchemes</key>
//         <array>
//           <string>com.googleusercontent.apps.YOUR_CLIENT_ID</string>
//         </array>
//       </dict>
//     </array>
//
// </dict>