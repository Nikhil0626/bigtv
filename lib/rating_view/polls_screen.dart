import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/app_fonts.dart';
import '../utils/app_spaces.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  List<String> options = ["బాగుంది", "బాగలేదు", "తెలియదు"];
  int? selectedIndex;
  List<int> votes = [0, 0, 0];

  int get totalVotes => votes.reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.network(
                    "https://cdn.gulte.com/wp-content/uploads/2025/06/8-Vasanthalu-movie-review-scaled.jpeg",
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * .35,
                    width: MediaQuery.of(context).size.width,
                  ),
                  Positioned(
                    top: 20,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.ios_share_outlined,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -20,
                    left: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 6, horizontal: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Chota ",
                              style: fontStyle(
                                color: Colors.black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "News",
                              style: fontStyle(
                                color: Colors.lightBlue,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              height(height: 25),
              Text(
                "8 వసంతాలు సినిమా ఎలా అనిపిస్తుంది?",
                style: fontStyle(
                  color: Colors.black,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              height(height: 15),
              ListView.builder(
                itemCount: options.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                      padding: EdgeInsets.all(8.0),
                      child: Container(
                        height: 45,
                        width: 327,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.lightBlue : Colors.white,
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    options[index],
                                    style: fontStyle(
                                      color: isSelected ? Colors.white : Colors.grey.shade900,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: isSelected
                                      ? Text(
                                          '${percentage.toStringAsFixed(1)}% • ${votes[index]} votes',
                                          style: fontStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      : SizedBox(),
                                ),
                              ),
                              width(width: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              height(height: 20),
              Container(
                height: 45,
                width: 327,
                decoration: BoxDecoration(
                  color: selectedIndex != null ? Colors.lightBlue : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: InkWell(
                  onTap: selectedIndex != null
                      ? () {
                          // Submit logic here
                          print("Submitted option: ${options[selectedIndex!]}");
                        }
                      : null,
                  child: Center(
                    child: Text(
                      "Submit",
                      style: fontStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              height(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
