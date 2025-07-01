import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';

class ListReviews extends StatefulWidget {
  const ListReviews({super.key});

  @override
  State<ListReviews> createState() => _ListReviewsState();
}

class _ListReviewsState extends State<ListReviews> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "కుబేర సినిమా టీజర్",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "overall Reviews",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          height(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.star,
                color: Colors.orange,
                size: 28,
              ),
              width(width: 7),
              Text(
                "3.5/5",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          height(height: 20),
          Container(
            height: 600,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Most helpful reviews",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () {
                        // Add your filter action here
                      },
                      icon: Icon(
                        Icons.filter_list_rounded,
                        color: Colors.black,
                        size: 25,
                      ),
                    )
                  ],
                ),
                height(height: 12),
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 145,
                        width: 280,
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.lightBlue.shade200),
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_circle, size: 35, color: Colors.black),
                                SizedBox(width: 8),
                                Text(
                                  "User name",
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                ),
                                Spacer(),
                                Icon(Icons.star, color: Colors.orange, size: 23),
                                SizedBox(width: 4),
                                Text(
                                  "4/5",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                              ],
                            ),
                            height(height: 10),
                            Text(
                              "Lorem ipsum dolor sit amet, consectetur and Lorem ipsum dolor sit amet, consectetur ",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                              maxLines: 2,
                            ),
                            height(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "1 min ago",
                                  style: TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
