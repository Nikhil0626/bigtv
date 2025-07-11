import 'dart:developer';

import 'package:chotanews/aggricator_screens/auth_screens/authentication_repo/authentication_repo.dart';
import 'package:chotanews/aggricator_screens/event_repo.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_view.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../../globel_keys/global_variables_data.dart';

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
  bool isBlockedUser = true;
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

  void updateNumber() {
    isBlockedUser = true;
    notifyListeners();
  }

  Future sendOtp(BuildContext context) async {
    isLoginLoading = true;
    notifyListeners();
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
        if (response.data['is_active'] == false) {
          isBlockedUser = response.data['is_active'];
        } else {
          newAppLoginStatus = NewAppLoginStatus.otp;
          saveLoginState();
          EventRepo().addEvent({
            "loginType": "mobileNumber",
            "mobileNumber": otpController.text ?? "",
            "createAt": DateTime.now().toString(),
          }, "login_event");
          otpController.text = "";
        }
      } else {
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
    isVerifyLoading = true;
    isButtonEnabled = false;
    notifyListeners();
    log(
      phoneController.text.toString(),
    );

    SharedPreferences sp = await SharedPreferences.getInstance();
    String? deviceId = sp.getString("deviceId");
    String? referralCode = sp.getString("referralCode");
    try {
      Map<String, dynamic> body = {
        "mobile_number": phoneController.text.toString(),
        "otp": otpController.text,
        "device_id": deviceId,
        "referral_id": referralCode ?? "",
      };
      log(body.toString());
      Response response = await AuthenticationRepo().validateOtp(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        sp.setString("loginType", "login");
        sp.setString("myReferralCode", response.data['user']['referral_code'].toString() ?? "");
        sp.setString("myReferralLink", response.data['referral_link'].toString() ?? "");
        sp.setString("userId", response.data['user']['id'].toString());
        sp.setString("userStatus", response.data['user']['status'].toString());
        if (response.data['is_new_user'] == false) {
          getAllCategories();
          getAllLocations();
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
          // getAllLocations();
        }

        WebEngagePlugin.userLogin(response.data['user']['id'].toString());
        WebEngagePlugin.setUserPhone(phoneController.text.toString());
        mobileVerificationDetails(phoneController.text.toString(), true);

        GlobalVariables().userId = "";
        SharedPreferences preferences = await SharedPreferences.getInstance();
        saveUserid("");
        preferences.setString("userName", "User${phoneController.text.substring(phoneController.text.length - 4)}");
        preferences.setString("referralCode", "");
        EventRepo().addEvent({"otpStatus": "complete", "mobileNumber": otpController.text ?? "", "otp": phoneController.text ?? "", "createAt": DateTime.now().toString()}, "otp_verify");
        phoneController.text = "";
        notifyListeners();
      }
      if (response.statusCode == 400) {
        errorMessage = response.data['detail'].toString();
        CustomToast.showErrorToast(msg: response.data['detail']);
      }
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(msg: e.message);
      log("error dio ${e.toString()}");
      log("error dio  ${st.toString()}");
      EventRepo().addEvent({"otpStatus": "fail", "mobileNumber": otpController.text ?? "", "otp": phoneController.text ?? "", "createAt": DateTime.now().toString()}, "otp_verify");
    } catch (e, st) {
      log("error  ${e.toString()}");
      log("error  ${st.toString()}");
      CustomToast.showErrorToast(msg: "Something went wrong");
      EventRepo().addEvent({"otpStatus": "fail", "mobileNumber": otpController.text ?? "", "otp": phoneController.text ?? "", "createAt": DateTime.now().toString()}, "otp_verify");
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
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "device_id": deviceId ?? "",
      "user_id": userId ?? "",
    };
    try {
      log("get all catttt$body");

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
        String result = selectedCategories.toSet().join(',');
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
    String catNames = selectedCategories.toSet().join(',');
    preferences.setString("categoriesId", result);
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    // preferences.setString("locationId", result);

    Map<String, dynamic> body = {
      "device_id": deviceId,
      "categoryids": selectedCategoryIds,
      "user_id": userId ?? "",
    };

    log(body.toString());
    try {
      Response response = await AuthenticationRepo().sendSelectCategories(body);
      if (response.statusCode == 200) {
        if (!isFilter) {
          saveLoginState();
          newAppLoginStatus = NewAppLoginStatus.location;
        }
        log(response.data.toString());
        EventRepo().addEvent({"listOfCategoriesIds": result ?? "", "listOfCategoriesNames": catNames ?? "", "updateStatus": "complete", "createAt": DateTime.now().toString()}, "update_categories");
      }
    } on DioException catch (e, st) {
      log("Dio error get all cat --- ${e.toString()} --- ${st.toString()}");
      EventRepo().addEvent({"listOfCategoriesIds": result ?? "", "listOfCategoriesNames": catNames ?? "", "updateStatus": "fail", "createAt": DateTime.now().toString()}, "update_categories");
    } catch (e, st) {
      log("Error get all cat --- ${e.toString()} --- ${st.toString()}");
      EventRepo().addEvent({"listOfCategoriesIds": result ?? "", "listOfCategoriesNames": catNames ?? "", "updateStatus": "fail", "createAt": DateTime.now().toString()}, "update_categories");
    } finally {
      isCatSaveLoading = false;
      notifyListeners();
    }
  }

  bool isLocationLoading = false;
  Map<int, String>? states;

  Future getAllLocations() async {
    isLocationLoading = true;
    selectedLocations = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "device_id": deviceId,
      "user_id": userId ?? "",
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

        states = {for (var d in data) d['stateId']: d['stateName']};

        print(states);

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
      isLocationLoading = false;
      notifyListeners();
    }
  }

  bool isLocationSendingLoading = false;

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

  Future sendLocationsToServer(BuildContext context, {bool isFilter = false}) async {
    isLocationSendingLoading = true;
    notifyListeners();
    List<int> selectedCategoryIds = getAllLocationList.where((item) => selectedLocations.contains(item.districtName.toString())).map((item) => item.districtId).toList();
    log("selkhvgbkjegjke ${selectedCategoryIds}");
    log("Selected District Names: $selectedLocations");
    String nameOfDistrict = selectedLocations.toSet().join(',');
    sendUserAttribute(nameOfDistrict);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    String result = selectedCategoryIds.toSet().join(',');
    preferences.setString("locationId", result);

    Map<String, dynamic> body = {
      "device_id": deviceId,
      "location_ids": selectedCategoryIds,
      "user_id": userId ?? "",
    };

    log(body.toString());
    try {
      log("response.data.toString123");
      Response response = await AuthenticationRepo().sendSelectLocations(body);
      if (response.statusCode == 200) {
        if (!isFilter) {
          newAppLoginStatus = NewAppLoginStatus.home;
          saveLoginState();
        }

        log(response.data.toString());
        EventRepo().addEvent({"listOfLocationsIds": result ?? "", "listOfLocationsNames": nameOfDistrict ?? "", "updateStatus": "complete", "createAt": DateTime.now().toString()}, "update_locations");
      }
    } on DioException catch (e, st) {
      log("Dio error get all cat --- ${e.toString()} --- ${st.toString()}");
      EventRepo().addEvent({"listOfLocationsIds": result ?? "", "listOfLocationsNames": "", "updateStatus": "fail", "createAt": DateTime.now().toString()}, "update_locations");
    } catch (e, st) {
      log("Error get all cat --- ${e.toString()} --- ${st.toString()}");
      EventRepo().addEvent({"listOfLocationsIds": result ?? "", "listOfLocationsNames": "", "updateStatus": "fail", "createAt": DateTime.now().toString()}, "update_locations");
    } finally {
      isLocationSendingLoading = false;
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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeView(),
          ),
          (route) => false,
        );
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

  void continueAsGuest(
    context,
  ) async {
    newAppLoginStatus = NewAppLoginStatus.category;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("loginState", newAppLoginStatus.toString());
    preferences.setString("loginType", "skip");
    String? deviceId = await preferences.getString("deviceId");

    notifyListeners();
    // isPageNavigation(context);
  }

  void setLogOutStatus(context, bool isLogout) async {
    newAppLoginStatus = isLogout ? NewAppLoginStatus.skip : NewAppLoginStatus.login;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    preferences.setString("loginState", newAppLoginStatus.toString());
    String? deviceId = await preferences.getString("deviceId");
    String? userId = await preferences.getString("userId");

    isPageNavigation(context);
  }

  void sendEvent(pageName) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
  }
}
