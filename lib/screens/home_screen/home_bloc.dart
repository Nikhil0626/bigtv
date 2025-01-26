import 'dart:developer';

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
     String pageType = "";
    int lastIndex = 0;

    on<GetAllNewsFeed>((event, emit) async {
      emit(LoadingHomeScreenState());
      final Map<String, dynamic> queryParams = {
        'userid': "1",
        'postid': "0",
        'lpostid': "1",
        'includeHomePage': "1",
        'hasAds': true,
        'isByNotification': false,
        'deviceid': '993f0e149b5bed89',
        'platform': 'ios',
        'homefeed': "1",
        'locationIds': 'undefined',
      };
      try {
        Response response = await HomeRepo().getAllNewsFeeds(queryParams);
        List data = response.data['posts'];
        getAllPosts = data
            .map(
              (e) => HomeScreenModel.fromJson(e),
            )
            .toList();
        emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: "",firstIndex: 1));
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
        emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: pageType,firstIndex:firstIndex ));
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

      log("page index update in each swipe");
      emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: pageType,firstIndex: firstIndex));

      if(getAllPosts.length-1==firstIndex){
        emit(LoadingHomeScreenState());
        log("page index update in lase ");

        int last = getAllPosts.length-1;
        final Map<String, dynamic> queryParams = {
          'userid': "1",
          'postid': 3523151,
          'lpostid': "0",
          'includeHomePage': "1",
          'hasAds': false,
          'isByNotification': false,
          'deviceid': '993f0e149b5bed89',
          'platform': 'ios',
          'homefeed': "0",
          'locationIds': '21,27',
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


        emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: pageType,firstIndex: firstIndex));
      }
    });

    on<OnSwipeEndCard>((event, emit) {
      log(event.data.toString());
    });
  }
}
