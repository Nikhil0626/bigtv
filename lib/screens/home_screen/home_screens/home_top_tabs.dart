import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/permission_handler_services.dart';
import '../../../utils/bottom_navigation_items.dart';
import '../home_provider/provider.dart';
import 'home_screen_view.dart';

class HomeTopTabs extends StatefulWidget {
  final String tab;
  final String postId;
  const HomeTopTabs({super.key, this.tab = "0",this.postId = "",});

  @override
  State<HomeTopTabs> createState() => _HomeTopTabsState();
}

class _HomeTopTabsState extends State<HomeTopTabs> with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool isChange = true;

  StreamSubscription? _pushSubscription;
  StreamSubscription? _pushActionSubscription;

  @override
  void initState() {
    super.initState();
    // if(widget.tab == "0" && widget.postId !=""){
    //   context.read<FlipProvider>().getIndividualPost(widget.postId).then((value) => context.read<FlipProvider>().getArticles(),);
    //
    // }
    requestNotificationPermission();
    context.read<FlipProvider>().isTabChange(int.parse(widget.tab), context, isMainPage: true);
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: int.parse(widget.tab),
    );

    log(widget.tab);
  }

  @override
  void dispose() {
    _pushSubscription?.cancel();
    _pushActionSubscription?.cancel();
    tabController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.blue,
        body: SafeArea(
          child: Consumer<FlipProvider>(
            builder: (context, flipProvider, __) {
              return Stack(
                children: [
                  // Main Page Views
                  TabBarView(
                    controller: tabController,

                    physics: const NeverScrollableScrollPhysics(),
                    children:  [
                      HomeScreenView(postId:  widget.postId ),
                      const HomeScreenView1(),
                    ],
                  ),

                  // Top TabBar (Fixed Overflow)
                  if (flipProvider.isShowTopBottomView)
                    Positioned(
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: isChange ? 1.0 : 0.0,
                          child: Material(
                            color: Colors.white,
                            child: SizedBox(
                              height: 50, // Fix for overflow issue
                              child: TabBar(
                                onTap: (val) {
                                  if (val == 1) {
                                    context.read<FlipProvider>().isLocationChange(false);
                                  }
                                  flipProvider.isTabChange(val, context);
                                },
                                controller: tabController,
                                indicatorColor: Colors.blue,
                                unselectedLabelColor: Colors.black,
                                unselectedLabelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                                tabs: const [
                                  Tab(text: 'న్యూస్'),
                                  Tab(text: 'జిల్లాలు'),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Bottom Navigation Bar (Fixed Overflow)
                  if (flipProvider.isShowTopBottomView)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),
                          opacity: isChange ? 1.0 : 0.0,
                          child: const BottomNavigationItems(),
                        ),
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
