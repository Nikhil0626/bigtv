import 'package:chotanews/aggricator_screens/filters_screen/update_categories_view.dart';
import 'package:chotanews/aggricator_screens/filters_screen/update_regions_view.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  _FilterViewState createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  Widget _buildBorderedItem(String title) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.lightBlue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: newAppFont(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter ',style: newAppFont(color: Colors.black,fontSize: 18,fontWeight: FontWeight.w500),),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Topics'),
            Tab(text: 'Regions'),
          ],
          unselectedLabelColor: Colors.black,
          labelColor: Colors.blue,
          indicatorColor: Colors.blue,
        ),
      ),
body: TabBarView(
    controller: _tabController,
    children: [
  UpdateCategoriesView(),
  UpdateRegionsView(),
]),    );
  }
}

