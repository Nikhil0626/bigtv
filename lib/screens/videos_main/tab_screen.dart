import 'package:chotanews/screens/videos_main/video_views/devotional_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/gallery_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/myagazines_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/podcost_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/videos_view_screen.dart';
import 'package:flutter/material.dart';

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
                fontSize: 30,
                fontWeight: FontWeight.bold,
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
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.circle_notifications_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          TabBar(
            controller: tabController,
            indicatorColor: Colors.lightBlue,
            labelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: "Videos"),
              Tab(text: "Gallery"),
              Tab(
                text: "Podcost",
              ),
              Tab(
                text: "Myagazines",
              ),
              Tab(
                text: "Devotional",
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                VideosScreen(),
                // ReelsScreen(),
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
