import 'dart:developer';

import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_event.dart';
import 'package:chotanews/screens/videos_main/video_repo/videos_repo.dart';
import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../videos_model/videos_model.dart';

class VideosBloc extends Bloc<VideosEvent, VideosState> {
  List<GetAllVideosModel> getAllVideosList = [];

  VideosBloc() : super(InitialState()) {
    on<GetAllVideos>((event, emit) async {
      emit(LoadingState());
      try {
        Map<String, dynamic> queryParameters = {"type": event.type.toString()};
        Response response = await VideosRepo().getAllVideos(queryParameters);
        log(response.toString());
        if (response.statusCode == 200) {
          List data = response.data["posts"];
          getAllVideosList =
              data.map((e) => GetAllVideosModel.fromJson(e)).toList();
          emit(VideoSuccessState(getAllVideoList: getAllVideosList));
        }
      } on DioException catch (e, st) {
        emit(VideoErrorState(message: e.response?.data.toString()));
        log(e.toString());
        log(st.toString());
      } catch (e, st) {
        emit(VideoErrorState(message: e.toString()));
        log(e.toString());
        log(st.toString());
      }
    });
  }
}
