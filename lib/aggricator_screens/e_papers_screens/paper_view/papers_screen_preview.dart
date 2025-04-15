import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

import '../../../globel_keys/global_variables_data.dart';
import '../../../screens/home_screen/home_provider/provider.dart';
import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_toasts.dart';
import '../../home_screen/news_posts_provider.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../paper_models/single_paper_model.dart';

class PapersScreenPreview extends StatefulWidget {
  final String postId;
  final List<PageData> imageUrls;
  final String name;

  PapersScreenPreview({super.key, required this.imageUrls, this.name = "Paper", required this.postId});

  @override
  State<PapersScreenPreview> createState() => _PapersScreenPreviewState();
}

class _PapersScreenPreviewState extends State<PapersScreenPreview> {
  final ScreenshotController paperScreenShort = ScreenshotController();
@override
  void initState() {
  context.read<NewsPostsProvider>().paperSet(widget.imageUrls[0].imageUrl,0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Better visibility
      body: InkWell(
        onTap: () {
        context.read<NewsPostsProvider>().isPaperShowing();
        },
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10, right: 10),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back_outlined,
                          size: 24,
                        ),
                        width(width: 20),
                        Text(
                          widget.name,
                          style: fontStyle(fontSize: 20),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        Consumer<NewsPostsProvider>(
                          builder: (_,newsPostsProvider,__) {
                            return Screenshot(
                                controller: paperScreenShort,
                                child: Center(
                                  child: InteractiveViewer(
                                    boundaryMargin: const EdgeInsets.all(6),
                                    minScale: 1.0,
                                    maxScale: 10.0, // Maximum zoom level
                                    child: Image.network(
                                      newsPostsProvider.currentPaper.toString()!=""?newsPostsProvider.currentPaper.toString(): widget.imageUrls[0].imageUrl.toString(),
                                      fit: BoxFit.fill,
                                      // Adjust for better fit
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1) : null,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Text(
                                            'Failed to load image',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ));
                          }
                        ),

                        Positioned(
                          top: 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: () async {
                              EventRepo().sendEvent({
                                "key": "share_via_articles",
                                "data": {
                                  "device_id": "${GlobalVariables().deviceId}",
                                  "userId": context.read<FlipProvider>().userId ?? "",
                                  "postId": widget.postId.toString(),
                                  "isWhatAppShare": false,
                                }
                              });
                              context.read<SettingsProvider>().saveBookmarks(
                                widget.imageUrls[context.read<NewsPostsProvider>().currentPaperIndex].id.toString(),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.bookmark_border,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 20,
                          right: 80,
                          child: GestureDetector(
                            onTap: () async {
                              EventRepo().sendEvent({
                                "key": "share_via_articles",
                                "data": {
                                  "device_id": "${GlobalVariables().deviceId}",
                                  "userId": context.read<FlipProvider>().userId ?? "",
                                  "postId": widget.postId.toString(),
                                  "isWhatAppShare": false,
                                }
                              });

                              sendShareDetails(context.read<FlipProvider>().userId, widget.postId, widget.postId.toString());
                              try {
                                final image = await paperScreenShort.capture(
                                  pixelRatio: 0.5,
                                );
                                if (image != null) {
                                  final directory = await getTemporaryDirectory();
                                  final imagePath = '${directory.path}/${widget.postId}.png';
                                  final imageFile = File(imagePath);
                                  await imageFile.writeAsBytes(image);

                                  // Share.shareXFiles([XFile(imageFile.path)],
                                  //     text:  widget.imageUrl);
                                } else {
                                  CustomToast.showErrorToast(msg: "Failed to capture screenshot");
                                }
                              } catch (e) {
                                CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.ios_share_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if( context.watch<NewsPostsProvider>().isBottomIsShow)
            Positioned(
              bottom: 0,

              child: Container(
                height: 170,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.ePaperCardColor,
                ),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.imageUrls.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: (){
                        context.read<NewsPostsProvider>().paperSet(widget.imageUrls[index].imageUrl,index);
                        context.read<NewsPostsProvider>().isPaperShowing();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: CachedNetworkImage(

                            imageUrl: widget.imageUrls[index].imageUrl.toString(),
                            height: 150,
                            width: 100,
                            fit: BoxFit.fill,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade200,
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Icon(
                                Icons.image,
                                size: 100,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
