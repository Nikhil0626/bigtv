import 'dart:developer';

import 'package:appinio_swiper/enums.dart';
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
        'lpostid': "0",
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
        emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: ""));
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
        emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: pageType));
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
      switch (event.activity) {
        case Swipe():
          pageType = getAllPosts[event.targetIndex!].type.toString();
          emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: pageType));

          if(event.targetIndex! == getAllPosts.length){
            emit(LoadingHomeScreenState());

            final Map<String, dynamic> queryParams = {
              'userid': "1",
              'postid': getAllPosts.last.id.toString(),
              'lpostid': "0",
              'includeHomePage': "1",
              'hasAds': true,
              'isByNotification': false,
              'deviceid': '993f0e149b5bed89',
              'platform': 'ios',
              'homefeed': "1",
              'locationIds': 'undefined',
            };
            log(getAllPosts.last.id.toString());
            log(queryParams.toString());
            Response response = await HomeRepo().getAllNewsFeeds(queryParams);
            List data = response.data['posts'];
            getAllPosts = data
                .map(
                  (e) => HomeScreenModel.fromJson(e),
            )
                .toList();
            emit(SuccessHomeScreenState(getAllHomeScreenNews: getAllPosts,pageType: pageType));
          }
          break;
        case Unswipe():
          log('A ${event.activity?.direction.name} swipe was undone.');
          log('previous index: ${event.previousIndex}, target index: ${event.targetIndex}');
          break;
        case CancelSwipe():
          log('A swipe was cancelled');
          break;
        case DrivenActivity():
          log('Driven Activity');
          break;
        case null:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    });

    on<OnSwipeEndCard>((event, emit) {
      log(event.data.toString());
    });
  }
}
