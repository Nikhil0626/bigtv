import 'dart:developer';

import 'package:chotanews/globel_keys/global_variables_data.dart';
import 'package:chotanews/screens/home_screen/home_event.dart';
import 'package:chotanews/screens/home_screen/home_repo.dart';
import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:chotanews/screens/home_screen/home_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeBloc() : super(InitialHomeScreenState()) {
    List<HomeScreenModel> getAllPosts = [];
    int firstIndex = 0;
    bool isMenuChange = false;
     String pageType = "";
     on<MenuChange>((event, emit) async {
       isMenuChange=!isMenuChange;
       emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: "",firstIndex: firstIndex,isChange: isMenuChange));
     });

    on<GetAllNewsFeed>((event, emit) async {
      emit(LoadingHomeScreenState());

    String  deviceId =  GlobalVariables().deviceId??"";
    String  platForm =  GlobalVariables().platForm??"";

      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': "0",
        'lpostid': "0",
        'includeHomePage': "1",
        // 'hasAds': true,
        // 'isByNotification': false,
        'deviceid': deviceId,
        'platform': platForm,
        // 'homefeed': "1",
        'locationIds': '64',
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
        emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: "",firstIndex: 1,isChange: isMenuChange));
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

    on<GetFollowingNewsFeed>((event,emit)async{
      try {
        Response response = await HomeRepo().getAllNewsFeeds({});
        List data = response.data['posts'];
        getAllPosts = data
            .map(
              (e) => HomeScreenModel.fromJson(e),
        )
            .toList();
        emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: pageType,firstIndex:firstIndex,isChange: isMenuChange ));
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

    on<OnSwipeCard>((event, emit) async{
      pageType = getAllPosts[event.currentIndex].type.toString();
      firstIndex = event.currentIndex;

      log("page index update in each swipe${getAllPosts[firstIndex].id}");
      emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: pageType,firstIndex: firstIndex,isChange: isMenuChange));

      if(getAllPosts.length-1==firstIndex){
        emit(LoadingHomeScreenState());
        log("page index update in lase ");
        int last = getAllPosts.length-1;
        String? lastPostId = getAllPosts[last].id.toString()??"";
        String  deviceId =  GlobalVariables().deviceId??"";
        String  platForm =  GlobalVariables().platForm??"";
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


        emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: pageType,firstIndex: firstIndex,isChange: isMenuChange));
      }
    });

    on<OnSwipeEndCard>((event, emit) {
      log(event.data.toString());
    });
  }
}
