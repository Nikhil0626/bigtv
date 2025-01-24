

import 'package:chotanews/districts_selection/district_selection_bloc.dart';
import 'package:chotanews/screens/home_animation_widgets/home_handle_bloc.dart';
import 'package:chotanews/screens/testing_screen/test_bloc.dart';
import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/Auth_module/auth_bloc.dart';
import '../screens/home_screen/home_bloc.dart';

class RegisterProviders {
  static providers(BuildContext context) {
    return [
      BlocProvider<TestBloc>(
        create: (BuildContext context) => TestBloc(),
      ),BlocProvider<HomeHandleBloc>(
        create: (BuildContext context) => HomeHandleBloc(),
      ),
    BlocProvider<VideosBloc>(
        create: (BuildContext context) => VideosBloc(),
      ),
    BlocProvider<AuthBloc>(
        create: (BuildContext context) => AuthBloc(),
      ),
    BlocProvider<HomeBloc>(
        create: (BuildContext context) => HomeBloc(),
      ),
      BlocProvider<DistrictSelectionBloc>(
        create: (BuildContext context) => DistrictSelectionBloc(),
      ),
    ];
  }
}

