import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:chotanews/screens/home_screen/home_repo.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/global_variables_data.dart';
import '../home_screen/home_screen_model.dart';

class FlipProvider extends ChangeNotifier {
  List<HomeScreenModel> mainArticlesData = [];
  List<HomeScreenModel> districtArticlesData = [];
  int isTab = 0;
  bool isShowTopBottomView = true;

  void isTabChange(val) {
    isTab = val;
    notifyListeners();
  }

  void isShowTopBottomChange(val) {
    print("set change value $val");
    isShowTopBottomView = !val;
    notifyListeners();
  }

  int initialIndex = 0;

  void setIndex(val) {
    print("set Index $val");
    initialIndex = val;
    if (val == 0) {
      isShowTopBottomChange(isShowTopBottomView);
    } else if (val == 1) {
      isShowTopBottomChange(!isShowTopBottomView);
    }
  }

  bool isLoading = false;
  bool isRefresh = false;
  Future<void> getArticles({bool refresh = false, int index = 0}) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    String locationId = sp.getString("locationId") ?? "";
    String deviceId = GlobalVariables().deviceId ?? "";

    if (refresh==true) {
      isLoading = true;
      isRefresh = true;
      notifyListeners();
      final Map<String, dynamic> queryParams = isTab ==1?{
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        'homefeed': "1",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
        'locationIds': locationId,
      }:{
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
      };
      getData(queryParams);
      isLoading = false;
      notifyListeners();
    } else if (index != 0 && isTab == 0) {
      log("Home index $index");
      String? lastPostId = mainArticlesData[index].id.toString() ?? "";
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': lastPostId,
        'lpostid': "0",
        'includeHomePage': "0",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
      };
      log(queryParams.toString());
      getData(queryParams);
    } else if (index != 0 && isTab == 1) {
      log("State index");
      int last = index - 1;
      String? lastPostId = districtArticlesData[last].id.toString() ?? "";
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': lastPostId,
        'lpostid': "0",
        'homefeed': "1",
        'deviceid': deviceId,
        'platform': Platform.isIOS ? "apple" : "android",
        'locationIds': locationId,
      };
      log(queryParams.toString());
      getData(queryParams);
    } else {
      log("elseeeeee $index");
      final Map<String, dynamic> queryParams = isTab != 0
          ? {
              'userid': "1",
              'postid': "0",
              'lpostid': "0",
              'homefeed': "1",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
              'locationIds': locationId,
            }
          : {
              'userid': "1",
              'postid': "0",
              'lpostid': "0",
              'includeHomePage': "0",
              'deviceid': deviceId,
              'platform': Platform.isIOS ? "apple" : "android",
            };
      log(queryParams.toString());
      getData(queryParams);
    }
  }

  Future getData(queryParams) async {
    Response jsonString = await HomeRepo().getAllNewsFeeds(queryParams);
    print(jsonString.toString());
    List jsonList = jsonString.data['posts'];
    List<HomeScreenModel> data =
        jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();

    if (isTab == 0) {
      if(isRefresh){
        log("siva");
        mainArticlesController.add([]);
        mainArticlesData= [];

        notifyListeners();
      }
      mainArticlesData.addAll(data);
      mainArticlesController.add(mainArticlesData);
    } else if (isTab == 1) {
      if(isRefresh){
        log("siva");
        districtArticlesController.add([]);
        districtArticlesData= [];

        notifyListeners();
      }
      districtArticlesData.addAll(data);
      districtArticlesController.add(districtArticlesData);
    }

    isRefresh = false;
    notifyListeners();
  }


  final StreamController<List<HomeScreenModel>> districtArticlesController =
      StreamController<List<HomeScreenModel>>.broadcast();
  final StreamController<List<HomeScreenModel>> mainArticlesController =
      StreamController<List<HomeScreenModel>>.broadcast();

  Stream<List<HomeScreenModel>> get mainArticles =>
      mainArticlesController.stream;

  Stream<List<HomeScreenModel>> get districtArticles =>
      districtArticlesController.stream;


  @override
  void dispose() {
    districtArticlesController
        .close(); // ✅ Close stream when provider is disposed
    mainArticlesController.close(); // ✅ Close stream when provider is disposed
    super.dispose();
  }


  Future<void> takeScreenshotAndShare( article,screenshotController) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://chotanews.page.link', // Make sure this matches Firebase Console
      link: Uri.parse('https://chotanews.com/store?postId=${article.id}'), // Ensure this is a valid URL
      androidParameters: const AndroidParameters(
        packageName: 'com.chotanews', // Ensure this matches your AndroidManifest.xml
      ),
      iosParameters: const IOSParameters(
        bundleId: 'com.chotanewstelugu.app', // Ensure this matches Firebase Console
        appStoreId: '1631068092',
      ),
    );
    try {


        final ShortDynamicLink shortLink =
        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
        print("Short Link Created: ${shortLink.shortUrl}");
        // Share.share('${shortLink.shortUrl}');


      final image = await screenshotController.capture(
        pixelRatio: 3.0,
      );
      if (image != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = '${directory.path}/${article.id}.png';
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(image);

        // Share the image

        // InkWell(
        //     onTap: () {
        //
        //     },
        //     child: Text("www.google.com"));

        Share.shareXFiles([XFile(imageFile.path)], text: '${shortLink.shortUrl}');

      } else {
        CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
      }
    } catch (e) {
      CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
    }
  }


  Future getAllPostById(postId)async{
    try{
      Response response = await HomeRepo().getAllCommentByPost(postId);
      log(response.data.toString());
    }on DioException catch(e,st){

    }catch(e,st){

    }
  }

  Future addCommentPostById(postData,comment)async{
    Map<String, dynamic> body = {
      "UserId": "User${GlobalVariables().userId}",
      "PostId": postData.toString(),
      "Content": comment
    };
    log(body.toString());
    try {
      Response response = await HomeRepo().addCommentByPost(body);
      log(response.data.toString());

     if(response.statusCode==200){
       getAllPostById(postData.toString());
     }

    } on DioException catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api  catch ${st.toString()}");
    } catch (e, st) {
      log("Get News Api catch error ${st.toString()}");
      log("Get News Api catch ${st.toString()}");
    }
  }


  List<String> isLikeList = [];

  void isLikePost(val) async{
    log(val.toString());
    if (!isLikeList.contains(val)) {
      isLikeList.add(val);
      log(isLikeList.toString());
    }else{
      isLikeList.remove(val);
      log(isLikeList.toString());
    }
    notifyListeners(); // Notify listeners if using ChangeNotifier

  }
}




