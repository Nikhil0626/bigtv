import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';

class FilterView extends StatefulWidget {
  @override
  _FilterViewState createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> with SingleTickerProviderStateMixin {
  late TabController _tabController;


  final List<String> topics = ['Entertainment', 'News', 'Sports', 'Technology', 'Health'];


  final List<String> regions = [
    'Hyderabad', 'Warangal', 'Khammam', 'Nizamabad', 'Karimnagar',
    'Suryapet', 'Mahabubnagar', 'Rangareddy', 'Medchal', 'Adilabad'
  ];

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
        title: Text('Filter View'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Topics'),
            Tab(text: 'Regions'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: (topics.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      int firstIndex = index * 2;
                      int secondIndex = firstIndex + 1;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [

                          if (firstIndex < topics.length)
                            Expanded(child: _buildBorderedItem(topics[firstIndex])),


                          if (secondIndex < topics.length)
                            Expanded(child: _buildBorderedItem(topics[secondIndex])),
                        ],
                      );
                    },
                  ),
                ),

                // Regions Tab
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: (regions.length / 2).ceil(),
                    itemBuilder: (context, index) {
                      int firstIndex = index * 2;
                      int secondIndex = firstIndex + 1;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // First item in the row
                          if (firstIndex < regions.length)
                            Expanded(child: _buildBorderedItem(regions[firstIndex])),

                          // Second item in the row
                          if (secondIndex < regions.length)
                            Expanded(child: _buildBorderedItem(regions[secondIndex])),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlue,
                minimumSize: Size(200, 50),
              ),
              child: Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
