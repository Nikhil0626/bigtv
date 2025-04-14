import 'dart:developer';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_repo/authentication_repo.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_view.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../../globel_keys/global_variables_data.dart';
import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_toasts.dart';
import '../../../utils/local_data.dart';
import '../authentication_model/categories_model.dart';
import '../authentication_model/location_model.dart';
import '../authentication_view/login_background_view.dart';

class AuthenticationProvider extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isLoginLoading = false;
  bool isVerifyLoading = false;
  String? errorMessage;
  bool isButtonEnabled = false;
  bool isOtpButtonEnabled = false;
  NewAppLoginStatus newAppLoginStatus = NewAppLoginStatus.none;


  List<CategoryModel> getAllCategoryList = [];
  List<String> selectedCategories = [];
  List<LocationModel> getAllLocationList = [];
  List<String> selectedLocations = [];

  void validationErrors(value) {
    if (value == null || value.trim().isEmpty) {
      errorMessage = "Please Enter Mobile Number";
      isButtonEnabled = false;
      notifyListeners();
      return;
    } else if (value.length < 10) {
      errorMessage = "Enter Exactly 10 Digits";
      isButtonEnabled = false;
      notifyListeners();
      return;
    } else if (!RegExp(r'^[6789]\d{9}$').hasMatch(value)) {
      errorMessage = "Enter Valid Phone Number";
      isButtonEnabled = false;
      notifyListeners();
      return;
    } else {
      isButtonEnabled = value.length == 10;
      notifyListeners();
      return null;
    }
  }

  void checkOtpFilled(String value) {
    isOtpButtonEnabled = value.length == 4;
    notifyListeners();
  }

  Future sendOtp(BuildContext context) async {
    isLoginLoading = true;

    log("ButtonClicked __${phoneController.text}");
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");

    Map<String, dynamic> body = {
      "mobile_number": phoneController.text.toString(),
      "device_id": deviceId.toString(),
    };
    log(body.toString());

    try {
      Response response = await AuthenticationRepo().sendOtp(body);
      log(response.toString());
      if (response.statusCode == 200) {
        newAppLoginStatus = NewAppLoginStatus.otp;
        saveLoginState();
        otpController.text = "";
      }else{
        CustomToast.showErrorToast(msg: "Check your mobile number try again");
      }
    } catch (e, st) {
      CustomToast.showErrorToast(msg: "Check your mobile number try again");
      log(e.toString());
      log(st.toString());
    } finally {

      isLoginLoading = false;
      notifyListeners();
    }
  }

  Future verifyOtp(
    context,
  ) async {
    errorMessage = '';
    isVerifyLoading  = true;
    isButtonEnabled = false;
    notifyListeners();
    log(
      phoneController.text.toString(),
    );

    SharedPreferences sp = await SharedPreferences.getInstance();
    String? deviceId = sp.getString("deviceId");
    try {
      Map<String, dynamic> body = {
        "mobile_number": phoneController.text.toString(),
        "otp": otpController.text,
        "device_id": deviceId,
      };
      log(body.toString());
      Response response = await AuthenticationRepo().validateOtp(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        sp.setString("loginType", "login");
        sp.setString("userId", response.data['user']['id'].toString());
        if (response.data['is_new_user'] == false) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeView(),
            ),
            (route) => false,
          );
          Future.delayed(
            Duration(seconds: 2),
            () {
              newAppLoginStatus = NewAppLoginStatus.home;
              saveLoginState();
            },
          );
        } else {

          newAppLoginStatus = NewAppLoginStatus.category;
          saveLoginState();
          getAllCategories();
        }

        EventRepo().sendEvent({
          "key": "otp_verify",
          "data": {"device_id": "${deviceId}", "isVerify": true, "mobileNumber": phoneController.text, "otp": otpController.text, "userId": ""}
        });

        EventRepo().sendEvent({
          "key": "login_skip",
          "data": {"device_id": "${deviceId}", "isLogin": true, "userId": ""}
        });
        WebEngagePlugin.userLogin("");
        WebEngagePlugin.setUserPhone(phoneController.text.toString());
        mobileVerificationDetails(phoneController.text.toString(), true);

        GlobalVariables().userId = "";
        SharedPreferences preferences = await SharedPreferences.getInstance();
        saveUserid("");
        preferences.setString("userName", "User${phoneController.text.substring(phoneController.text.length - 4)}");
        preferences.setString("referralCode", "");

        phoneController.text = "";
        notifyListeners();
      } if(response.statusCode == 400){
        errorMessage = response.data['detail'].toString();
        CustomToast.showErrorToast(msg: response.data['detail']);
      }
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(msg: e.message);
      log("error dio ${e.toString()}");
      log("error dio  ${st.toString()}");
    } catch (e, st) {
      log("error  ${e.toString()}");
      log("error  ${st.toString()}");
      CustomToast.showErrorToast(msg: "Something went wrong");
    } finally {
      isVerifyLoading = false;
      notifyListeners();
    }
  }

  bool isCatLoading = false;
  bool isCatSaveLoading = false;

  Future getAllCategories() async {
    isCatLoading = true;
    selectedCategories = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    Map<String, dynamic> body = {
      "device_id": deviceId,
    };
    try {
      log("get all catttt");
      Response response = await AuthenticationRepo().getAllCategories(body);
      if (response.statusCode == 200) {
        List data = response.data['categories'];
        getAllCategoryList = data
            .map(
              (e) => CategoryModel.fromJson(e),
            )
            .toList();

        selectedCategories = getAllCategoryList.where((item) => item.isFollowed == true).map((item) => item.categoryName.toString()).toList();
        log(getAllCategoryList.first.categoryName.toString());
        String result = selectedLocations.toSet().join(',');
        preferences.setString("categoriesId", result);
      }
    } on DioException catch (e, st) {
      log("Dio error get all cat --- ${e.toString()} --- ${st.toString()}");
    } catch (e, st) {
      log("Error get all cat --- ${e.toString()} --- ${st.toString()}");
    } finally {
      isCatLoading = false;
      notifyListeners();
    }
  }

  void addToSelectedEngagements(String profileName) {
    if (!selectedCategories.contains(profileName)) {
      selectedCategories.add(profileName);
      log(selectedCategories.toString());
      notifyListeners(); // Notify listeners if using ChangeNotifier
    } else {
      selectedCategories.remove(profileName);
      notifyListeners();
    }
  }

  Future sendCategoriesToServer({bool isFilter = false}) async {
    isCatSaveLoading = true;
    List<int> selectedCategoryIds = getAllCategoryList.where((item) => selectedCategories.contains(item.categoryName.toString())).map((item) => item.categoryId as int).toList();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String result = selectedCategoryIds.toSet().join(',');
    preferences.setString("categoriesId", result);
    String? deviceId = preferences.getString("deviceId");
    Map<String, dynamic> body = {"device_id": deviceId, "categoryids": selectedCategoryIds};

    log(body.toString());
    try {
      log("response.data.toString123");
      Response response = await AuthenticationRepo().sendSelectCategories(body);
      if (response.statusCode == 200) {
        newAppLoginStatus = NewAppLoginStatus.location;
        saveLoginState();
        log(response.data.toString());
      }
    } on DioException catch (e, st) {
      log("Dio error get all cat --- ${e.toString()} --- ${st.toString()}");
    } catch (e, st) {
      log("Error get all cat --- ${e.toString()} --- ${st.toString()}");
    } finally {
      isCatSaveLoading = false;
      notifyListeners();
    }
  }

  Future getAllLocations() async {
    selectedLocations = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    Map<String, dynamic> body = {
      "device_id": deviceId,
    };
    try {
      log("response.data.toString123");
      Response response = await AuthenticationRepo().getAllLocations(body);
      if (response.statusCode == 200) {
        List data = response.data['locations'];
        getAllLocationList = data
            .map(
              (e) => LocationModel.fromJson(e),
            )
            .toList();

        selectedLocations = getAllLocationList.where((item) => item.isFollowed == true).map((item) => item.districtName.toString()).toList();
        log(getAllLocationList.first.districtName.toString());


        String result = selectedLocations.toSet().join(',');
        preferences.setString("locationId", result);
      }
    } on DioException catch (e, st) {
      log("Dio error get all cat --- ${e.toString()} --- ${st.toString()}");
    } catch (e, st) {
      log("Error get all cat --- ${e.toString()} --- ${st.toString()}");
    } finally {
      notifyListeners();
    }
  }

  void addToSelectedLocations(String profileName) {
    if (!selectedLocations.contains(profileName)) {
      selectedLocations.add(profileName);
      log(selectedLocations.toString());
      notifyListeners(); // Notify listeners if using ChangeNotifier
    } else {
      selectedLocations.remove(profileName);
      notifyListeners();
    }
  }

  Future sendLocationsToServer(BuildContext context) async {
    List<int> selectedCategoryIds = getAllLocationList.where((item) => selectedLocations.contains(item.districtName.toString())).map((item) => item.districtId).toList();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String result = selectedCategoryIds.toSet().join(',');
    preferences.setString("locationId", result);

    Map<String, dynamic> body = {"device_id": deviceId, "location_ids": selectedCategoryIds};

    log(body.toString());
    try {
      log("response.data.toString123");
      Response response = await AuthenticationRepo().sendSelectLocations(body);
      if (response.statusCode == 200) {
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeView(),
            ),
            (route) => false,
          );
          Future.delayed(
            Duration(seconds: 2),
            () {
              newAppLoginStatus = NewAppLoginStatus.home;
              saveLoginState();
            },
          );
        }
        log(response.data.toString());
      }
    } on DioException catch (e, st) {
      log("Dio error get all cat --- ${e.toString()} --- ${st.toString()}");
    } catch (e, st) {
      log("Error get all cat --- ${e.toString()} --- ${st.toString()}");
    } finally {
      notifyListeners();
    }
  }

  void isPageNavigation(BuildContext context) async {
    NewAppLoginStatus status = await getLoginStatus();
    log("Page Name $status");
    switch (status) {
      case NewAppLoginStatus.skip:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeView(),
          ),
          (route) => false,
        );
        break;
      case NewAppLoginStatus.home:
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HomeView(),
            ));
        break;
      default:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginBackgroundView(),
          ),
          (route) => false,
        );
    }
  }

  void saveLoginState() async {
    log("loginState");
    log(newAppLoginStatus.toString());
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("loginState", newAppLoginStatus.toString());
  }

  Future<NewAppLoginStatus> getLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? status = prefs.getString('loginState');

    if (status != null) {
      return NewAppLoginStatus.values.firstWhere((e) => e.toString() == status, orElse: () => NewAppLoginStatus.none);
    }
    return NewAppLoginStatus.none;
  }

  void continueAsGuest(context,) async {
    newAppLoginStatus = NewAppLoginStatus.category;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("loginState", newAppLoginStatus.toString());
    preferences.setString("loginType", "skip");
    notifyListeners();
    // isPageNavigation(context);
  }

  void setLogOutStatus(context, bool isLogout) async {
    newAppLoginStatus =isLogout?NewAppLoginStatus.skip: NewAppLoginStatus.login;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("loginState", newAppLoginStatus.toString());
    isPageNavigation(context);
  }
}
