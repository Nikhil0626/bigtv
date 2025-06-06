import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class  HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Container(
              height: MediaQuery.of(context).size.height/2-50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 20),



            Container(
              height: 20,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 8),   Container(
              height: 20,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 8),   Container(
              height: 20,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: double.infinity,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: MediaQuery.of(context).size.width * 0.7,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Container(
              height: 20,
              width: 200,
              color: Colors.white,
            ),
            const SizedBox(height: 8), Container(
              height: 20,
              width: 150,
              color: Colors.white,
            ),
            const SizedBox(height: 8),

            // Subtitle
            Container(
              height: 15,
              width: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
