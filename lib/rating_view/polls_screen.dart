import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_fonts.dart';
import '../utils/app_spaces.dart';
import '../utils/app_colors.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  List<String> options = ["బాగుంది", "బాగలేదు"];
  int? selectedIndex;
  List<int> votes = [80, 20];
  final TextEditingController commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalVotes = votes.reduce((a, b) => a + b);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              "https://cdn.gulte.com/wp-content/uploads/2025/06/8-Vasanthalu-movie-review-scaled.jpeg",
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Share Button
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
                          onPressed: () {},
                          icon: const Icon(Icons.ios_share_outlined, color: Colors.white, size: 22),
                        ),
                      ),
                    ),
                  ),

                  // UI pushed down
                  height(height: 270),

                  // Tag
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

                  // Question
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "8 వసంతాలు సినిమా ఎలా అనిపిస్తుంది?",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: fontStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  height(height: 5),

                  // Options
                  ListView.builder(
                    itemCount: options.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      bool isSelected = selectedIndex == index;
                      double percentage = totalVotes > 0 ? (votes[index] / totalVotes) * 100 : 0.0;

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

                  // Comment Field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 52,
                      width: 327,
                      child: TextFormField(
                        controller: commentController,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: "Type your comment here (optional)",
                          hintStyle: const TextStyle(fontSize: 12, color: Colors.white70),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          filled: true,
                          fillColor: Colors.grey.shade900,
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
                  ),

                  height(height: 5),

                  // Submit Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      height: 45,
                      width: 327,
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(12)),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: selectedIndex != null ? Colors.lightBlue : Colors.blueGrey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          onPressed: selectedIndex != null
                              ? () {
                            print("Selected option: ${options[selectedIndex!]}");
                            print("Comment: ${commentController.text}");
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

                  // Top Comments Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          "Top Comments",
                          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        const Spacer(),
                        const Text(
                          "More",
                          style: TextStyle(color: Colors.lightBlue, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  height(height: 7),

                  // Top Comments List
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
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.account_circle, size: 22, color: Colors.black),
                                    const SizedBox(width: 6),
                                    Text("User name", style: fontStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    const Spacer(),
                                    const Icon(Icons.star, color: AppColors.ratingColor, size: 16),
                                    const SizedBox(width: 2),
                                    Text('4/5', style: fontStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                                height(height: 4),
                                Text(
                                  "Nice movie. Good performances!",
                                  style: fontStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                height(height: 4),
                                Text(
                                  "a few moments ago",
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
          ),
        ],
      ),
    );
  }
}
