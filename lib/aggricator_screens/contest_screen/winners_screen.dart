import 'package:chotanews/aggricator_screens/contest_screen/contest_provider.dart';
import 'package:chotanews/aggricator_screens/contest_screen/contest_screen.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/app_spaces.dart';

class WinnersScreen extends StatefulWidget {
  const WinnersScreen({super.key});

  @override
  State<WinnersScreen> createState() => _WinnersScreenState();
}

class _WinnersScreenState extends State<WinnersScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdsContestProvider>(builder: (_, contestProvider, __) {
      return ListView.separated(
        padding: const EdgeInsets.all(15.0),
        itemCount: contestProvider.contestWinnersList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = contestProvider.contestWinnersList[index];

          return Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: item.userPic != null
                      ? Image.network(
                          item.userPic!,
                          height: 50,
                          width: 50,
                          fit: BoxFit.fill,
                          errorBuilder: (_, __, ___) => const Icon(Icons.image),
                        )
                      : Container(
                          height: 70,
                          width: 70,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image),
                        ),
                ),
                width(width: 12),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.contestName??"User123",

                        style: newAppFont(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      height(height: 4),
                      Text(
                        item.userName??"User123",
                        style: newAppFont(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade500
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      height(height: 4),
                      Text(
                        "Awarded on: ${formatTimeDifferences(item.dateOfContest.toString())}",
                        style: newAppFont(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.normal
                        ),
                      ),
                    ],
                  ),
                ),


              ],
            ),
          );
        },
      );
    });
  }
}
