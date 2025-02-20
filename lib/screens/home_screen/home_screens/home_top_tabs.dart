import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../../services/permission_handler_services.dart';
import '../../../utils/bottom_navigation_items.dart';
import '../home_provider/provider.dart';
import 'home_screen_view.dart';

class HomeTopTabs extends StatefulWidget {
  final String tab;
  const HomeTopTabs({super.key, this.tab = "0"});

  @override
  State<HomeTopTabs> createState() => _HomeTopTabsState();
}

class _HomeTopTabsState extends State<HomeTopTabs> with SingleTickerProviderStateMixin {
  final WebEngagePlugin _webEngagePlugin = WebEngagePlugin();
  late TabController tabController;
  bool isChange = true;

  StreamSubscription? _pushSubscription;
  StreamSubscription? _pushActionSubscription;

  @override
  void initState() {
    super.initState();
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

    double height = (
        MediaQuery.of(context).padding.top );
    double height1 = (MediaQuery.of(context).padding.bottom);

    log("height height height ${height}");
    log("height1 height2 height3 ${height1}");
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Consumer<FlipProvider>(
            builder: (context, flipProvider, __) {
              return Stack(
                children: [
                  // Main Page Views
                  TabBarView(
                    controller: tabController,

                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      HomePage(),
                      HomePage1(),
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
