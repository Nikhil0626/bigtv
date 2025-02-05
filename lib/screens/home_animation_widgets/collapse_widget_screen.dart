import 'package:chotanews/screens/home_animation_widgets/home_handle_bloc.dart';
import 'package:chotanews/screens/home_animation_widgets/home_handle_event.dart';
import 'package:chotanews/screens/home_animation_widgets/home_handle_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';

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
                          padding:  EdgeInsets.all(10),
                          color: Colors.black.withOpacity(0.7),
                          child:  Text(
                            'Top Row Content',
                            style: fontStyle(color: Colors.white, fontSize: 16),
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
                    child:  SizedBox(
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
                                    const Icon(
                                      Icons.home,
                                      color: Colors.black,
                                    ),
                                    height(height: 4),
                                    Text(
                                      'Home',
                                      style: fontStyle(color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.video_call,
                                      color: Colors.black,
                                    ),
                                    height(height: 4),
                                    Text(
                                      'Videos',
                                      style: fontStyle(color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                               Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.add_card,
                                      color: Colors.black,
                                    ),
                                    height(height: 4),

                                     Text(
                                      'Bytes',
                                      style: fontStyle(color: Colors.black, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                               Expanded(
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.account_circle,
                                      color: Colors.black,
                                    ),
                                    height(height: 4),
                                    Text(
                                      'Profile',
                                      style: fontStyle(color: Colors.black, fontSize: 12),
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
