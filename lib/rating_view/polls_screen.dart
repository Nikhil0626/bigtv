import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/rating_view/rating_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../aggricator_screens/home_screen/home_provider/home_provider.dart';
import '../utils/app_fonts.dart';
import '../utils/app_spaces.dart';
import '../utils/app_colors.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key, this.article});

  final article;

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  late final List<String> options;

  int? selectedIndex;
  final List<int> votes = [80, 20];
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    options = [
      widget.article['poll_option_1'] ?? "Option 1",
      widget.article['poll_option_4'] ?? "Option 4",
    ];
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int totalVotes = votes.reduce((a, b) => a + b);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: widget.article['image_url'] ?? "",
              fit: BoxFit.fill,
              placeholder: (context, url) => Container(color: AppColors.borderColor.withOpacity(.2)),
              errorWidget: (context, url, error) => Center(child: Icon(Icons.image, size: 80, color: Colors.grey.shade300)),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8, right: 12),
                  child: Align(
                    alignment: Alignment.topRight,
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

                height(height: 178),

                // ─ Tag
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                ),

                height(height: 5),

                // ─ Question
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.article['title'].toString(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: fontStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                height(height: 5),

                // ─ Options
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final bool isSelected = selectedIndex == index;
                    final double percentage = totalVotes > 0 ? (votes[index] / totalVotes) * 100 : 0.0;

                    return GestureDetector(
                      onTap: () {
                        if (selectedIndex == null) {
                          setState(() {
                            selectedIndex = index;
                            votes[index]++;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Center(
                          child: Stack(
                            children: [
                              Container(
                                height: 52,
                                width: 327,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade900,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade400),
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  height: 52,
                                  width: 327 * (percentage / 100),
                                  decoration: BoxDecoration(
                                    color: Colors.lightBlue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              Container(
                                height: 52,
                                width: 327,
                                padding: const EdgeInsets.symmetric(horizontal: 15),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        options[index],
                                        // maxLines: 1,
                                        // overflow: TextOverflow.ellipsis,
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
                                              '${percentage.toStringAsFixed(1)}% • ${votes[index]} votes',
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

                // ─ Comment field
                Consumer<RatingProvider>(
                  builder: (_, ratingProvider, __) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        height: 52,
                        width: 327,
                        child: TextFormField(
                          onTap: () {
                            context.read<HomeProvider>().pageChange(isValue: false);
                          },
                          controller: ratingProvider.commentController,
                          style: const TextStyle(
                            fontSize: 13,
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
                    );
                  },
                ),

                height(height: 5),

                // ─ Submit button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 45,
                    width: 327,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: selectedIndex != null ? Colors.lightBlue : Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: selectedIndex != null
                            ? () {
                                debugPrint("Selected: ${options[selectedIndex!]}");
                                debugPrint("Comment: ${commentController.text}");
                              }
                            : null,
                        child: Text(
                          "Submit",
                          style: fontStyle(
                            color: selectedIndex != null ? Colors.white : Colors.black54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                height(height: 15),

                // ─ Top‑comments heading
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: const [
                      Text("Top Comments", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                      Spacer(),
                      Text("More", style: TextStyle(color: Colors.lightBlue, fontSize: 15, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),

                height(height: 7),

                // ─ Top‑comments list
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: SizedBox(
                    height: 98,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 298,
                          margin: const EdgeInsets.only(right: 12),
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
                                  Text("User name",
                                      //   widget.article["topComments"][index]["userName"],

                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              height(height: 4),
                              Text(
                                "Nice movie. Good performances!",
                                //   widget.article["topComments"][index]["comment"],

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
                ),

                height(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
