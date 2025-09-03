import 'package:chotanews/aggricator_screens/contest_screen/winners_screen.dart';
import 'package:chotanews/aggricator_screens/home_screen/home_provider/home_provider.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_fonts.dart';
import '../../no_data_screen/contest_no_data.dart';
import '../../utils/app_spaces.dart';
import 'contest_model.dart';
import 'contest_provider.dart';
import 'join_contest_screen.dart';

class ContestScreen extends StatefulWidget {
  const ContestScreen({super.key});

  @override
  State<ContestScreen> createState() => _ContestScreenState();
}

class _ContestScreenState extends State<ContestScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AdsContestProvider>().getContestList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(),
      body: Consumer<AdsContestProvider>(
        builder: (context, adsContestProvider, _) {
          return adsContestProvider.isLoading
              ? AppLoadingScreen()
              : TabBarView(
                  controller: _tabController,
                  children: [JoinContestScreen(), WinnersScreen()],
                );
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_outlined, size: 24.sp, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        }
      ),
      title: Text(
        "Contest",
        style: newAppFont(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: Colors.lightBlue,
        unselectedLabelColor: Colors.black,
        indicatorColor: Colors.lightBlue,
        indicatorWeight: 3.0,
        tabAlignment: TabAlignment.start,
        // <-- Align tabs to the left
        labelStyle: newAppFont(
          color: Colors.blue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: newAppFont(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: "Contest Details"),
          Tab(text: "Winners"),
        ],
      ),
    );
  }
}

String formatTimeDifferences(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'Invalid date';

  try {
    final dateTime = DateTime.parse(dateString);
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    }
  } catch (e) {
    return 'Invalid date';
  }
}
