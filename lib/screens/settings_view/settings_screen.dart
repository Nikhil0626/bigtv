
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/settings_view/profile_screen.dart';
import 'package:tweetai/screens/settings_view/setting_provider.dart';
import 'package:tweetai/screens/settings_view/users_screen.dart';
import 'package:tweetai/utils/app_colors.dart';

import '../../mixin_class/auth_mixin.dart';
import '../../utils/app_fonts.dart';
import 'content_configuration_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin,AuthMixin{
  int current = 0;
  late TabController tabController;

  @override
  void initState() {
    context.read<SettingProvider>().getSettingData();


    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          TabBar(
              indicatorColor: AppColors.appButtonColor,
              unselectedLabelColor: AppColors.headerTextColor,
              dividerColor: Colors.white,
              controller: tabController,

              labelStyle: fontStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.appButtonColor,
                  fontSize: 14),
              unselectedLabelStyle: fontStyle(
                  fontWeight: FontWeight.normal,
                  color: AppColors.headerTextColor,
                  fontSize: 14),
              tabs: [

            Tab(
              child: Text("Users ",),
            ),
            Tab(
              child: Text("Content "),
            ),
                Tab(
                  child: Text("Profile "),
                ),
          ]),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children:  const [
                UsersScreen(),
                ContentConfigurationScreen(),
                UserProfileScreen(),

              ],
            ),
          )
        ],
      ),
    );
  }
}
