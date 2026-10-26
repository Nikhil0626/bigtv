import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chotanews/aggricator_screens/settings_screen/settings_repository/settings_repo.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:chotanews/analytics/analytics_service.dart';
import 'package:chotanews/analytics/models/analytics_event_name.dart';


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

  void setDob(DateTime dt) {
    dayController.text = dt.day.toString().padLeft(2, '0');
    monthController.text = dt.month.toString().padLeft(2, '0');
    yearController.text = dt.year.toString().padLeft(4, '0');
    notifyListeners();
  }

  void _clearDobControllers() {
    dayController.text = "";
    monthController.text = "";
    yearController.text = "";
  }

  void _parseAndPopulateDob(dynamic rawDob) {
    if (rawDob == null) {
      _clearDobControllers();
      return;
    }
    String dobStr = rawDob.toString().trim();
    if (dobStr.isEmpty || dobStr.toLowerCase() == "null" || dobStr == "--") {
      _clearDobControllers();
      return;
    }

    // Strip time portion if present (e.g. 1995-05-20T00:00:00 or 1995-05-20 00:00:00)
    if (dobStr.contains('T')) {
      dobStr = dobStr.split('T').first.trim();
    } else if (dobStr.contains(' ')) {
      dobStr = dobStr.split(' ').first.trim();
    }

    // Try DateTime.tryParse (handles ISO YYYY-MM-DD)
    final parsed = DateTime.tryParse(dobStr);
    if (parsed != null) {
      dayController.text = parsed.day.toString().padLeft(2, '0');
      monthController.text = parsed.month.toString().padLeft(2, '0');
      yearController.text = parsed.year.toString().padLeft(4, '0');
      return;
    }

    // Try splitting by '-' or '/'
    final separator = dobStr.contains('-') ? '-' : (dobStr.contains('/') ? '/' : null);
    if (separator != null) {
      final parts = dobStr.split(separator).map((e) => e.trim()).toList();
      if (parts.length == 3) {
        final p0 = int.tryParse(parts[0]);
        final p1 = int.tryParse(parts[1]);
        final p2 = int.tryParse(parts[2]);

        if (p0 != null && p1 != null && p2 != null) {
          // Check if parts[0] is year (e.g. 1995-05-15)
          if (parts[0].length == 4 || p0 > 1000) {
            yearController.text = p0.toString().padLeft(4, '0');
            monthController.text = p1.toString().padLeft(2, '0');
            dayController.text = p2.toString().padLeft(2, '0');
            return;
          }
          // Check if parts[2] is year (e.g. 15-05-1995)
          else if (parts[2].length == 4 || p2 > 1000) {
            dayController.text = p0.toString().padLeft(2, '0');
            monthController.text = p1.toString().padLeft(2, '0');
            yearController.text = p2.toString().padLeft(4, '0');
            return;
          }
        }
      }
    }

    _clearDobControllers();
  }

  String? _formatDateStringToYmd(String raw) {
    String dobStr = raw.trim();
    if (dobStr.isEmpty || dobStr.toLowerCase() == "null" || dobStr == "--") {
      return null;
    }
    if (dobStr.contains('T')) {
      dobStr = dobStr.split('T').first.trim();
    } else if (dobStr.contains(' ')) {
      dobStr = dobStr.split(' ').first.trim();
    }
    final parsed = DateTime.tryParse(dobStr);
    if (parsed != null) {
      return '${parsed.year.toString().padLeft(4, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    }
    final separator = dobStr.contains('-') ? '-' : (dobStr.contains('/') ? '/' : null);
    if (separator != null) {
      final parts = dobStr.split(separator).map((e) => e.trim()).toList();
      if (parts.length == 3) {
        final p0 = int.tryParse(parts[0]);
        final p1 = int.tryParse(parts[1]);
        final p2 = int.tryParse(parts[2]);
        if (p0 != null && p1 != null && p2 != null) {
          if (parts[0].length == 4 || p0 > 1000) {
            return '${p0.toString().padLeft(4, '0')}-${p1.toString().padLeft(2, '0')}-${p2.toString().padLeft(2, '0')}';
          } else if (parts[2].length == 4 || p2 > 1000) {
            return '${p2.toString().padLeft(4, '0')}-${p1.toString().padLeft(2, '0')}-${p0.toString().padLeft(2, '0')}';
          }
        }
      }
    }
    return null;
  }

  Future getProfile() async {
    isMainLoading = true;
    notifyListeners();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId,
    };

    try {
      Response response = await SettingsRepo().getProfile(body);
      log("profile data -- ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        profileData = response.data;
        final profile = response.data['profile'];
        if (profile is Map) {
          phoneController.text = profile['mobileNumber']?.toString() ?? "";
          nameController.text = profile['name']?.toString() ?? "";
          uploadImageUrl = profile['photo']?.toString() ?? "";

          final rawDob = profile['dob'];
          _parseAndPopulateDob(rawDob);
        }
        notifyListeners();
        log("Profile fetched successfully: ${response.data}");
      } else {
        log("Failed to get profile: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      log("Dio error while fetching profile: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while fetching profile: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isMainLoading = false;
      notifyListeners();
    }
  }

  bool isProfileUpdate = false;

  Future postProfile() async {
    final String name = nameController.text.trim();
    if (name.isEmpty) {
      CustomToast.showErrorToast(msg: "Please enter your name");
      return;
    }

    final String dayStr = dayController.text.trim();
    final String monthStr = monthController.text.trim();
    final String yearStr = yearController.text.trim();

    final bool hasAnyDobField = dayStr.isNotEmpty || monthStr.isNotEmpty || yearStr.isNotEmpty;
    final bool hasAllDobFields = dayStr.isNotEmpty && monthStr.isNotEmpty && yearStr.isNotEmpty;

    String? formattedDob;

    if (hasAnyDobField) {
      if (!hasAllDobFields) {
        CustomToast.showErrorToast(msg: "Please enter complete date of birth");
        return;
      }

      final int? day = int.tryParse(dayStr);
      final int? month = int.tryParse(monthStr);
      final int? year = int.tryParse(yearStr);

      if (day == null || month == null || year == null ||
          day < 1 || day > 31 ||
          month < 1 || month > 12 ||
          year < 1900 || year > DateTime.now().year) {
        CustomToast.showErrorToast(msg: "Please enter a valid date of birth");
        return;
      }

      try {
        final date = DateTime(year, month, day);
        if (date.year != year || date.month != month || date.day != day) {
          CustomToast.showErrorToast(msg: "Please enter a valid date of birth");
          return;
        }
        if (date.isAfter(DateTime.now())) {
          CustomToast.showErrorToast(msg: "Date of birth cannot be in the future");
          return;
        }
      } catch (_) {
        CustomToast.showErrorToast(msg: "Please enter a valid date of birth");
        return;
      }

      formattedDob = '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
      dayController.text = day.toString().padLeft(2, '0');
      monthController.text = month.toString().padLeft(2, '0');
      yearController.text = year.toString().padLeft(4, '0');
    } else {
      // If user hasn't filled DOB fields, check if there was already an existing valid DOB in profileData
      final existingDob = profileData != null && profileData['profile'] != null
          ? profileData['profile']['dob']?.toString()
          : null;
      if (existingDob != null &&
          existingDob.trim().isNotEmpty &&
          existingDob.trim() != "null" &&
          existingDob.trim() != "--") {
        formattedDob = _formatDateStringToYmd(existingDob);
      }
    }

    isProfileUpdate = true;
    notifyListeners();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");

    Map<String, dynamic> body = {
      "user_id": int.tryParse(userId.toString()) ?? userId,
      "name": name,
      "dob": formattedDob,
      "photo_url": uploadImageUrl.toString(),
    };
    log('postProfile body: $body');

    try {
      Response response = await SettingsRepo().postProfile(body);
      if (response.statusCode == 200) {
        AnalyticsService.instance.track(AnalyticsEventName.userProfileUpdate, properties: {
          'updated_fields': ['name', if (formattedDob != null) 'dob', 'photo_url'],
        });
        if (profileData != null && profileData['profile'] != null) {
          profileData['profile']['name'] = name;
          if (formattedDob != null) {
            profileData['profile']['dob'] = formattedDob;
          }
          profileData['profile']['photo'] = uploadImageUrl.toString();
        }
        preferences.setString("userName", name);
        CustomToast.showSuccessToast(msg: "Profile data updated");
        log("Profile updated successfully: ${response.data}");
      } else {
        final errorMsg = response.data is Map && response.data['detail'] != null
            ? response.data['detail'].toString()
            : "Failed to update profile";
        CustomToast.showErrorToast(msg: errorMsg);
        log("Failed to update profile: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      String errorMsg = "Profile data not updated";
      if (e.response?.data is Map && e.response?.data['detail'] != null) {
        errorMsg = e.response!.data['detail'].toString();
      }
      CustomToast.showErrorToast(msg: errorMsg);
      log("Dio error while updating profile: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      CustomToast.showErrorToast(msg: "Profile data not updated");
      log("Unexpected error while updating profile: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isProfileUpdate = false;
      notifyListeners();
    }
  }

  Future deleteAccount() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String? userId = preferences.getString("userId");
Map<String,dynamic> body = {
  "user_id": userId
};

    try {
      Response response = await SettingsRepo().deleteAccount(body);
      if (response.statusCode == 200) {
        CustomToast.showSuccessToast(msg: "Your account will be permanently delete within 48 hours");
        log("Like posted successfully: ${response.data}");
      }
    } on DioException catch (e, st) {
      log("Like posted successfully:$e --- $st");
    } catch (e, st) {
      CustomToast.showSuccessToast(msg: "Profile data not updated");
      log("Unexpected error while posting like: ${e.toString()} ---- ${st.toString()}");
    } finally {

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
      debugPrint("No file selected.");
    }
  }

  String uploadImageUrl = '';
  Future<void> uploadFile(String selectedFilePath, id) async {
    isProfileLoading = true;
    final uri = Uri.parse('${BaseUrls.baseUrlAwsDev}/upload_image');

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

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        log('Upload successful: ${response.toString()}');
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = json.decode(responseBody);
        uploadImageUrl = decodedResponse['image_url'];
        log('Upload successful: $responseBody');
      } else {
        log('Failed to upload. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error uploading file: $e');
    }
    finally{
      isProfileLoading = false;
      notifyListeners();
    }
  }
}
