import 'dart:developer';
import 'dart:async'; // Import for StreamSubscription

import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../services/permission_handler_services.dart';
import '../../utils/bottom_navigation_items.dart';
import '../individual_post_view/individual_post.dart';
import '../testing_screen/provider.dart';
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

  // Stream subscriptions
  StreamSubscription? _pushSubscription;
  StreamSubscription? _pushActionSubscription;

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    // context.read<FlipProvider>().disposes("0");
    context.read<FlipProvider>().isTabChange(int.parse(widget.tab), context, isMainPage: true);
    tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: int.parse(widget.tab),
    );

    // if (widget.tab != "1") {
    //   subscribeToPushCallbacks();
    // }

    log(widget.tab);
  }

  void subscribeToPushCallbacks() {
    // Cancel existing subscriptions to prevent multiple listeners
    _pushSubscription?.cancel();
    _pushActionSubscription?.cancel();

    _pushSubscription = _webEngagePlugin.pushStream.listen((event) {
      Map<String, dynamic> messagePayload = event.payload!;
      log("Push Notification Received: ${messagePayload["postId"]}");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => IndividualPost(postId: messagePayload["postId"].toString())),
            (route) => false,
      );
    });

    _pushActionSubscription = _webEngagePlugin.pushActionStream.listen((event) {
      Map<String, dynamic>? messagePayload = event.payload;
      log("Push Action Clicked: ${messagePayload!["postId"]}");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => IndividualPost(postId: messagePayload["postId"].toString())),
            (route) => false,
      );
    });
  }

  @override
  void dispose() {
    // Cancel the stream subscriptions to prevent memory leaks
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
        backgroundColor: AppColors.appButtonColor,
        body: SafeArea(
          child: Consumer<FlipProvider>(
            builder: (context, flipProvider, __) {
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
                  if (flipProvider.isShowTopBottomView)
                    Positioned(
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isChange ? 1.0 : 0.0,
                        child: Material(
                          color: Colors.white,
                          child: TabBar(
                            onTap: (val) {
                              if(val == 1){
                               // context.read<FlipProvider>().disposes("1");
                               context.read<FlipProvider>().isLocationChange(false);
                              }else{
                                // context.read<FlipProvider>().disposes("0");
                              }
                              flipProvider.isTabChange(val, context);
                            },
                            controller: tabController,
                            isScrollable: false,
                            unselectedLabelColor: Colors.black,
                            indicatorColor: Colors.blue,
                            unselectedLabelStyle: fontStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w700),
                            labelStyle: fontStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                            tabs: const [
                              Tab(text: 'న్యూస్'),
                              Tab(text: 'జిల్లాలు'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (flipProvider.isShowTopBottomView)
                    Positioned(
                      bottom: 0,
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
