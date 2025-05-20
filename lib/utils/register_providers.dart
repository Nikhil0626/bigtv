

import 'package:chotanews/screens/home_animation_widgets/home_handle_bloc.dart';
import 'package:chotanews/screens/testing_screen/test_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/districts_selection/district_selection_bloc.dart';

import '../screens/individual_post_view/individual_post_bloc.dart';
import '../screens/videos_main/video_bloc/videos_bloc.dart';

class RegisterProviders {
  static providers(BuildContext context) {
    return [
      // BlocProvider<TestBloc>(
      //   create: (BuildContext context) => TestBloc(),
      // ),

      BlocProvider<HomeHandleBloc>(
        create: (BuildContext context) => HomeHandleBloc(),
      ),
    BlocProvider<VideosBloc>(
        create: (BuildContext context) => VideosBloc(),
      ),
      BlocProvider<DistrictSelectionBloc>(
        create: (BuildContext context) => DistrictSelectionBloc(),
      ),BlocProvider<IndividualPostBloc>(
        create: (BuildContext context) => IndividualPostBloc(),
      ),
    ];
  }
}

