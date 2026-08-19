import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';

import 'package:chotanews/features/auth/data/repositories/authentication_repo.dart';
import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/features/home/presentation/screens/home_view.dart';
import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:chotanews/services/webengage_event_tracks.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:chotanews/utils/local_data.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import 'package:chotanews/features/auth/domain/models/categories_model.dart';
import 'package:chotanews/features/auth/domain/models/location_model.dart';
import 'package:chotanews/features/auth/domain/models/language_model.dart';
import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';

class AuthenticationProvider extends ChangeNotifier {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  bool isLoginLoading = false;
  bool isBlockedUser = true;
  bool isVerifyLoading = false;
  String? errorMessage;
  bool isButtonEnabled = false;
  bool isOtpButtonEnabled = false;
  bool isLanguageSelected = false;
  NewAppLoginStatus newAppLoginStatus = NewAppLoginStatus.none;
  List<CategoryModel> getAllCategoryList = [];
  List<String> selectedCategories = [];
  List<LocationModel> getAllLocationList = [];
  List<String> selectedLocations = [];
  int? selectedLanguageId;

  void setSelectedLanguageId(int id) {
    selectedLanguageId = id;
    notifyListeners();
  }

  int remainingTime = 60;
  Timer? _timer;
  bool canResend = false;

  void startCountdown() {
    remainingTime = 60;
    canResend = false;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime > 0) {
        remainingTime--;
        notifyListeners();
      } else {
        _timer?.cancel();
        canResend = true;
        notifyListeners();
      }
    });
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void updateLoginStatus(NewAppLoginStatus status) {
    newAppLoginStatus = status;
    notifyListeners();
  }

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
          startCountdown();
          saveLoginState();
          EventRepo().addEvent({
            "loginType": "mobileNumber",
            "mobileNumber": phoneController.text,
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
        sp.setString("myReferralCode", response.data['user']['referral_code'].toString());
        sp.setString("myReferralLink", response.data['user']['refferal_link'].toString());
        sp.setString("userId", response.data['user']['id'].toString());
        sp.setString("userName", response.data['user']['name'].toString());
        
        // Device details API call moved to language selection

        sp.setString("userStatus", response.data['user']['status'].toString());
        
        // Always redirect to language selection regardless of new/existing user
        newAppLoginStatus = NewAppLoginStatus.language;
        saveLoginState();

        WebEngagePlugin.userLogin(response.data['user']['id'].toString());
        WebEngagePlugin.setUserPhone(phoneController.text.toString());
        mobileVerificationDetails(phoneController.text.toString(), true);

        GlobalVariables().userId = "";
        SharedPreferences preferences = await SharedPreferences.getInstance();
        saveUserid("");
        preferences.setString("userName", "User${phoneController.text.substring(phoneController.text.length - 4)}");
        preferences.setString("referralCode", "");
        EventRepo().addEvent({"otpStatus": "complete", "otp": otpController.text, "mobileNumber": phoneController.text, "createAt": DateTime.now().toString()}, "otp_verify");
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
      EventRepo().addEvent({"otpStatus": "fail", "otp": otpController.text, "mobileNumber": phoneController.text, "createAt": DateTime.now().toString()}, "otp_verify");
    } catch (e, st) {
      log("error  ${e.toString()}");
      log("error  ${st.toString()}");
      CustomToast.showErrorToast(msg: "Something went wrong");
      EventRepo().addEvent({"otpStatus": "fail", "otp": otpController.text, "mobileNumber": phoneController.text, "createAt": DateTime.now().toString()}, "otp_verify");
    } finally {
      isVerifyLoading = false;
      notifyListeners();
    }
  }

  bool isCatLoading = false;
  bool isCatSaveLoading = false;


  bool isLanguageLoading = false;
  List<LanguageModel> getAllLanguageList = [];

  Future getAllLanguages() async {
    isLanguageLoading = true;
    notifyListeners();
    try {
      print("Fetching languages...");
      Response response = await AuthenticationRepo().getAllLanguages(<String, dynamic>{
        "skip": 0,
        "limit": 100,
      });
      print("Languages response status: ${response.statusCode}");
      print("Languages response data type: ${response.data.runtimeType}");
      print("Languages response data: ${response.data}");
      
      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is String) {
          try {
            responseData = jsonDecode(responseData);
          } catch (e) {
            print("Languages decode error: $e");
          }
        }
        
        List data = responseData is List ? responseData : (responseData['data'] ?? []);
        print("Languages list length: ${data.length}");
        getAllLanguageList = data.map((e) => LanguageModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    } catch (e, st) {
      print("Error getAllLanguages --- ${e.toString()} --- ${st.toString()}");
    } finally {
      isLanguageLoading = false;
      notifyListeners();
    }
  }

  void saveLanguageAndProceed(BuildContext context, int languageId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setInt("selectedLanguageId", languageId);
    String langCode = 'en';
    try {
      final lang = getAllLanguageList.firstWhere((l) => l.id == languageId);
      langCode = lang.code ?? 'en';
      await preferences.setString("selectedLanguageCode", langCode);
    } catch (_) {}

    String token = "";
    if (Platform.isIOS) {
      token = await FirebaseMessaging.instance.getAPNSToken() ?? "";
    } else {
      token = await FirebaseMessaging.instance.getToken() ?? "";
    }
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");

    Provider.of<HomeProvider>(context, listen: false).sendDeviceDetailsApi(
        userId: userId ?? "0",
        deviceId: deviceId ?? "",
        fcmToken: token,
        lan: langCode,
    );

    newAppLoginStatus = NewAppLoginStatus.category;
    saveLoginState();
    getAllCategories();
    notifyListeners();
  }
  Future getAllCategories() async {
    isCatLoading = true;
    selectedCategories = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String langCode = preferences.getString("selectedLanguageCode") ?? "en";
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");

    Map<String, dynamic> body = {
      "lang": langCode,
      "device_id": deviceId ?? "",
    };

    if (userId != null && userId.isNotEmpty) {
      body["user_id"] = userId;
    }
    try {
      log("get all catttt$body");

      Response response = await AuthenticationRepo().getAllCategories(body);
      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is String) {
          try { responseData = jsonDecode(responseData); } catch (_) {}
        }
        List data = responseData is List ? responseData : (responseData['categories'] ?? responseData['data'] ?? []);
        
        getAllCategoryList = data
            .map(
              (e) {
                if (e['categoryNameTranslations'] != null && e['categoryNameTranslations'][langCode] != null) {
                  e['categoryName'] = e['categoryNameTranslations'][langCode];
                }
                return CategoryModel.fromJson(e);
              }
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
    List<int> selectedCategoryIds = getAllCategoryList.where((item) => selectedCategories.contains(item.categoryName.toString()) && item.categoryId != null).map((item) => item.categoryId as int).toList();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String result = selectedCategoryIds.toSet().join(',');
    String catNames = selectedCategories.toSet().join(',');
    preferences.setString("categoriesId", result);
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");

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
        EventRepo().addEvent({"listOfCategoriesIds": result, "listOfCategoriesNames": catNames, "updateStatus": "complete", "createAt": DateTime.now().toString()}, "update_categories");
      }
    } on DioException catch (e, st) {
      log("Dio error get all cat --- ${e.toString()} --- ${st.toString()}");
      EventRepo().addEvent({"listOfCategoriesIds": result, "listOfCategoriesNames": catNames, "updateStatus": "fail", "createAt": DateTime.now().toString()}, "update_categories");
    } catch (e, st) {
      log("Error get all cat --- ${e.toString()} --- ${st.toString()}");
      EventRepo().addEvent({"listOfCategoriesIds": result, "listOfCategoriesNames": catNames, "updateStatus": "fail", "createAt": DateTime.now().toString()}, "update_categories");
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
    String langCode = preferences.getString("selectedLanguageCode") ?? "en";
    String? deviceId = preferences.getString("deviceId");
    
    Map<String, dynamic> body = {
      "lang": langCode,
      "device_id": deviceId ?? "",
    };
    try {
      log("response.data.toString123");
      Response response = await AuthenticationRepo().getStateLocation(body);
      if (response.statusCode == 200) {
        var responseData = response.data;
        if (responseData is String) {
          try { responseData = jsonDecode(responseData); } catch (_) {}
        }
        List data = responseData is List ? responseData : (responseData['locations'] ?? responseData['data'] ?? []);
        
        getAllLocationList = data
            .map(
              (e) {
                if (e['locationNameTranslations'] != null && e['locationNameTranslations'][langCode] != null) {
                  e['locationName'] = e['locationNameTranslations'][langCode];
                } else if (e['stateNameTranslations'] != null && e['stateNameTranslations'][langCode] != null) {
                  e['stateName'] = e['stateNameTranslations'][langCode];
                }
                return LocationModel.fromJson(e);
              }
            )
            .toList();

        states = {for (var d in data) (d['locationId'] ?? d['stateId']): (d['locationName'] ?? d['stateName'])};

        selectedLocations = getAllLocationList.where((item) => item.isFollowed == true).map((item) => item.stateName.toString()).toSet().toList();
        log(getAllLocationList.first.stateName.toString());
        log("response.data.toString123 $selectedLocations");
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
    List<int> selectedCategoryIds = [];
    for (String stateName in selectedLocations) {
      var statesMatched = getAllLocationList.where((item) => item.stateName == stateName).toList();
      selectedCategoryIds.addAll(statesMatched.map((e) => e.stateId));
    }
    selectedCategoryIds = selectedCategoryIds.toSet().toList();
    log("Mapped state names to state IDs: ${selectedCategoryIds}");
    log("Selected State Names: $selectedLocations");
    String nameOfDistrict = selectedLocations.toSet().join(',');
    sendUserAttribute(nameOfDistrict);

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    String result = selectedCategoryIds.toSet().join(',');
    preferences.setString("locationId", result);
    preferences.setString("locationNames", nameOfDistrict);

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
        EventRepo().addEvent({"listOfLocationsIds": result, "listOfLocationsNames": nameOfDistrict, "updateStatus": "complete", "createAt": DateTime.now().toString()}, "update_locations");
      }
    } on DioException catch (e, st) {
      log("Dio error get all cat --- ${e.toString()} --- ${st.toString()}");
      EventRepo().addEvent({"listOfLocationsIds": result, "listOfLocationsNames": "", "updateStatus": "fail", "createAt": DateTime.now().toString()}, "update_locations");
    } catch (e, st) {
      log("Error get all cat --- ${e.toString()} --- ${st.toString()}");
      EventRepo().addEvent({"listOfLocationsIds": result, "listOfLocationsNames": "", "updateStatus": "fail", "createAt": DateTime.now().toString()}, "update_locations");
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
    newAppLoginStatus = NewAppLoginStatus.language;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("loginState", newAppLoginStatus.toString());
    preferences.setString("loginType", "skip");

    // Device details API call moved to language selection

    notifyListeners();
  }

  void setLogOutStatus(context, bool isLogout) async {
    newAppLoginStatus = isLogout ? NewAppLoginStatus.skip : NewAppLoginStatus.login;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.clear();
    preferences.setString("loginState", newAppLoginStatus.toString());

    isPageNavigation(context);
  }

  void sendEvent(pageName) async {
  }


}
