import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(

        backgroundColor: Colors.white,
        body: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Stack(
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
                  ],
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
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "News",
                            style: TextStyle(
                              color: Colors.lightBlue,
                              fontSize: 14,
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
            height(height: 25.h),
            Text(
              "8 వసంతాలు సినిమా ఎలా అనిపిస్తుంది?",
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
            ),
            height(height: 15.h),
            Container(
              height: 45.h,
              width: 327.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "బాగుంది",
                  style: TextStyle(color: Colors.grey.shade900, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            height(height: 10.h),
            Container(
              height: 45.h,
              width: 327.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "బాగలేదు",
                  style: TextStyle(color: Colors.grey.shade900, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            height(height: 10.h),
            Container(
              height: 45.h,
              width: 327.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "తెలియదు",
                  style: TextStyle(color: Colors.grey.shade900, fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            height(height: 20.h),
            Container(
              height: 45.h,
              width: 327.w,
              decoration: BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                onTap: () {},
                child: Center(
                  child: Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
