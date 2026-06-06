import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';


import 'contest_provider.dart';
import '../individual_post_details/individual_post_view.dart';
import 'contest_screen.dart';

class JoinContestScreen extends StatefulWidget {
  const JoinContestScreen({super.key});

  @override
  State<JoinContestScreen> createState() => _JoinContestScreenState();
}

class _JoinContestScreenState extends State<JoinContestScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AdsContestProvider>(builder: (_, contestProvider, __) {
      if (contestProvider.joinedContestsList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/svg/no_contest.svg',
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(15.0),
        itemCount: contestProvider.joinedContestsList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = contestProvider.joinedContestsList[index];

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
                  child: item.contestImageUrl != null
                      ? Image.network(
                    item.contestImageUrl,
                    height: 50,
                    width: 50,
                    fit: BoxFit.fill,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image),
                  )
                      : Container(
                    height: 50,
                    width: 50,
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
                        item.contestName ?? "New Contest",
                        maxLines: 1,
                        style: newAppFont(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      height(height: 2),
                      Row(
                        children: [
                          Text(
                            "Created At: ${formatTimeDifferences(item.dateOfContest.toString())}",
                            style: newAppFont(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              if(item.isParticipated == true ){

                              }else{
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => IndividualPostView1(
                                      postId: item.postId.toString(),
                                      isComeFrom: true,
                                    ),
                                  ),
                                );

                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.isParticipated == true ? Colors.lightBlue.withOpacity(0.15) : Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.isParticipated == true ? "Joined" : "Join",
                                style: newAppFont(
                                  fontSize: 12,
                                  color: item.isParticipated == true ? Colors.blue : Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
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
