import 'dart:developer';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/permission_handler_services.dart';
import '../../utils/bottom_navigation_items.dart';
import '../testing_screen/provider.dart';
import 'home_screen_view.dart';

class HomeTopTabs extends StatefulWidget {
  final String tab;
  const HomeTopTabs({super.key, this.tab = "0"});

  @override
  State<HomeTopTabs> createState() => _HomeTopTabsState();
}

class _HomeTopTabsState extends State<HomeTopTabs> with SingleTickerProviderStateMixin {
  late TabController tabController;
  bool isChange = true;

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    log(widget.tab);
    context.read<FlipProvider>().isTabChange(int.parse(widget.tab),isMainPage: true );
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: int.parse(widget.tab) ?? 0,
    );

  }

  @override
  void dispose() {
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
        backgroundColor: AppColors.appButtonColor,

        body: SafeArea(
          child: Consumer<FlipProvider>(
            builder: (context,flipProvider,__) {
              return Stack(
                children: [
                  TabBarView(
                    controller: tabController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      HomePage(),
                      HomePage1(),
                    ],
                  ),
                  if(flipProvider.isShowTopBottomView)
                    Positioned(
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isChange ? 1.0 : 0.0,
                        child: Material(
                          color: Colors.white,
                          child: TabBar(
                            onTap: (val){
                              flipProvider.isTabChange(val);
                            },
                            controller: tabController,
                            isScrollable: false, // Disable scrolling of the TabBar
                            unselectedLabelColor: Colors.black,
                            indicatorColor: Colors.blue,
                            unselectedLabelStyle: fontStyle(color: Colors.black,fontSize: 16,fontWeight: FontWeight.w600),
                            labelStyle: fontStyle(color: Colors.blue,fontSize: 16,fontWeight: FontWeight.bold),
                            tabs: const [
                              Tab(text: 'న్యూస్'),
                              Tab(text: 'జిల్లాలు'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if(flipProvider.isShowTopBottomView)
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
            }
          ),
        ),
      ),
    );
  }
}
