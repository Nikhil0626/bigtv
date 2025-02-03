import 'package:chotanews/screens/chota_info_screens/chota_info.dart';
import 'package:chotanews/screens/videos_main/video_views/devotional_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/gallery_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/myagazines_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/podcost_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/videos_view_screen.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../globel_keys/app_router.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreen();
}

class _TabScreen extends State<TabScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: InkWell(
          onTap: (){

          },
          child: const Icon(Icons.arrow_back_ios,size: 24,),
        ),
        title:  const Text(
          "Menu Screen",
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 25,
              color: Colors.black,
            ),
            onPressed: () {
              final GoogleSignIn _googleSignIn = GoogleSignIn();
              _googleSignIn.disconnect();
              // Navigator.pushNamed(context, RoutesManager.login);

            },
          ),
          width(width: 10)
        ],
        bottom: TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          indicatorColor: Colors.lightBlue,
          labelColor: Colors.lightBlue,

          labelStyle:  fontStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle:  fontStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(text: "వీడియోలు"),
            Tab(text: "గ్యాలరీ"),
            Tab(text: "పాడ్‌కాస్ట్"),
            Tab(text: "మ్యాగజైన్లు"),
            Tab(text: "భక్తి"),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                VideosScreen(),
                GalleryScreen(),
                PodcostScreen(),
                MyagazinesScreen(),
                DevotionalScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
