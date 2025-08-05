import 'package:chotanews/aggricator_screens/home_screen/home_provider/home_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdsTestData extends StatefulWidget {
  const AdsTestData({super.key});

  @override
  State<AdsTestData> createState() => _AdsTestDataState();
}

class _AdsTestDataState extends State<AdsTestData> {
  int selectedIndex = 0;
  @override
  void initState() {
   context.read<HomeProvider>().getAdsSaveData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_,homeProvider,__) {
        return Scaffold(
          body:  ListView.builder(
            itemCount: homeProvider.getAdsDataList.length,
            itemBuilder: (context, index) {
              final item = homeProvider.getAdsDataList[index];
              return Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                  childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    maxRadius: 16,
                    backgroundColor: Colors.teal.shade400,
                    child: Text("$index", style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(
                    item["id"].toString() ?? "Hello",
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  // subtitle: Text(item["tags"], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  initiallyExpanded: false,
                  children: [
                    Text(
                      item["data"] ?? "Why",
                      style: const TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                  onExpansionChanged: (bool expanded) {
                    setState(() {
                      // You can track expanded state here if needed
                    });
                  },
                ),
              );
            },
          ),
        );
      }
    );
  }
}
