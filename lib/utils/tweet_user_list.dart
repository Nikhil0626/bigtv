import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/x_tweete_view/x_tweets_provider.dart';

class BottomSheetExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return  Container(
      height: 200,
        width: 500,
        color: Colors.teal,
        // child: ElevatedButton(
        //   onPressed: () {
        //     showModalBottomSheet(
        //       context: context,
        //       isScrollControlled: true,
        //       builder: (context) {
        //         return Consumer<XTweetsProvider>(
        //           builder: (_,xTweetsProvider,__) {
        //             return Padding(
        //               padding: const EdgeInsets.all(8.0),
        //               child: ListView.builder(
        //                 itemCount: xTweetsProvider.userNamesList.length,
        //                 itemBuilder: (context, index) {
        //                   return Card(
        //                     margin: EdgeInsets.all(10),
        //                     elevation: 5,
        //                     shape: RoundedRectangleBorder(
        //                       borderRadius: BorderRadius.circular(10),
        //                     ),
        //                     child: ListTile(
        //                       contentPadding: EdgeInsets.all(15),
        //                       title: Text(xTweetsProvider.userNamesList[index]),
        //                     ),
        //                   );
        //                 },
        //               ),
        //             );
        //           }
        //         );
        //       },
        //     );
        //   },
        //   child: Text('Show Bottom Sheet'),
        // ),
      );
  }
}