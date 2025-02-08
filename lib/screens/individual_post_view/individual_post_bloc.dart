import 'dart:developer';

import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:chotanews/screens/individual_post_view/individual_post_event.dart';
import 'package:chotanews/screens/individual_post_view/individual_post_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/global_variables_data.dart';
import '../home_screen/home_repo.dart';

class IndividualPostBloc extends Bloc<IndividualPostEvent,IndividualPostState> {
  IndividualPostBloc() : super(InitialPostState()) {

    HomeScreenModel getSinglePost;


    on<GetSinglePost>((event, emit) async {
      emit(LoadingPostState());
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      String locationId = sharedPreferences.getString(
        "locationId",
      ) ??
          "";
      log(locationId);
      String deviceId = GlobalVariables().deviceId ?? "";
      String platForm = GlobalVariables().platForm ?? "";

      try {
        Response response = await HomeRepo().getSinglePost(event.postId);
        log(response.data.toString());
        List data = response.data['posts'];
         getSinglePost = HomeScreenModel.fromJson(data[0]);
        emit(SuccessPostState(getPost: getSinglePost));
      } on DioException catch (e, st) {
        emit(ErrorPostState(error: ""));
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api  catch ${st.toString()}");
      } catch (e, st) {
        emit(ErrorPostState(error: ""));
        log("Get News Api catch error ${st.toString()}");
        log("Get News Api catch ${st.toString()}");
      }
    });
  }
}