import 'dart:developer';

import 'package:chotanews/screens/home_screen/home_bloc.dart';
import 'package:chotanews/screens/home_screen/home_state.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/bottom_navigation_items.dart';
import 'flip_way2news.dart';

class HomeTopTabs extends StatefulWidget {
  final String tab;
  const HomeTopTabs({super.key, this.tab ="1"});

  @override
  State<HomeTopTabs> createState() => _HomeTopTabsState();
}

class _HomeTopTabsState extends State<HomeTopTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isChange = false;

  @override
  void initState() {
    super.initState();
    log(widget.tab);
    _tabController = TabController(length: 2, vsync: this,initialIndex: int.parse(widget.tab.toString()));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Intercept the back button press
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocConsumer<HomeBloc, HomeScreenState>(
            listener: (context, state) {
              if (state is SuccessHomeScreenState) {
                setState(() {
                  isChange = state.isChange;
                });
              }
            },
            builder: (context, state) {
              return Stack(
                children: [
                  TabBarView(
                    controller: _tabController,
                    physics: const NeverScrollableScrollPhysics(), // Disable horizontal scroll
                    children:  const [
                      MyHomePage1(tabName: "Home",),
                      MyHomePage1(tabName: "",),

                    ],
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: isChange ? 1.0 : 0.0,
                      child: Material(
                        color: Colors.white,
                        child: TabBar(
                          controller: _tabController,
                          isScrollable: false, // Disable scrolling of the TabBar
                          unselectedLabelColor: Colors.black,
                          indicatorColor: Colors.blue,
                          unselectedLabelStyle: fontStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.normal),
                          labelStyle: fontStyle(color: Colors.blue,fontSize: 16,fontWeight: FontWeight.bold),
                          tabs: const [
                            Tab(text: 'వార్తలు'),
                            Tab(text: 'జిల్లాలు'),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 1,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: isChange ? 1.0 : 0.0,
                      child: const BottomNavigationItems(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
