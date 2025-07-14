import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../home_screen/home_provider/home_provider.dart';
import '../../rating_screen/rating_provider/rating_provider.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key, this.article});

  final article;

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  List<dynamic> optionsPolls = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: widget.article['image_url'] ?? "",
            fit: BoxFit.fill,
            placeholder: (context, url) => Container(color: AppColors.borderColor.withOpacity(.2)),
            errorWidget: (context, url, error) => Center(child: Icon(Icons.image, size: 80, color: Colors.grey.shade300)),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, right: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.ios_share_outlined, color: Colors.white, size: 22),
                onPressed: () {},
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Consumer<PollProvider>(builder: (_, pollProvider, __) {
              // pollProvider.initialPollData();
              final int totalVotes = pollProvider.votes.reduce((a, b) => a + b);
              optionsPolls = widget.article['poll_options'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Chota ",
                            style: fontStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: "News",
                            style: fontStyle(color: Colors.lightBlue, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  height(height: 6),
                  Text(
                    widget.article['title'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: fontStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  height(height: 6),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: optionsPolls.length,
                    itemBuilder: (context, index) {
                      final bool isSelected = pollProvider.selectedIndex == index;
                      final double percentage = totalVotes > 0 ? (pollProvider.votes[index] / totalVotes) * 100 : 0.0;

                      return GestureDetector(
                        onTap: () {
                          pollProvider.submitPolls(widget.article['id'],index);

                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Center(
                            child: Stack(
                              children: [
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade900,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.grey.shade400),
                                  ),
                                ),
                                if (isSelected)
                                  Container(
                                    height: 50,
                                    width: MediaQuery.of(context).size.width * (percentage / 100),
                                    decoration: BoxDecoration(
                                      color: Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          optionsPolls[index]['option_name'],
                                          style: fontStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: isSelected
                                            ? Text(
                                                '${percentage.toStringAsFixed(1)}% • ${pollProvider.votes[index]} votes',
                                                textAlign: TextAlign.end,
                                                style: fontStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  height(height: 4),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: TextFormField(
                      onTap: () {
                        context.read<HomeProvider>().pageChange(isValue: false);
                      },
                      controller: pollProvider.commentController,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        hintText: "Type your comment here (optional)",
                        hintStyle: const TextStyle(fontSize: 12, color: Colors.white70),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        filled: true,
                        fillColor: Colors.grey.shade900,
                        // dark fill to match the screen
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  height(height: 6),
                  SizedBox(
                    height: 46,
                    width: MediaQuery.of(context).size.width,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: pollProvider.selectedIndex != null ? Colors.lightBlue : Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: pollProvider.selectedIndex != null
                            ? () {
                                debugPrint("Selected: ${optionsPolls[pollProvider.selectedIndex!]}");
                              }
                            : null,
                        child: Text(
                          "Submit",
                          style: fontStyle(
                            color: pollProvider.selectedIndex != null ? Colors.white : Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  widget.article['topComments'].isEmpty
                      ? SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 6),
                          child: Row(
                            children: const [
                              Text("Top Comments", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                              Spacer(),
                              Text("More >", style: TextStyle(color: Colors.lightBlue, fontSize: 15, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                  widget.article['topComments'].isEmpty
                      ? SizedBox.shrink()
                      : SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.article['topComments'].length,
                            itemBuilder: (context, index) {
                              return Container(
                                width: MediaQuery.of(context).size.width - 100,
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.account_circle, size: 22, color: Colors.black),
                                        width(width: 5),
                                        Text(widget.article["topComments"][index]["userName"], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                    height(height: 4),
                                    Text(
                                      widget.article["topComments"][index]["comment"],
                                      style: fontStyle(color: Colors.grey.shade800, fontSize: 14, fontWeight: FontWeight.w500),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    height(height: 4),
                                    Text(
                                      "a few moments ago",
                                      // " ${formatTimeDifference(
                                      //         widget.article["topComments"][index]["createdAt"],
                                      //        )}",
                                      style: fontStyle(color: Colors.grey.shade500, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                  height(height: 20),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
