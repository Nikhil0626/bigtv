import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'reels_screen_preview.dart'; // Import the preview screen
import '../reels_provider/reels_providers.dart'; // Import the provider

class ReelsScreenList extends StatefulWidget {
  const ReelsScreenList({super.key});

  @override
  State<ReelsScreenList> createState() => _ReelsScreenListState();
}

class _ReelsScreenListState extends State<ReelsScreenList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelsProviders>().getReels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reelsDataList = context.watch<ReelsProviders>().reelsDataList;

    return Scaffold(
      backgroundColor: Colors.white,
      body: reelsDataList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: GridView.builder(
          itemCount: reelsDataList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
          ),
          itemBuilder: (context, index) {
            final card = reelsDataList[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReelPreviewScreen(
                      initialIndex: index, // Pass the tapped index
                    ),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: card['thumbnailUrl'] ?? '',
                      fit: BoxFit.cover, // Ensure image fills the card
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, color: Colors.red),
                    ),

                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Title (Main Text)
                            Text(
                              card['title'] ?? "No title",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 1.h),


                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(card['publisherImage']??''),
                                    radius: 10,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  card['publisher'] ?? "Unknown",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white70,
                                    fontSize: 13.sp,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      top: 8.w,
                      right: 8.w,
                      child: Container(
                        height: 30.w,
                        width: 30.w,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(15.r), // Fully curved
                        ),
                        child: Icon(Icons.bookmark_border, color: Colors.white, size: 20.sp),
                      ),
                    ),

                    Positioned(
                      bottom: 8.h,
                      right: 8.w,
                      child: Icon(Icons.more_vert, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
