
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/filters_screen/update_categories_view.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_view/filters_screen/update_regions_view.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../utils/app_colors.dart';
import '../../settings_provider/settings_provider.dart';

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  _FilterViewState createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List tabNames = ['Topics', 'Regions'];

  @override
  void initState() {
    super.initState();
    // context.read<SettingsProvider>().bannerAd.dispose();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(onTap: () {
          Navigator.pop(context);
        },
          child: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 16.0.sp),
            child: Icon(Icons.arrow_back_outlined,size: 24.sp,)
          ),
        ),
        title: Text(
          'Filter ',
          style: newAppFont(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
        ),
        // bottom: PreferredSize(
        //   preferredSize: Size.fromHeight(48),
        //   child: Align(
        //     alignment: Alignment.centerLeft,
        //     child: TabBar(
        //       controller: _tabController,
        //       isScrollable: true,
        //       padding: EdgeInsets.zero,
        //       labelPadding: const EdgeInsets.only(right: 12),
        //       indicatorPadding: EdgeInsets.zero,
        //       tabs: [
        //         Tab(text: 'Topics',),
        //         Tab(text: 'Regions'),
        //       ],
        //       unselectedLabelStyle: newAppFont(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
        //       labelStyle: newAppFont(color:AppColors.appButtonColor, fontSize: 14, fontWeight: FontWeight.w600),
        //       unselectedLabelColor: AppColors.bodyTextColor,
        //       labelColor: AppColors.appButtonColor,
        //       indicatorColor: AppColors.appButtonColor,
        //     ),
        //   ),
        // ),
      ),
      body: Column(
        children: [
          // TabBar(
          //   controller: _tabController,
          //   isScrollable: true,
          //   padding: EdgeInsets.zero,
          //   //labelPadding: const EdgeInsets.only(right: 12),
          //   indicatorPadding: EdgeInsets.zero,
          //   tabs: [
          //     Tab(child: Text('Topics'),),
          //     Tab(child: Text('Regions'),),
          //   ],
          //   unselectedLabelStyle: newAppFont(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
          //   labelStyle: newAppFont(color:AppColors.appButtonColor, fontSize: 14, fontWeight: FontWeight.w600),
          //   unselectedLabelColor: AppColors.bodyTextColor,
          //   labelColor: AppColors.appButtonColor,
          //   indicatorColor: AppColors.appButtonColor,
          // ),
          TabBar(
            isScrollable: true,
            controller: _tabController,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            unselectedLabelStyle: newAppFont(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
            labelStyle: newAppFont(color:AppColors.appButtonColor, fontSize: 14, fontWeight: FontWeight.w600),
            unselectedLabelColor: AppColors.bodyTextColor,
            labelColor: AppColors.appButtonColor,
            indicatorColor: AppColors.appButtonColor,
            tabs: List.generate(
              tabNames.length,
                  (tIndex) => Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 12,
                ),
                child: Text(
                  tabNames[tIndex],
                  // style: newAppFont(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
            ),

          ),

          Expanded(child: TabBarView(controller: _tabController, children: [
            UpdateCategoriesView(),
            UpdateRegionsView(),
          ]))
        ]
      ),
    );
  }
}
