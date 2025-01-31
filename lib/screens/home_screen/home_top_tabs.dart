import 'package:chotanews/screens/districts_selection/districts_selection_screen.dart';
import 'package:chotanews/screens/home_screen/home_bloc.dart';
import 'package:chotanews/screens/home_screen/home_screen_view.dart';
import 'package:chotanews/screens/home_screen/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/bottom_navigation_items.dart';

class HomeTopTabs extends StatefulWidget {
  const HomeTopTabs({super.key});

  @override
  State<HomeTopTabs> createState() => _HomeTopTabsState();
}

class _HomeTopTabsState extends State<HomeTopTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isChange = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Method to handle back button press and stop the back navigation
  Future<bool> _onWillPop() async {
    // Returning false prevents the system back button from doing anything
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
                    children: const [
                      HomeScreenView(),
                      DistrictsSelectionScreen(),
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
                          labelColor: Colors.black,
                          unselectedLabelColor: Colors.black,
                          indicatorColor: Colors.blue,
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
