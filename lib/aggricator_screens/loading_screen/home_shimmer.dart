import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class  HomeShimmer extends StatelessWidget {
  const HomeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF1E293B) : Colors.grey.shade300;
    final highlightColor = isDark ? const Color(0xFF334155) : Colors.grey.shade100;
    final blockColor = isDark ? const Color(0xFF334155) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              Container(
                height: MediaQuery.of(context).size.height / 2 - 50,
                decoration: BoxDecoration(
                  color: blockColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              height(height: 20),

              Container(
                height: 20,
                width: double.infinity,
                color: blockColor,
              ),
              height(height: 8),
              Container(
                height: 20,
                width: double.infinity,
                color: blockColor,
              ),
              height(height: 8),
              Container(
                height: 20,
                width: double.infinity,
                color: blockColor,
              ),
              height(height: 8),
              Container(
                height: 20,
                width: double.infinity,
                color: blockColor,
              ),
              height(height: 8),
              Container(
                height: 20,
                width: MediaQuery.of(context).size.width * 0.7,
                color: blockColor,
              ),
              height(height: 8),
              Container(
                height: 20,
                width: 200,
                color: blockColor,
              ),
              height(height: 8),
              Container(
                height: 20,
                width: 150,
                color: blockColor,
              ),
              height(height: 8),

              // Subtitle
              Container(
                height: 15,
                width: 100,
                color: blockColor,
              ),
              height(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
