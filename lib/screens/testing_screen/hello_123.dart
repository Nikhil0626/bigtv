// homeProvider.getAllPostList[index]['type'] == "Video"
// ? Padding(
// padding: const EdgeInsets.all(12.0),
// child: ClipRRect(
// borderRadius: BorderRadius.all(
// Radius.circular(12),
// ),
// child: SizedBox(
// height: 330,
// child: Stack(
// children: [
// VideoPreview(
// imageUrl: homeProvider.getAllPostList[index]['image_url'],
// url: homeProvider.getAllPostList[index]['video_url'] ?? "",
// isFoldable: false,
// ),
// Positioned(
// top: 10,
// right: 14,
// child: GestureDetector(
// onTap: () {
// context.read<SettingsProvider>().saveBookmarks(
// homeProvider.getAllPostList[index]['id'].toString(),
// );
// print("Bookmark saved");
// },
// child: Container(
// padding: EdgeInsets.all(7),
// decoration: BoxDecoration(
// color: Colors.black54,
// shape: BoxShape.circle,
// ),
// child: Icon(
// Icons.bookmark_outline,
// color: Colors.white,
// size: 20,
// ),
// ),
// ),
// ),
// ],
// ),
// ),
// ),
// )
//     : homeProvider.getAllPostList[index]['type'] == "GoogleAds"
// ? Padding(
// padding: const EdgeInsets.all(16.0),
// child: ClipRRect(
// borderRadius: BorderRadius.all(
// Radius.circular(12),
// ),
// child: SizedBox(
// height: 330.h,
// child: GoogleAdsView(
// article: homeProvider.getAllPostList[index],
// flipProvider: homeProvider,
// screenshotController: ScreenshotController(),
// isFoldable: false,
// ),
// ),
// ),
// )
//     : homeProvider.getAllPostList[index]['type'] == "Image"
// ? Padding(
// padding: const EdgeInsets.all(16.0),
// child: SizedBox(
// height: 330.h,
// child: Stack(
// children: [
// ClipRRect(
// borderRadius: BorderRadius.all(
// Radius.circular(16.r),
// ),
// child: CachedNetworkImage(
// imageUrl: homeProvider.getAllPostList[index]['image_url'],
// height: 330.h,
// width: MediaQuery.of(context).size.width,
// fit: BoxFit.fill,
// placeholder: (context, url) => Container(
// height: 330.h,
// width: MediaQuery.of(context).size.width,
// color: AppColors.borderColor.withOpacity(.2),
// ),
// errorWidget: (context, url, error) => Container(
// height: 330.h,
// width: MediaQuery.of(context).size.width,
// color: Colors.grey.shade200,
// child: Center(
// child: Icon(
// Icons.image,
// size: 100,
// color: Colors.grey.shade300,
// ),
// ),
// ),
// ),
// ),
// Positioned(
// top: 10,
// right: 14,
// child: GestureDetector(
// onTap: () {
// context.read<SettingsProvider>().saveBookmarks(homeProvider.getAllPostList[index]['id'].toString());
// print("");
// },
// child: Container(
// padding: EdgeInsets.all(7),
// decoration: BoxDecoration(
// color: Colors.black54,
// shape: BoxShape.circle,
// ),
// child: Icon(
// Icons.bookmark_outline,
// color: Colors.white,
// size: 20,
// ),
// ),
// ),
// ),
// ],
// ),
// ),
// )
//     : homeProvider.getAllPostList[index]['type'] == "Gallery"
// ? Padding(
// padding: const EdgeInsets.all(12.0),
// child: SizedBox(
// height: 330.h,
// child: ClipRRect(
// borderRadius: BorderRadius.all(Radius.circular(12)),
// child: Stack(
// children: [
// FullPageCarousel(
// isHome: true,
// imageUrls: homeProvider.getAllPostList[index]['gallery'] ?? [],
// postDetails: homeProvider.getAllPostList[index],
// ),
// Positioned(
// top: 10,
// right: 14,
// child: GestureDetector(
// onTap: () {
// context.read<SettingsProvider>().saveBookmarks(
// homeProvider.getAllPostList[index]['id'].toString(),
// );
// print("");
// },
// child: Container(
// padding: EdgeInsets.all(7),
// decoration: BoxDecoration(
// color: Colors.black54,
// shape: BoxShape.circle,
// ),
// child: Icon(
// Icons.bookmark_outline,
// color: Colors.white,
// size: 20,
// ),
// ),
// ),
// ),
// ],
// ),
// ),
// ),
// )
// :