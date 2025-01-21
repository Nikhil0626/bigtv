import 'package:chotanews/screens/home_animation_widgets/home_handle_bloc.dart';
import 'package:chotanews/screens/home_animation_widgets/home_handle_event.dart';
import 'package:chotanews/screens/home_animation_widgets/home_handle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CollapseWidgetScreen extends StatefulWidget {
  final Widget homeView;
  const CollapseWidgetScreen({super.key,required this.homeView});

  @override
  State<CollapseWidgetScreen> createState() => _CollapseWidgetScreenState();
}

class _CollapseWidgetScreenState extends State<CollapseWidgetScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeHandleBloc,HomeHandleState>(
      builder: (context,state) {
        if(state is ActiveAndInActive){
          return GestureDetector(
            onTap: () {
              context.read<HomeHandleBloc>().add(ActiveAndInactive());
            },
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height-50,
                    child: widget.homeView),

                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 1000), // Animation duration
                    opacity: state.isActive ? 1.0 : 0.0, // Opacity based on state
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          color: Colors.black.withOpacity(0.7),
                          child: const Text(
                            'Top Row Content',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500), // Animation duration
                    opacity: state.isActive ? 1.0 : 0.0, // Opacity based on state
                    child: const SizedBox(
                      height: 70,
                      child: Column(
                        children: [
                          Divider(color: Colors.black,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.home,
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Home',
                                      style: TextStyle(color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(

                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.video_call,
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Videos',
                                      style: TextStyle(color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.add_card,
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Bytes',
                                      style: TextStyle(color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.account_circle,
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Profile',
                                      style: TextStyle(color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              ],
            ),
          );
        }else{
          return GestureDetector(
            onTap: () {
              context.read<HomeHandleBloc>().add(ActiveAndInactive());
            },
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,

                child: widget.homeView),
          );
        }

      }
    );
  }
}
