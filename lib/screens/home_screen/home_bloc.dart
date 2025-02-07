import 'dart:developer';

import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:chotanews/screens/home_screen/home_event.dart';
import 'package:chotanews/screens/home_screen/home_repo.dart';
import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_state.dart';
import 'package:chotanews/screens/videos_main/tab_screen.dart';
import 'package:dio/dio.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/app_router.dart';

class HomeBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeBloc() : super(InitialHomeScreenState()) {
    List<HomeScreenModel> getAllPosts = [];
    int firstIndex = 0;
    bool isMenuChange = false;
    bool isChange = true;
    String pageType = "";



    on<MenuChange>((event, emit) async {
      isMenuChange = !isMenuChange;
      emit(SuccessHomeScreenState(
          getAllHomeScreenNews: getAllPosts,
          pageType: "",
          firstIndex: firstIndex,
          isChange: isMenuChange));
    });

    on<GetAllNewsFeed>((event, emit) async {
      emit(LoadingHomeScreenState());

      String deviceId = GlobalVariables().deviceId ?? "";
      String platForm = GlobalVariables().platForm ?? "";

      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        'includeHomePage': "0",
        'isByNotification': "false",
        'deviceid': deviceId,
        'platform': platForm,
        'homefeed': "0",
        // 'hasAds': true,
        // 'locationIds': '21,22,43,44,55,64',
        // "debugMode": true
      };
      log(queryParams.toString());
      try {
        Response response = await HomeRepo().getAllNewsFeeds(queryParams);
        List data = response.data['posts'];
        getAllPosts = data
            .map(
              (e) => HomeScreenModel.fromJson(e),
            )
            .toList();
        emit(SuccessHomeScreenState(
            getAllHomeScreenNews: getAllPosts,
            pageType: "",
            firstIndex: 1,
            isChange: isMenuChange));
      } on DioException catch (e, st) {
        emit(ErrorHomeScreenState(getHomeScreenError: ""));
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api  catch ${st.toString()}");
      } catch (e, st) {
        emit(ErrorHomeScreenState(getHomeScreenError: "No News Feeds Available"));
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api catch ${st.toString()}");
      }
    });

    on<GetAllDistrictFeed>((event, emit) async {
      emit(LoadingHomeScreenState());
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      String locationId = sharedPreferences.getString(
            "locationId",
          ) ??
          "";
      log(locationId);
      String deviceId = GlobalVariables().deviceId ?? "";
      String platForm = GlobalVariables().platForm ?? "";

      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        'includeHomePage': "0",
        // 'hasAds': true,
        // 'isByNotification': false,
        'deviceid': deviceId,
        'platform': platForm,
        'homefeed': "0",
        'locationIds': locationId,
        // "debugMode": true
      };
      try {
        Response response = await HomeRepo().getAllNewsFeeds(queryParams);
        List data = response.data['posts'];
        getAllPosts = data
            .map(
              (e) => HomeScreenModel.fromJson(e),
            )
            .toList();
        emit(SuccessHomeScreenState(
            getAllHomeScreenNews: getAllPosts,
            pageType: "",
            firstIndex: 1,
            isChange: isMenuChange));
      } on DioException catch (e, st) {
        emit(ErrorHomeScreenState(getHomeScreenError: ""));
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api  catch ${st.toString()}");
      } catch (e, st) {
        emit(ErrorHomeScreenState(getHomeScreenError: ""));
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api catch ${st.toString()}");
      }
    });

    on<GetFollowingNewsFeed>((event, emit) async {
      try {
        Response response = await HomeRepo().getAllNewsFeeds({});
        List data = response.data['posts'];
        getAllPosts = data
            .map(
              (e) => HomeScreenModel.fromJson(e),
            )
            .toList();
        emit(SuccessHomeScreenState(
            getAllHomeScreenNews: getAllPosts,
            pageType: pageType,
            firstIndex: firstIndex,
            isChange: isMenuChange));
      } on DioException catch (e, st) {
        emit(ErrorHomeScreenState(getHomeScreenError: ""));
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api  catch ${st.toString()}");
      } catch (e, st) {
        emit(ErrorHomeScreenState(getHomeScreenError: ""));
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api catch ${st.toString()}");
      }
    });

    on<OnSwipeCard>((event, emit) async {
      pageType = getAllPosts[event.index].type.toString();
      firstIndex = event.index;

      log("page index update in each swipe${getAllPosts[firstIndex].id}");
      emit(SuccessHomeScreenState(
          getAllHomeScreenNews: getAllPosts,
          pageType: pageType,
          firstIndex: firstIndex,
          isChange: isMenuChange));

      if (getAllPosts.length - 1 == firstIndex) {
        emit(LoadingHomeScreenState());
        log("page index update in lase ");
        int last = getAllPosts.length - 1;
        String? lastPostId = getAllPosts[last].id.toString() ?? "";
        String deviceId = GlobalVariables().deviceId ?? "";
        String platForm = GlobalVariables().platForm ?? "";
        final Map<String, dynamic> queryParams = {
          'userid': "1",
          'postid': lastPostId,
          'lpostid': "0",
          'includeHomePage': "1",
          // 'hasAds': false,
          // 'isByNotification': false,
          'deviceid': deviceId,
          'platform': platForm,
          // 'homefeed': "1",
          'locationIds': '64',
        };
        log(getAllPosts.last.id.toString());

        log(queryParams.toString());
        Response response = await HomeRepo().getAllNewsFeeds(queryParams);
        List data = response.data['posts'];
        log(data.toString());
        getAllPosts = data
            .map(
              (e) => HomeScreenModel.fromJson(e),
            )
            .toList();

        emit(SuccessHomeScreenState(
            getAllHomeScreenNews: getAllPosts,
            pageType: pageType,
            firstIndex: firstIndex,
            isChange: isMenuChange));
      }
    });

    on<OnSwipeEndCard>((event, emit) {
      log(event.data.toString());
    });

    on<SendNewsToSocialMedia>((event, emit) async {
      final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: 'https://chotanews.page.link', // Make sure this matches Firebase Console
        link: Uri.parse('https://chotanews.com/store?postId=${event.id}'), // Ensure this is a valid URL
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
        Share.share('${shortLink.shortUrl}');
      } catch (e) {
        print("Error creating dynamic link: $e");
      }


      // try {
      //   var dynamicUrl =
      //       await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      //   print('Short Dynamic Link: $dynamicUrl');
      //   Share.share('$dynamicUrl');
      // } catch (e, st) {
      //   print('Error generating dynamic link: $st');
      //   print('Error generating dynamic link: $e');
      // }
    });

    on<MenuItemClickEvent>((event, emit) async {
      if (event.currentMenuItem == "హోమ్") {
        Navigator.pushNamed(event.context, RoutesManager.homeScreen);
      } else if (event.currentMenuItem == "లొకేషన్స్") {
        Navigator.pushNamed(
            event.context, RoutesManager.districtSelectionScreen,
            arguments: {
              "className": "Home",
            });
      } else {
        Navigator.push(
          event.context,
          MaterialPageRoute(
            builder: (context) => const GetAllMenuItemScreen(),
          ),
        );
      }
    });

    on<CommentByPost>((event, emit) async {
      emit(LoadingHomeScreenState());

      final Map<String, dynamic> body = {};
      try {
        Response response = await HomeRepo().addCommentByPost(body);
        List data = response.data['posts'];
        getAllPosts = data
            .map(
              (e) => HomeScreenModel.fromJson(e),
            )
            .toList();
        emit(SuccessHomeScreenState(
            getAllHomeScreenNews: getAllPosts,
            pageType: "",
            firstIndex: 1,
            isChange: isMenuChange));
      } on DioException catch (e, st) {
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api  catch ${st.toString()}");
      } catch (e, st) {
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api catch ${st.toString()}");
      }
    });
    on<LikeByPost>((event, emit) async {
      emit(LoadingHomeScreenState());
      String deviceId = GlobalVariables().deviceId ?? "";
      String userId = GlobalVariables().userId ?? "";
      final Map<String, dynamic> body = {
        "CategoryId": "",
        "CreatedAt": DateTime.now().toString(),
        "DeviceId": deviceId,
        "IsLiked": event.isLike,
        "PostId": event.postId,
        "UserId": userId.toString()
      };
      try {
        Response response = await HomeRepo().likeByPost(body);
        if(response.statusCode==200){
          emit(IsLike(isLike: true));
        }
      } on DioException catch (e, st) {
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api  catch ${st.toString()}");
      } catch (e, st) {
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api catch ${st.toString()}");
      }
    });
  }


}
