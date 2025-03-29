
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';





class PapersScreenList extends StatelessWidget {
  final List<Map<String, String>> newsItems = [
    {
      "image":"https://enewspapers.s3.amazonaws.com/sakshi/2025-03-28/andhra_pradesh_main/page_001.png",
      "title": "Rohit Sharma powers India to series win",
      "source": "Star Sports",
    },
    {
      "image":"https://enewspapers.s3.amazonaws.com/sakshi/2025-03-28/andhra_pradesh_main/page_002.png",
      "title": "A newly detected asteroid could pose...",
      "source": "India Today",
    },
    {
      "image": "https://enewspapers.s3.amazonaws.com/sakshi/2025-03-28/andhra_pradesh_main/page_003.png",
      "title": "Reason behind AAP defeat in Delhi",
      "source": "Hindustan Times",
    },
    {
      "image": "https://enewspapers.s3.amazonaws.com/sakshi/2025-03-28/andhra_pradesh_main/page_001.png",
      "title": "Thandel on track to post decent total",
      "source": "Zee5",
    },
    {
      "image":"https://enewspapers.s3.amazonaws.com/sakshi/2025-03-28/andhra_pradesh_main/page_001.png",
      "title": "Rohit Sharma powers India to series win",
      "source": "Star Sports",
    },
    {
      "image":"https://enewspapers.s3.amazonaws.com/sakshi/2025-03-28/andhra_pradesh_main/page_002.png",
      "title": "A newly detected asteroid could pose...",
      "source": "India Today",
    },
    {
      "image": "https://enewspapers.s3.amazonaws.com/sakshi/2025-03-28/andhra_pradesh_main/page_003.png",
      "title": "Reason behind AAP defeat in Delhi",
      "source": "Hindustan Times",
    },
    {
      "image": "https://enewspapers.s3.amazonaws.com/sakshi/2025-03-28/andhra_pradesh_main/page_001.png",
      "title": "Thandel on track to post decent total",
      "source": "Zee5",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 0, left: 10, right: 10), // Adjusted for safe area
        child: GridView.builder(
          itemCount: newsItems.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.all( Radius.circular(12.r)),
                    child: Image.network(newsItems[index]["image"]!, fit: BoxFit.fill, width: double.infinity),
                  ),


                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackgroundColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.r),
                          bottomRight: Radius.circular(12.r),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Ensures the container fits its content
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            newsItems[index]["title"]!,
                            style: fontStyle(fontWeight: FontWeight.w600, color: AppColors.textColor,fontSize: 12.sp),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4), // Adding space
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                newsItems[index]["source"]!,
                                style: TextStyle(fontSize: 12, color:AppColors.textColor,),
                              ),
                              Icon(Icons.more_vert, color: AppColors.textColor,),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      height: 24.w,
                        width: 24.w,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.8),
                            borderRadius: BorderRadius.all(Radius.circular(12.r))),
                        child: Icon(Icons.bookmark_border, color: Colors.white,size: 20.sp,)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
