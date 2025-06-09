import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class  Banner300x50sizeLoading extends StatelessWidget {
  const Banner300x50sizeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:  SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 50,

        )
      ),
    );
  }
}