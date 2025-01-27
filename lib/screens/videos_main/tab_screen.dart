import 'package:chotanews/screens/chota_info_screens/chota_info.dart';
import 'package:chotanews/screens/videos_main/video_views/devotional_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/gallery_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/myagazines_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/podcost_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/videos_view_screen.dart';
import 'package:flutter/material.dart';

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
        title: Row(
          children: [
            const Text(
              "Chota",
              style: TextStyle(
                color: Colors.black,
                fontSize: 25,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              color: Colors.lightBlue,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: const Text(
                "News",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 25,
              color: Colors.grey,
            ),
            onPressed: () {
              Navigator.pushNamed(context, RoutesManager.chotaInfo);

            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            indicatorColor: Colors.lightBlue,
            labelColor: Colors.lightBlue,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
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
