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
                    item["user_id"].toString(),
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  initiallyExpanded: false,
                  children: [
                    Text(
                      "Ads Source -- ${item["ad_source"]}",
                      style: const TextStyle(fontSize: 14, color: Colors.teal),
                    ),
                    Text(
                      "Latency Request -- ${item["latency_request"]}",
                      style: const TextStyle(fontSize: 14, color: Colors.orange),
                    ),
                    Text(
                      "Latency Load -- ${item["latency_load"]}",
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                    Text(
                      "Latency Render -- ${item["latency_render"]}",
                      style: const TextStyle(fontSize: 14, color: Colors.purple),
                    ),
                    Text(
                      "Latency Total -- ${item["latency_total"]}",
                      style: const TextStyle(fontSize: 14, color: Colors.green),
                    ),
                    Text(
                      "Ads Data -- ${item["data"]}",
                      style: const TextStyle(fontSize: 14, color: Colors.red),
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
