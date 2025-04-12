import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/reels_screens/reels_view/reels_screen_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
 // Import the preview screen

class ReelsScreenList extends StatefulWidget {
  const ReelsScreenList({super.key});

  @override
  State<ReelsScreenList> createState() => _ReelsScreenListState();
}

class _ReelsScreenListState extends State<ReelsScreenList> {
  final List<Map<String, dynamic>> _cardData = [
    {
      'id': 1,
      'text': 'Rohith Sharma',
      'subtext': 'BIG TV',
      'thumbnail': 'https://img.youtube.com/vi/D7DYyHbDJE4/maxresdefault.jpg',
      'url': 'https://youtube.com/shorts/D7DYyHbDJE4'
    },
    {
      'id': 2,
      'text': 'Virat Kohli',
      'subtext': 'V6 Telugu',
      'thumbnail': 'https://img.youtube.com/vi/kjqKDjjLuc8/maxresdefault.jpg',
      'url': 'https://youtube.com/shorts/kjqKDjjLuc8?si=e-KfiWAwHEm0mXWY'
    },
    {
      'id': 3,
      'text': 'Sachin Tendulkar',
      'subtext': 'BIG TV',
      'thumbnail': 'https://img.youtube.com/vi/tyC7zT5xWkE/maxresdefault.jpg',
      'url': 'https://youtube.com/shorts/tyC7zT5xWkE'
    },
    {
      'id': 4,
      'text': 'MS Dhoni',
      'subtext': 'BIG TV',
      'thumbnail': 'https://img.youtube.com/vi/AsPdLV-e4Us/maxresdefault.jpg',
      'url': 'https://youtube.com/shorts/AsPdLV-e4Us'
    },
    {
      'id': 5,
      'text': 'AB de Villiers',
      'subtext': 'BIG TV',
      'thumbnail': 'https://img.youtube.com/vi/kSeonA9eJi0/maxresdefault.jpg',
      'url': 'https://youtube.com/shorts/kSeonA9eJi0'
    },
    {
      'id': 6,
      'text': 'Chris Gayle',
      'subtext': 'BIG TV',
      'thumbnail': 'https://img.youtube.com/vi/BM0htuPE5pU/maxresdefault.jpg',
      'url': 'https://youtube.com/shorts/BM0htuPE5pU'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: GridView.builder(
          itemCount: _cardData.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
          ),
          itemBuilder: (context, index) {
            final card = _cardData[index];
            return GestureDetector(
              onTap: () {
                // Navigate to ReelPreviewScreen with the selected index
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
                borderRadius: BorderRadius.circular(16.r), // Fully rounded card
                child: Stack(
                  children: [
                    // Thumbnail Image with Rounded Corners
                    CachedNetworkImage(
                      imageUrl: card['thumbnail'],
                      fit: BoxFit.cover, // Ensure image fills the card
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.error, color: Colors.red),
                    ),
                    // Dark Gradient Overlay at Bottom for better text visibility
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
                              card['text'] ?? "No title",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 14.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),

                            // Movie Icon & "BIG TV" Text in One Line
                            Row(
                              children: [
                                Icon(Icons.movie, color: Colors.white, size: 18.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  card['subtext'] ?? "No subtext",
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

                    // Bookmark Icon (Top-Right)
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

                    // More Icon (Bottom-Right)
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
