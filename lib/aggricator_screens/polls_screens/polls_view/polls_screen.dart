// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
// import 'package:chotanews/aggricator_screens/polls_screens/polls_view/polls_comments.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../utils/app_colors.dart';
// import '../../../utils/app_fonts.dart';
// import '../../../utils/app_spaces.dart';
//
// class PollsScreen extends StatefulWidget {
//   const PollsScreen({super.key, required this.article});
//   final dynamic article;
//
//   @override
//   State<PollsScreen> createState() => _PollsScreenState();
// }
//
// class _PollsScreenState extends State<PollsScreen> {
//   late List optionsPolls;
//   bool hasVoted = false;
//
//   @override
//
//   void initState() {
//     super.initState();
//
//     optionsPolls = widget.article['pollData']['options'];
//     hasVoted = widget.article['pollData']['userHasVoted'] ?? false;
//     Future.delayed(Duration.zero, () {
//       context.read<PollProvider>().votes = [];
//       context.read<PollProvider>().initialPollData(optionsPolls);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//
//         Positioned.fill(
//           child: CachedNetworkImage(
//             imageUrl: widget.article['image_url'] ?? "",
//             fit: BoxFit.cover,
//             placeholder: (context, url) =>
//                 Container(color: AppColors.borderColor.withOpacity(.2)),
//             errorWidget: (context, url, error) =>
//                 Center(child: Icon(Icons.image, size: 80, color: Colors.grey.shade300)),
//           ),
//         ),
//
//         Positioned(
//           top: 9,
//           right: 5,
//           child: Padding(
//             padding:  EdgeInsets.only(top: 8, right: 12),
//             child: Container(
//               decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
//               child: IconButton(
//                 icon:  Icon(Icons.ios_share_outlined, color: Colors.white, size: 22),
//                 onPressed: () {
//                   // Handle share
//                 },
//               ),
//             ),
//           ),
//         ),
//
//
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Consumer<PollProvider>(
//             builder: (_, pollProvider, __) {
//               final int totalVotes = pollProvider.votes.isNotEmpty
//                   ? pollProvider.votes.reduce((a, b) => a + b)
//                   : 0;
//
//               return Container(
//                 padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//
//                     Text(
//                       widget.article['title'] ?? '',
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: fontStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//
//                     height(height: 12),
//
//
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics:  NeverScrollableScrollPhysics(),
//                       itemCount: optionsPolls.length,
//                       itemBuilder: (context, index) {
//                         // ――― poll state ―――
//                         final bool   isSelected   = pollProvider.selectedIndex == index;
//                         final votes                = pollProvider.votes;
//                         final int    optionVotes   = (index < votes.length) ? votes[index] : 0;
//                         final double percentage    =
//                         totalVotes > 0 ? (optionVotes / totalVotes) * 100 : 0.0;
//
//                         // helper: “vote” vs. “votes”
//                         String voteLabel(int v) => v == 1 ? 'vote' : 'votes';
//
//                         return GestureDetector(
//                           onTap: hasVoted ? null : () => pollProvider.setSelectedIndex(index),
//                           child: Padding(
//                             padding:  EdgeInsets.symmetric(vertical: 4),
//                             child: Stack(
//                               children: [
//                                 // background card
//                                 Container(
//                                   height: 50,
//                                   width: MediaQuery.of(context).size.width,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade900,
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(color: Colors.grey.shade400),
//                                   ),
//                                 ),
//
//                                 // filled bar when user has voted
//                                 if (hasVoted)
//                                   Container(
//                                     height: 50,
//                                     width: MediaQuery.of(context).size.width * (percentage / 100),
//                                     decoration: BoxDecoration(
//                                       color: Colors.lightBlue,
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                   ),
//
//                                 // foreground row: option text + results
//                                 Container(
//                                   height: 50,
//                                   padding:  EdgeInsets.symmetric(horizontal: 16),
//                                   alignment: Alignment.centerLeft,
//                                   child: Row(
//                                     children: [
//                                       // option label
//                                       Expanded(
//                                         child: Text(
//                                           optionsPolls[index]['text'],
//                                           style: fontStyle(
//                                             color: hasVoted || isSelected
//                                                 ? Colors.white
//                                                 : Colors.grey,
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ),
//                                       // percentage + vote count
//                                       if (hasVoted)
//                                         Text(
//                                           '${percentage.toStringAsFixed(1)}% • '
//                                               '$optionVotes ${voteLabel(optionVotes)}',
//                                           style: fontStyle(
//                                             color: Colors.white,
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//
//                     if (!hasVoted && !pollProvider.isArticleRated(widget.article['id'])) ...[
//                       height(height: 12),
//
//                       /// Comment input
//                       TextFormField(
//                         controller: pollProvider.commentController,
//                         style: fontStyle(fontSize: 14, color: Colors.white),
//                         decoration: InputDecoration(
//                           hintText: "Type your comment here (optional)",
//                           hintStyle: fontStyle(color: Colors.white70),
//                           filled: true,
//                           fillColor: Colors.grey.shade900,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide:  BorderSide(color: Colors.white),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide:  BorderSide(color: Colors.white),
//                           ),
//                           focusedBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                             borderSide:  BorderSide(color: Colors.white),
//                           ),
//                         ),
//                       ),
//
//                       height(height: 12),
//
//                       /// Submit button
//                       SizedBox(
//                         width: double.infinity,
//                         height: 46,
//                         child: InkWell(
//                           onTap: pollProvider.selectedIndex != null
//                               ? () {
//                             pollProvider.submitPolls(
//                               widget.article['id'],
//                               pollProvider.selectedIndex!,
//                               optionsPolls,
//                               onSuccess: () {
//                                 setState(() => hasVoted = true);
//                               },
//                             );
//                           }
//                               : null,
//                           child: Container(
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                               color: pollProvider.selectedIndex != null ? Colors.lightBlue : Colors.grey.shade800,
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text("Submit", style: fontStyle(color: Colors.white)),
//                           ),
//                         ),
//                       ),
//                     ],
//
//                     /// Top Comments
//                     if (widget.article['topComments'].isNotEmpty) ...[
//                       height(height: 20),
//                       Row(
//                         children: [
//                           Text("Top Comments", style: fontStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
//                            Spacer(),
//                           InkWell(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => PollsComments(postId: widget.article["id"].toString()),
//                                 ),
//                               );
//                             },
//                               child: InkWell(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => PollsComments(postId:  widget.article["id"].toString()),
//                                     ),
//                                   );
//                                 },
//                                 child: Text(
//                                   "More >",
//                                   style: fontStyle(
//                                     color: Colors.lightBlue,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               )
//                           ),
//                         ],
//                       ),
//                       height(height: 6),
//                       SizedBox(
//                         height: 100,
//                         child: ListView.builder(
//                           scrollDirection: Axis.horizontal,
//                           itemCount: widget.article['topComments'].length,
//                           itemBuilder: (context, index) {
//                             final comment = widget.article['topComments'][index];
//                             return Container(
//                               width: MediaQuery.of(context).size.width - 100,
//                               margin:  EdgeInsets.only(right: 8),
//                               padding:  EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(color: Colors.grey),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                        Icon(Icons.account_circle, size: 20),
//                                       width(width: 5),
//                                       Text(comment["userName"] ?? "", style:  fontStyle(fontWeight: FontWeight.w600, fontSize: 12)),
//                                     ],
//                                   ),
//                                   height(height: 4),
//                                   Text(
//                                     comment["comment"] ?? "",
//                                     style:  fontStyle(fontSize: 13, color: Colors.black87),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                   height(height: 4),
//                                   Text(
//                                     "a few moments ago",
//                                     style: fontStyle(color: Colors.grey.shade600, fontSize: 11),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                     if(widget.article['topComments'].isEmpty)
//                     height(height: 55),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/aggricator_screens/polls_screens/polls_view/polls_comments.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key, required this.article});

  final dynamic article;

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  late List optionsPolls;
  late bool hasVoted;

  @override
  void initState() {
    super.initState();
    optionsPolls = widget.article['pollData']['options'];
    hasVoted = widget.article['pollData']['userHasVoted'] ?? false;

    Future.delayed(Duration.zero, () {
      context.read<PollProvider>().initialPollData(
            optionsPolls,
            widget.article['id'],
            hasVoted,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: widget.article['image_url'] ?? "",
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: AppColors.borderColor.withOpacity(.2)),
            errorWidget: (context, url, error) => Center(child: Icon(Icons.image, size: 80, color: Colors.grey.shade300)),
          ),
        ),
         Positioned(
          top: 9,
          right: 5,
          child: Padding(
            padding: EdgeInsets.only(top: 8, right: 12),
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(Icons.ios_share_outlined, color: Colors.white, size: 22),
                onPressed: () {
                  // Handle share
                },
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Consumer<PollProvider>(
            builder: (_, pollProvider, __) {
              final int totalVotes = pollProvider.votes.isNotEmpty ? pollProvider.votes.reduce((a, b) => a + b) : 0;

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.article['title'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: fontStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    height(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: optionsPolls.length,
                      itemBuilder: (context, index) {
                        final bool isSelected = pollProvider.selectedIndex == index;
                        final votes = pollProvider.votes;
                        final int optionVotes = (index < votes.length) ? votes[index] : 0;
                        final double percentage = totalVotes > 0 ? (optionVotes / totalVotes) * 100 : 0.0;

                        String voteLabel(int v) => v == 1 ? 'vote' : 'votes';

                        return GestureDetector(
                          onTap: hasVoted ? null : () => pollProvider.setSelectedIndex(index),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Stack(
                              children: [
                                // Background card
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade400),
                                  ),
                                ),

                                // Filled bar when voted
                                if (hasVoted)
                                  Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width * (percentage / 100),
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),

                                // Foreground content
                                Container(
                                  height: 50,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.centerLeft,
                                  child: Row(
                                    children: [
                                      // Option label
                                      Expanded(
                                        child: Text(
                                          optionsPolls[index]['text'],
                                          style: fontStyle(
                                            color: hasVoted || isSelected ? Colors.white : Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      // Percentage + votes
                                      if (hasVoted)
                                        Text(
                                          '${percentage.toStringAsFixed(1)}% • '
                                          '$optionVotes ${voteLabel(optionVotes)}',
                                          style: fontStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    if (!hasVoted && !pollProvider.isArticleRated(widget.article['id'])) ...[
                      height(height: 12),

                      // Comment input
                      TextFormField(
                        controller: pollProvider.commentController,
                        style: fontStyle(fontSize: 14, color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Type your comment here (optional)",
                          hintStyle: fontStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.grey.shade900,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      ),

                      height(height: 12),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: InkWell(
                          onTap: pollProvider.selectedIndex != null
                              ? () {
                                  pollProvider.submitPolls(
                                    widget.article['id'],
                                    pollProvider.selectedIndex!,
                                    optionsPolls,
                                    onSuccess: () {
                                      setState(() => hasVoted = true);
                                    },
                                  );
                                }
                              : null,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: pollProvider.selectedIndex != null ? Colors.lightBlue : Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text("Submit", style: fontStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],

                    // Top Comments
                    if (widget.article['topComments'].isNotEmpty) ...[
                      height(height: 20),
                      Row(
                        children: [
                          Text("Top Comments", style: fontStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Spacer(),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PollsComments(postId: widget.article["id"].toString()),
                                ),
                              );
                            },
                            child: Text(
                              "More >",
                              style: fontStyle(
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      height(height: 6),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: widget.article['topComments'].length,
                          itemBuilder: (context, index) {
                            final comment = widget.article['topComments'][index];
                            return Container(
                              width: MediaQuery.of(context).size.width - 100,
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_circle, size: 20),
                                      width(width: 5),
                                      Text(comment["userName"] ?? "", style: fontStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                    ],
                                  ),
                                  height(height: 4),
                                  Text(
                                    comment["comment"] ?? "",
                                    style: fontStyle(fontSize: 13, color: Colors.black87),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  height(height: 4),
                                  Text(
                                    "a few moments ago",
                                    style: fontStyle(color: Colors.grey.shade600, fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    if (widget.article['topComments'].isEmpty) height(height: 55),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
