
import 'package:chotanews/main.dart';
import 'package:chotanews/screens/testing_screen/test_bloc.dart';
import 'package:chotanews/screens/testing_screen/test_event.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestView extends StatefulWidget {
  const TestView({super.key});

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  @override
  void initState() {
   context.read<TestBloc>().add(TestEventOne());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }
}
