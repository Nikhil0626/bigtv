import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tweetai/screens/settings_view/user_model.dart';
import 'package:tweetai/screens/x_handles_view/x_handle_provider.dart';
import '../../mixin_class/auth_mixin.dart';
import '../../utils/app_toasts.dart';
import '../auth/auth_repo.dart';
import '../dashboard_view/models/engage_tweet_model.dart';
import '../dashboard_view/models/words_model.dart';
import 'add_user_screen.dart';

class SettingProvider extends ChangeNotifier with AuthMixin {
  /// User Screen
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  bool addUserLoading = false;
  int userIds = 0;

  File? selectedFile;

  /// content screen
  final formKey = GlobalKey<FormState>();
  TextEditingController ageController = TextEditingController();
  TextEditingController engagementScoreController = TextEditingController();
  TextEditingController imageSizeController = TextEditingController();
  TextEditingController wordsController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  String? selectedTimePeriod;
  String? selectedEngagement;
  String? selectedImageSize;
  String? selectedWord;
  String? selectedTone;
  String? selectedAi;

  /// content update
  void ageUpdate(value) {
    selectedTimePeriod = value;
    notifyListeners();
  }

  void aiUpdate(value) {
    selectedAi = value;
    notifyListeners();
  }

  void engagementUpdate(value) {
    selectedEngagement = value;
    notifyListeners();
  }

  void imageSizeUpdate(value) {
    selectedImageSize = value;
    notifyListeners();
  }

  void wordUpdate(value) {
    log(value.toString());
    selectedWord = value;
    notifyListeners();
  }

  void toneUpdate(value) {
    selectedTone = value;
    notifyListeners();
  }

  /// search user
  void searchUser(String value, BuildContext context) {
    print(value);
    filteredList = getSettingsUserList.where((user) {
      final query = value.toLowerCase();
      return user.email!.toLowerCase().contains(query) ||
          user.firstName!.toLowerCase().contains(query) ||
          user.role!.toLowerCase().contains(query) ||
          user.phoneNumber!.toLowerCase().contains(query) ||
          user.name!.toLowerCase().contains(query) ||
          user.lastName!.toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }

  /// Get User Data
  bool isEngageTweetsLoading = false;
  bool addXHandleLoading = false;
  List<UsersModel> getSettingsUserList = [];
  List<UsersModel> filteredList = [];

  List<TimePeriodModel> timePeriodList = [];
  List<TimePeriodModel> aiList = [];
  List<TimePeriodModel> engageList = [];
  List<WordsModel> wordsList = [];
  List<ToneModel> tonesList = [];

  Future getSettingsUser({isCall = false}) async {
    isEngageTweetsLoading = true;
    if(isCall){
      notifyListeners();
    }
    try {
      Response response = await AppRepo().getSettingsUser();
      log(response.data.toString());
      if (response.statusCode == 200) {
        List data = response.data['users'];
        List age = response.data['age'];
        List engage = response.data['engage'];
        List words = response.data['words'];
        List tones = response.data['tones'];
        List ai = response.data['models'];

        getSettingsUserList = data
            .map(
              (e) => UsersModel.fromJson(e),
            )
            .toList();
        filteredList = getSettingsUserList;

        timePeriodList = age
            .map(
              (e) => TimePeriodModel.fromJson(e),
            )
            .toList();

        aiList = ai
            .map(
              (e) => TimePeriodModel.fromJson(e),
            )
            .toList();

        engageList = engage
            .map(
              (e) => TimePeriodModel.fromJson(e),
            )
            .toList();

        wordsList = words
            .map(
              (e) => WordsModel.fromJson(e),
            )
            .toList();

        tonesList = tones
            .map(
              (e) => ToneModel.fromJson(e),
            )
            .toList();

        isEngageTweetsLoading = false;
      }
    } on DioException catch (e, st) {
      log("dio error --- $st");
    } catch (e, st) {
      log("error --- $st");
    } finally {
      isEngageTweetsLoading = false;
      notifyListeners();
    }
  }

  Future<void> getSettingData() async {
    log("Fetching settings data...");
    try {
      Response response = await AppRepo().getSettingsId();
      log("Response: ${response.toString()}");

      if (response.statusCode == 200) {
        final settingsData = response.data;

        log("Processing setting: ${settingsData.toString()}");

        selectedTimePeriod = timePeriodList
            .where(
              (element) =>
                  element.id.toString() == settingsData['age_id'].toString(),
            )
            .first
            .name;
        log('Selected Time Period: $selectedTimePeriod');
        selectedEngagement = engageList
            .where(
              (element) =>
                  element.id.toString() ==
                  settingsData['engagement_id'].toString(),
            )
            .first
            .name;
        log('Selected Engagement: $selectedEngagement');
        selectedWord = wordsList
            .where(
              (element) =>
                  element.id.toString() == settingsData['word_id'].toString(),
            )
            .first
            .name;
        log('Selected Word: $selectedWord');
        selectedAi = aiList
            .where(
              (element) =>
                  element.id.toString() == settingsData['model_id'].toString(),
            )
            .first
            .name;
        log('Selected Word: $selectedAi');
        selectedTone = tonesList
            .where(
              (element) =>
                  element.id.toString() == settingsData['tone_id'].toString(),
            )
            .first
            .toneName;
        log('Selected Tone: $selectedTone');
      }
      log("All settings processed successfully.");
    } on DioException catch (dioError, stackTrace) {
      log("DioException occurred: ${dioError.toString()}");
      log("StackTrace: ${stackTrace.toString()}");
    } catch (error, stackTrace) {
      log("Exception occurred: ${error.toString()}");
      log("StackTraces: ${stackTrace.toString()}");
    } finally {
      notifyListeners();
    }
  }

  Future deleteUser(index, UsersModel item, context) async {
    addXHandleLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> body = {
        "ids": [item.id]
      };
      log(body.toString());
      Response response = await AppRepo().deleteUser(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds:500 ),(){
          CustomToast.showSuccessToast(msg: response.data['message']);
        });
        addXHandleLoading = false;
        getSettingsUser(isCall: true);
        notifyListeners();

      }
    } on DioException catch (e, st) {
      log(st.toString());
      log(e.toString());
    } catch (e, st) {
      log(st.toString());
      log(e.toString());
    } finally {
      addXHandleLoading = false;
      notifyListeners();
    }
  }

  Future statusChangeUser(id, context, String type) async {
    addXHandleLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> body = {
        "ids": [id],
        "path": false,
      };
      log(body.toString());
      Response response = await AppRepo().blockUser(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        getSettingsUser(isCall: true);
        addXHandleLoading = false;
        notifyListeners();
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds:500 ),(){
          CustomToast.showSuccessToast(msg: response.data['message']);
        });


      }
    } on DioException catch (e, st) {
      log(st.toString());
      log(e.toString());
    } catch (e, st) {
      log(st.toString());
      log(e.toString());
    } finally {
      addXHandleLoading = false;
      notifyListeners();
    }
  }

  Future unbBlockUser(id, context, String type) async {
    addXHandleLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> body = {
        "ids": [id],
        "path": type == "handle" ? true : false,
      };
      log(body.toString());
      Response response = await AppRepo().unbBlockUser(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        if (type == "handle") {
          await Provider.of<XHandleProvider>(context, listen: false)
              .getTwitterHandles();
        } else {
          await getSettingsUser(isCall: true);
        }
        addXHandleLoading = false;
        notifyListeners();
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds:500 ),(){
          CustomToast.showSuccessToast(msg: response.data['message']);
        });
      }
    } on DioException catch (e, st) {
      log(st.toString());
      log(e.toString());
    } catch (e, st) {
      log(st.toString());
      log(e.toString());
    } finally {
      addXHandleLoading = false;
      notifyListeners();
    }
  }

  Future addUser(BuildContext context) async {
    addUserLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "phonenumber": phoneNumberController.text
    };
    try {
      Response response = await AppRepo().addUser(body);

      if (response.statusCode == 200) {
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds:500 ),(){
          CustomToast.showSuccessToast(msg: response.data['message']);
        });
        addUserLoading = false;
        notifyListeners();
      }
    } on DioException catch (e, st) {
      log(e.toString());
      log(st.toString());
      CustomToast.showErrorToast(msg: "Something Went Wrong...");
      addUserLoading = false;
    } catch (e, st) {
      log(e.toString());
      log(st.toString());
      CustomToast.showErrorToast(msg: "Something Went Wrong...");
      addUserLoading = false;
    } finally {
      getSettingsUser(isCall: true);
    }
  }

  /// edit user details
  Future editUser(BuildContext context) async {
    addUserLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "first_name": firstNameController.text,
      "last_name": lastNameController.text,
      "email": emailController.text,
      "phonenumber": phoneNumberController.text
    };
    try {
      Response response = await AppRepo().editUser(body, userIds);

      log(response.data.toString());
      if (response.statusCode == 200) {
        loadUserData().then((e) async {
          if (userId.toString() == userIds.toString()) {
            SharedPreferences sharedPreferences =
                await SharedPreferences.getInstance();
            UserModel data = UserModel.fromJson(response.data['user']);
            await setUserData(
                data.name,
                data.email,
                data.profilePic,
                data.id.toString(),
                data.phoneNumber,
                data.lastName,
                data.firstName);
            sharedPreferences.setString(
                "userData", response.data['user'].toString());
          }
        });

        addUserLoading = false;
        await getSettingsUser(isCall: true);
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds:500 ),(){
          CustomToast.showSuccessToast(msg: response.data['message']);
        });
      }
    } on DioException catch (e, st) {
      CustomToast.showSuccessToast(msg: "Something Went Wrong...");
      addUserLoading = false;
      log(st.toString());
    } catch (e, st) {
      CustomToast.showSuccessToast(msg: "Something Went Wrong...");
      log(st.toString());
      addUserLoading = false;
    } finally {
      notifyListeners();
    }
  }

  /// update conf data
  Future updateConfigData(context) async {
    addUserLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "age_id": timePeriodList
          .where(
            (element) => element.name == selectedTimePeriod,
          )
          .first
          .id,
      "engagement_id": engageList
          .where(
            (element) => element.name == selectedEngagement,
          )
          .first
          .id,
      "word_id": wordsList
          .where(
            (element) => element.name == selectedWord,
          )
          .first
          .id,
      "tone_id": tonesList
          .where(
            (element) => element.toneName.toString() == selectedTone,
          )
          .first
          .id,
      "model": selectedAi,
      "model_id": aiList
          .where(
            (element) => element.name == selectedAi,
          )
          .first
          .id
    };

    log(body.toString());
    try {
      Response response = await AppRepo().updateWords(body);

      log(response.toString());
      if (response.statusCode == 200) {
        CustomToast.showSuccessToast(msg: response.data['message']);
        // await context.read<HomeProvider>().getEngageTweets();
      }

      notifyListeners();
    } on DioException catch (e, st) {
      log(e.toString());
      log(st.toString());
      addUserLoading = false;
    } catch (e, st) {
      log(e.toString());
      log(st.toString());
      addUserLoading = false;
    } finally {
      addUserLoading = false;
      notifyListeners();
    }
  }

  bool isEdit = false;

  get id => null;

  /// edit user data set
  Future editUserDate(
      uId, fName, lName, email, number, BuildContext context) async {
    isEdit = true;
    userIds = int.parse(uId.toString()) ?? 0;
    firstNameController.text = fName ?? "";
    lastNameController.text = lName ?? "";
    emailController.text = email ?? "";
    passwordController.text = "";
    phoneNumberController.text = number ?? "";

    log(userIds.toString());
    notifyListeners();
    var result = Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddUserScreen(
            screenType: "edit",
          ),
        ));

    return result;
  }

  /// clear setting pageData
  void clear() {
    firstNameController.clear();
    lastNameController.clear();
    phoneNumberController.clear();
    passwordController.clear();
    emailController.clear();
    selectedTimePeriod;
    selectedEngagement = null;
    selectedImageSize = null;
    selectedWord = null;
    selectedTone = null;
    addUserLoading = false;
    userIds = 0;
  }

  void pickAndUploadFile() async {
    await Permission.storage.request();
    var status = await Permission.photos.status;

    if (status.isDenied) {
      status = await Permission.photos.request();
    }
    log(userIds.toString());
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      String filePath = result.files.single.path!;
      selectedFile = File(filePath);
      notifyListeners();
      await uploadFile(filePath, userIds);
    } else {
      print("No file selected.");
    }
  }

  Future<void> uploadFile(String selectedFilePath, id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken = preferences.getString("accessToken");
    log(accessToken.toString());

    final uri = Uri.parse('https://twitter.signitivessoft.com/api/profilepic');

    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json, text/plain, */*',
        'Authorization': 'Bearer $accessToken',
        'Origin': 'https://bigtv.signitivessoft.com',
      });

    request.fields['id'] = id.toString();

    final filePath = selectedFilePath;
    request.files.add(await http.MultipartFile.fromPath(
      'profilepic',
      filePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    /// Send the request
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        print('Upload successful: $responseBody');
      } else {
        print('Failed to upload. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
  }
}
