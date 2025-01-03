import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tweetai/screens/articles_view/models/schedule_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_toasts.dart';
import '../articles_view/models/draft_model.dart';
import '../articles_view/models/send_model.dart';
import '../auth/auth_repo.dart';
import '../dashboard_view/models/engage_tweet_model.dart';
import '../dashboard_view/models/words_model.dart';
import '../x_tweete_view/x_tweet_model.dart';
import 'package:intl/intl.dart';

class HomeProvider extends ChangeNotifier {

  TextEditingController titleController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  TextEditingController homeSearchController = TextEditingController();

  int selectedPage = 0;
  late PageController pageController;
  final GlobalKey<CurvedNavigationBarState> bottomNavigationKey = GlobalKey();

  void initialPage() {
    pageController = PageController(initialPage: selectedPage);
  }

  void disposePage() {
    pageController.dispose();
  }

  void pageChange(index) {
    selectedPage = index;
    pageController.jumpToPage(index);
    notifyListeners();
  }

  bool isEngageTweetsLoading = false;
  bool tweetGenerateLoading = false;
  bool addXHandleLoading = false;

  bool isTitleGenLoading = false;

  List<EngageTweetModel> engageTweetsList = [];
  List<ZonesModel> zonesModelList = [];
  List<SendModel> publishedTweetsList = [];
  List<DraftModel> draftTweetsList = [];
  List<ScheduleModel> readyToPublishList = [];
  List<TimePeriodModel> ageList = [];
  List<TimePeriodModel> engagementListForDropDown = [];
  List<TimePeriodModel> gptListForDropDown = [];
  List<WordsModel> wordsList = [];


  Future getEngageTweets({bool filter = false}) async {
    isEngageTweetsLoading = true;
    if (filter) {
      notifyListeners();
    }
    Map<String, dynamic> body = filter
        ? {
            "time_period": ageList
                .where((element) =>
                    element.name.toString() == selectAge.toString())
                .first
                .id,
            "param ": "engage",
            "engagement_count": engagementListForDropDown
                .where((element) =>
                    element.name.toString() == selectEngagement.toString())
                .first
                .value,
            "engagement": engagementListForDropDown
                .where((element) =>
            element.name.toString() == selectEngagement.toString())
                .first
                .id
          }
        : {
          };

    log(body.toString());
    try {
      Response response = await AppRepo().getEngageTweets(body);
      if (response.statusCode == 200) {
        isFilterEnable = false;

        List data = response.data['data']['tweets'];
        List zones = response.data['data']['zones'];
        List publishedTweets = response.data['data']['publishedTweets'];
        List readyToPublish = response.data['data']['readytopublish'];
        List age = response.data['data']['age'];
        List engagement = response.data['data']['engagement'];
        List draft = response.data['data']['draft'];
        List models = response.data['data']['models'];
        List words = response.data['data']['words'];

        engageTweetsList = data
            .map(
              (e) => EngageTweetModel.fromJson(e),
            )
            .toList();
        filteredEngageList = engageTweetsList;
        zonesModelList = zones
            .map(
              (e) => ZonesModel.fromJson(e),
            )
            .toList();
        wordsList = words
            .map(
              (e) => WordsModel.fromJson(e),
            )
            .toList();
        publishedTweetsList = publishedTweets
            .map(
              (e) => SendModel.fromJson(e),
            )
            .toList();
        readyToPublishList = readyToPublish
            .map(
              (e) => ScheduleModel.fromJson(e),
            )
            .toList();
        ageList = age
            .map(
              (e) => TimePeriodModel.fromJson(e),
            )
            .toList();

        engagementListForDropDown = engagement
            .map(
              (e) => TimePeriodModel.fromJson(e),
            )
            .toList();

        draftTweetsList = draft
            .map(
              (e) => DraftModel.fromJson(e),
            )
            .toList();

        gptListForDropDown = models
            .map(
              (e) => TimePeriodModel.fromJson(e),
            )
            .toList();

        if (!filter) {

          ///GPT selection
          selectGPT = gptListForDropDown
              .where((element) =>
                  element.id.toString() ==
                  response.data['data']['selected_model_id'].toString())
              .first
              .name;
          log('Selected gpt: $selectGPT');

          ///Age selection
          selectAge = ageList
              .where((element) =>
                  element.id.toString() == response.data['data']['selected_age_id'].toString())
              .first
              .name;
          log('Selected age: $selectAge');


          /// Eng Selection
          selectEngagement = engagementListForDropDown
              .where((element) => element.id.toString() == response.data['data']['selected_enage_id'].toString())
              .first
              .name;
          log('Selected eng: $selectEngagement');
        }


        /// Tone Selection
        toneId = zonesModelList
            .where((element) =>
        element.toneName.toString() == response.data['data']['tone'].toString())
            .first
            .toneName;
        log('Selected Tone: $toneId');


      /// Words Selection
      numOfWords = wordsList
          .where((element) =>
      element.id.toString() == response.data['data']['selected_word_id'].toString())
          .first
          .name;
      log('Selected Words: $numOfWords');


        isEngageTweetsLoading = false;
      }
    } on DioException catch (e, st) {
      log("dio error --- ${st}");
      log("dio error --- ${e}");
    } catch (e, st) {
      log("error --- ${st}");
      log("error --- ${e}");
    } finally {
      isEngageTweetsLoading = false;
      notifyListeners();
    }
  }



  List<EngageTweetModel> filteredEngageList = [];

  /// search Home Tweets
  void searchTweetHome(String value, BuildContext context) {
    log(value);
    log(engageTweetsList.length.toString());
    filteredEngageList = engageTweetsList.where((user) {
      final query = value.toLowerCase();
      return user.profileName!.toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }





  var generateByAi = {};
  File? selectedFile;

  void pickAndUploadFile(id) async {
    await Permission.storage.request();

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png','jpg','jpeg',], // Customize file types
    );
    if (result != null) {
      String filePath = result.files.single.path!;
      selectedFile = File(filePath);
      notifyListeners();
      await uploadFile(filePath, id);
    } else {
      print("No file selected.");
    }
  }

  Future<void> uploadFile(String selectedFilePath, id) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? accessToken = preferences.getString("accessToken");
    final uri = Uri.parse('https://twitter.signitivessoft.com/api/upload-file');

    // Prepare the multipart request
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'Accept': 'application/json, text/plain, */*',
        'Authorization': 'Bearer $accessToken',
        'Origin': 'https://bigtv.signitivessoft.com',
      });

    request.fields['id'] = id.toString();

    final filePath = selectedFilePath;
    request.files.add(await http.MultipartFile.fromPath(
      'files[]',
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

  Future tweetGenerateByAi(
      tweetText, tweetId, BuildContext context, String type) async {
    tweetGenerateLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "id": tweetId,
      "tone_id": zonesModelList.where((e)=>e.toneName.toString() == toneId.toString()).first.id ,
      "text": tweetText ?? "",
      "type": type == "regenerate" ? "full" : "-",
      "static": false,
      "number_of_words":  wordsList.where((e)=>e.name.toString()==numOfWords.toString()).first.id,
      "language": "telugu",
    "model_id": gptListForDropDown.where((element) => element.name.toString()==selectGPT.toString(),).first.id,
      "model": selectGPT,
    };


    log(body.toString());
    try {
      Response response = await AppRepo().tweetGenerateByAi(body);

      if (response.statusCode == 200) {
        log(response.data.toString());
        generateByAi = response.data;
        titleController.text = generateByAi['title']??"";
        bodyController.text = generateByAi['text']??"";
        tweetGenerateLoading = false;
        notifyListeners();
      }
    } on DioException catch (e, st) {
      Navigator.pop(context);
      CustomToast.showErrorToast(msg: "Tweet not generating properly");
      log("dio error --- ${st}");
    } catch (e, st) {
      Navigator.pop(context);
      CustomToast.showErrorToast(msg: "Tweet not generating properly");

      log("error --- ${st}");
    } finally {
      tweetGenerateLoading = false;
      notifyListeners();
    }
  }

  bool isExpand = false;
  int? selectedIndex;

  void expandData(index) {
    selectedIndex = index;
    isExpand = !isExpand;
    notifyListeners();
  }

  String? selectAge;

  void updateAge(value) {
    log(value.toString());
    selectAge = value;
    notifyListeners();
  }

  void updateGPT(value) {
    selectGPT = value;
    notifyListeners();
  }

  void reSetFilter() {
    selectAge = null;
    selectEngagement = null;
  }

  String? selectEngagement;
  String? selectGPT;

  void updateEngagement(value) {
    selectEngagement = value;
    notifyListeners();
  }

  String? toneId;

  void toneChange(value) {
    toneId = value;
    notifyListeners();
  }

  String? numOfWords;

  void numOfWordsChange(value) {
    numOfWords = value;
    notifyListeners();
  }

  Future deleteTweet(
      id, int index, BuildContext context, String classType) async {
    isEngageTweetsLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "ids": [id]
    };

    log(body.toString());
    try {
      Response response = await AppRepo().deleteTweet(body);
      log(response.data.toString());

      if (response.statusCode == 200) {
         await getEngageTweets();
        log(response.statusCode.toString());
        notifyListeners();
        isEngageTweetsLoading = false;
        Navigator.pop(context);
      }
    } on DioException catch (e, st) {
      log(e.toString());
      log(st.toString());
    } catch (e, st) {
      log(e.toString());
      log(st.toString());
    } finally {
      notifyListeners();
    }
  }

  Future publishTweet(BuildContext context, tweetId, String tweetTitle, String tweetBody) async {
    tweetGenerateLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "id": int.parse(tweetId.toString()),
      "status": "publish",
      "text": tweetBody,
      "title": tweetTitle
    };

    log(body.toString());
    try {
      Response response = await AppRepo().publishTweet(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
       await getEngageTweets();
        CustomToast.showSuccessToast(msg: response.data['message']).then((value) =>  Navigator.pop(context));


      }
    } on DioException catch (e, st) {
      log(e.toString());
      log(st.toString());
    } catch (e, st) {
      log(e.toString());
      log(st.toString());
    } finally {
      tweetGenerateLoading = false;
      // Navigator.pop(context);
      notifyListeners();
    }
  }


  Future publish(BuildContext context, tweetId, ) async {
    isEngageTweetsLoading = true;
    notifyListeners();
    Map<String, dynamic> body = {
      "id": int.parse(tweetId.toString()),
    };

    log(body.toString());
    try {
      Response response = await AppRepo().publish(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
       await getEngageTweets();
        CustomToast.showSuccessToast(msg: response.data['message']).then((value) =>  Navigator.pop(context));

      }
    } on DioException catch (e, st) {
      log(e.toString());
      log(st.toString());
    } catch (e, st) {
      log(e.toString());
      log(st.toString());
    } finally {
      isEngageTweetsLoading = false;
      // Navigator.pop(context);
      notifyListeners();
    }
  }

  Future tweetReGenerateByAi(id, title, name) async {
    // if (name == "title") {
    //   isTitleGenLoading = true;
    // } else {
      tweetGenerateLoading = true;
    // }
    notifyListeners();

    Map<String, dynamic> body = {
      "id": id,
      "tone_id": zonesModelList.where((element) => element.toneName.toString() == toneId,).first.id ?? 4,
      "text": title ?? "",
      "type": name,
      "static": name=="title"?true:false,
      "number_of_words": getGptValue(selectGPT),
      "language": "telugu",
      "model":selectGPT,
      "model_id":gptListForDropDown.where((element) => element.name.toString() == selectGPT,).first.id,
    };
    log(body.toString());
    try {
      Response response = await AppRepo().tweetGenerateByAi(body);

      if (response.statusCode == 200) {
        log(response.data.toString());
        generateByAi = response.data;
        titleController.text = generateByAi['title'];
        bodyController.text = generateByAi['text'];
        notifyListeners();
      }
    } on DioException catch (e, st) {
      log("dio error --- ${st}");
    } catch (e, st) {
      log("error --- ${st}");
    } finally {
      // if (name == "title") {
      //   isTitleGenLoading = false;
      // } else {
        tweetGenerateLoading = false;
      // }
      notifyListeners();
    }
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text)).then((_) {
      CustomToast.showSuccessToast(msg: 'Copied to Clipboard');
    });
  }

  String formatTimeDifference(String inputTime, {bool isTweets = false}) {
    print("Input Time: $inputTime");

    final now = DateTime.now().add(Duration(minutes: -330)); // Adjust time zone
    DateFormat inputFormat = DateFormat("MMM d, yyyy h:mm a"); // Format for tweets
    DateFormat format = DateFormat('yyyy-MM-dd HH:mm:ss'); // Generic format

    // Parse the date with proper error handling
    DateTime date;
    try {
      if (inputTime == null || inputTime.trim().isEmpty) {
        date = now; // Fallback to 'now' if input is null
      } else {
        date = isTweets ? inputFormat.parse(inputTime) : format.parse(inputTime);
      }
    } catch (e) {
      // Handle invalid date format
      print("Error parsing date: $e");
      date = now; // Fallback to 'now' if parsing fails
    }

    // Calculate the time difference
    final difference = now.difference(date);

    // Format the difference into human-readable format
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago'; // Seconds ago
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago'; // Minutes ago
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago'; // Hours ago
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago'; // Days ago
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w ago'; // Weeks ago
    } else {
      return DateFormat('dd MMM yyyy').format(date); // Date format
    }
  }

  bool isFilterEnable = false;
  bool isFilterEnableXTweet = false;

  void filterEnable({String screenName="Viral Tweets"}) {
    if(screenName == "XTweet"){
      isFilterEnable = false;
      isFilterEnableXTweet =!isFilterEnableXTweet;
      notifyListeners();

    }else{
      isFilterEnableXTweet = false;
      isFilterEnable = !isFilterEnable;
      notifyListeners();


    }
  }

  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  String? getGptValue(String? selectGPT) {
    log(numOfWords.toString());

    switch (selectGPT) {
      case "GPT":
        return wordsList.where(
    (element) => element.name.toString()== numOfWords, ).first.gpt.toString();
      case "Llama":
        return wordsList.where(
              (element) => element.name.toString()== numOfWords, ).first.llama.toString();
      case "Gemini":
        return wordsList.where(
              (element) => element.name.toString()== numOfWords, ).first.gemini.toString();
      default:
        return null;
    }
  }

}

String formatCount(int count) {
  if (count < 1000) {
    return count.toString();
  } else if (count < 1000000) {
    return '${(count / 1000).toStringAsFixed(1).replaceAll('.0', '')}k';
  } else {
    return '${(count / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M';
  }
}
