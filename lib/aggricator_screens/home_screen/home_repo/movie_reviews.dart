import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'list_reviews.dart';

class MovieRatings extends StatefulWidget {
  const MovieRatings({super.key});

  @override
  State<MovieRatings> createState() => _MovieRatingsState();
}

class _MovieRatingsState extends State<MovieRatings> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
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
                      "https://pbs.twimg.com/media/GbrurlobsAAH2q8.jpg:large",
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * .35,
                      width: MediaQuery.of(context).size.width,
                    ),
                    Positioned(
                      top: 35,
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
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 18),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 70,
                        width: 400,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Chota Meter",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  height(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.lightBlue, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        "3.5/5",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            width(width: 20),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Critic Rating",
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                  height(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.lightBlue, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        "4.5/5",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      height(height: 15),
                      Text(
                        "కుబేర సినిమా టీజర్ మీకు ఎలా అనిపించింది?",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      height(height: 8),
                      Row(
                        children: List.generate(5, (index) {
                          return Row(
                            children: [
                              Icon(
                                Icons.star_outline,
                                color: Colors.grey.shade700,
                                size: 37,
                              ),
                              if (index != 4) SizedBox(width: 35), // adjust space here
                            ],
                          );
                        }),
                      ),

                      height(height: 10),
                      height(height: 8),
                      Container(
                        height: 42,
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade300),
                        ),
                        child: Text(
                          "Type your comment here (optional)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                      height(height: 15),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Submit",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      height(height: 10),
                      Row(
                        children: [
                          Text(
                            "Critics Reviews",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          Spacer(),
                          Text(
                            "184.33k",
                            style: TextStyle(color: Colors.lightBlue, fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ListReviews(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.keyboard_arrow_right_outlined,
                              color: Colors.lightBlue,
                              size: 29,
                            ),
                          ),
                        ],
                      ),
                      height(height: 8),
                      SizedBox(
                        height: 135,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 20,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 280,
                              margin: EdgeInsets.only(right: 12),
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.lightBlue),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_circle, size: 30, color: Colors.black),
                                      SizedBox(width: 8),
                                      Text(
                                        "User name",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(Icons.star, color: Colors.orange, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        "4/5",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  height(height: 10),
                                  Text(
                                    "Lorem ipsum dolor sit amet, consectetur",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  height(height: 8),
                                  Text(
                                    "A few moments ago",
                                    style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox height({required double height}) => SizedBox(height: height);

  SizedBox width({required double width}) => SizedBox(width: width);
}
