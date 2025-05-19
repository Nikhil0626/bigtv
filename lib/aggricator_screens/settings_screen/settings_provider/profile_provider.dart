import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../../services/base_urls.dart';

class ProfileProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController monthController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  bool isButtonEnabled = false;
  var profileData;
  File? selectedFile;
  bool isMainLoading = false;

  Future getProfile() async {
    isMainLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    // String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId,
    };

    try {
      Response response = await SettingsRepo().getProfile(body);
      log("data -- ${response.data}");
      if (response.statusCode == 200) {
        profileData = response.data;
        phoneController.text = response.data['profile']['mobileNumber']??"";


        String dob = response.data['profile']['dob'].toString();
       List data = dob.split("-");
        dayController.text = data[2]??"";
        monthController.text = data[1]??"";
        yearController.text = data[0]??"";
        nameController.text = response.data['profile']['name']??"";
        uploadImageUrl = response.data['profile']['photo']??"";
        notifyListeners();
        log("Like posted successfully: ${response.data}");
      } else {
        log("Failed to post like: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {

      log("Unexpected error while posting like: ${e.toString()} ---- ${st.toString()}");
    } finally {
    Future.delayed(Duration(seconds: 1),() {
      isMainLoading = false;
      notifyListeners();

    },);
    }
  }
  bool isProfileUpdate = false;

  Future postProfile() async {
    isProfileUpdate = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? userId = preferences.getString("userId");

    Map<String, dynamic> body = {
      "user_id":int.parse(userId.toString()),
      "name":nameController.text.toString(),
      "dob":'${yearController.text}-${monthController.text}-${dayController.text}',
      "photo_url":uploadImageUrl.toString(),
    };
    log('body $body');
    try {
      Response response = await SettingsRepo().postProfile(body);
      if (response.statusCode == 200) {
        CustomToast.showSuccessToast(msg: "Profile data updated");
        log("Like posted successfully: ${response.data}");
      } else {
        CustomToast.showErrorToast(msg: "${response.data['detail']}");
        log("Failed to post like: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      CustomToast.showSuccessToast(msg: "Profile data not updated");
      log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      CustomToast.showSuccessToast(msg: "Profile data not updated");
      log("Unexpected error while posting like: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isProfileUpdate = false;
      notifyListeners();
    }
  }


  bool isProfileLoading = false;

  void pickAndUploadFile() async {
    SharedPreferences sp =await SharedPreferences.getInstance();
    String? userId = sp.getString('userId');
    await Permission.storage.request();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'png',
        'jpg',
        'jpeg',
      ], // Customize file types
    );
    if (result != null) {
      String filePath = result.files.single.path!;
      selectedFile = File(filePath);
      log(selectedFile.toString());
      notifyListeners();
      await uploadFile(filePath, userId);
    } else {
      print("No file selected.");
    }
  }

  String uploadImageUrl = '';
  Future<void> uploadFile(String selectedFilePath, id) async {
    isProfileLoading = true;
    final uri = Uri.parse('${BaseUrls.baseUrlAwsDev}/upload_image');

    // Prepare the multipart request
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json, text/plain, */*',
        'Origin': BaseUrls.baseUrlAwsDev,
      });

    request.fields['id'] = id.toString();

    final filePath = selectedFilePath;
    request.files.add(await http.MultipartFile.fromPath(
      'profile_image',
      filePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    /// Send the request
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        print('Upload successful: ${response.toString()}');
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseBody);
        uploadImageUrl = decodedResponse['image_url'];
        print('Upload successful: $responseBody');
      } else {
        print('Failed to upload. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
    finally{
      isProfileLoading = false;
      notifyListeners();
    }
  }
}
