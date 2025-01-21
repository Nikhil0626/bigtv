

import 'package:chotanews/screens/home_animation_widgets/home_handle_bloc.dart';
import 'package:chotanews/screens/testing_screen/test_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterProviders {
  static providers(BuildContext context) {
    return [
      BlocProvider<TestBloc>(
        create: (BuildContext context) => TestBloc(),
      ),BlocProvider<HomeHandleBloc>(
        create: (BuildContext context) => HomeHandleBloc(),
      ),
    ];
  }
}

