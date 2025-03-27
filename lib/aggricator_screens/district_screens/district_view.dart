import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class RegionSelectionScreen extends StatefulWidget {
  @override
  _RegionSelectionScreenState createState() => _RegionSelectionScreenState();
}

class _RegionSelectionScreenState extends State<RegionSelectionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 28),
          onPressed: () {},
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              'assets/svg/Chota_news_logo.svg',
              height: 30,
              width: 180,
              alignment: Alignment.centerLeft,
            ),
            height(height: 40.h),
            Text("Let's personalise", style: TextStyle(fontSize: 32, color: Colors.blue, fontWeight: FontWeight.w400)),
            Text("your experience", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue)),
            SizedBox(height: 16),
            Text("Choose Regions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                )),
            SizedBox(height: 4),
            Text("Select your districts to receive hyperlocal news and relevant local information tailored to your area.",
                style: TextStyle(fontSize: 12, color: Colors.black)),
            SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.black,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(color: Colors.lightBlue, width: 2.0),
              ),
              labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              tabs: [
                Tab(text: "Andhra Pradesh"),
                Tab(text: "Telangana"),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [],
              ),
            ),
            height(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {},
                child: Text("Skip", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
