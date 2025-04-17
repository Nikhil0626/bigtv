import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../globel_keys/global_variables_data.dart';
import '../../../main.dart';
import '../../../screens/home_screen/home_provider/provider.dart';
import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
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
  GlobalKey previewContainer = GlobalKey();
  final PageController _pageController = PageController();
  TransformationController _transformationController = TransformationController();
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    context.read<NewsPostsProvider>().paperSet(widget.imageUrls[0].imageUrl,0);

    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if (scale > 1.0 && !_isZoomed) {
        setState(() {
          _isZoomed = true;
        });
      } else if (scale <= 1.0 && _isZoomed) {
        setState(() {
          _isZoomed = false;
        });
      }
    });
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
            Column(
              children: [
                Padding(
                  padding:  EdgeInsets.only(top: MediaQuery.of(context).padding.top+20),
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Row(
                      children: [
                        width(width: 20),
                        Icon(
                          Icons.arrow_back_outlined,
                          size: 24,
                        ),
                        width(width: 20),
                        Text(
                          widget.name,
                          style: fontStyle(fontSize: 20,fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                ),
                width(width: 10),
                Expanded(
                  child: Stack(
                    children: [
                      Consumer<NewsPostsProvider>(
                          builder: (_,newsPostsProvider,__) {
                            return Listener(
                              onPointerMove: _isZoomed ? (_) {} : null, // Prevent swipe when zoomed
                              child: PageView.builder(
                                controller: _pageController,
                                scrollDirection: Axis.horizontal,
                                physics: _isZoomed
                                    ? const NeverScrollableScrollPhysics()
                                    : const BouncingScrollPhysics(),
                                itemCount: widget.imageUrls.length,
                                itemBuilder: (context, index) {
                                  final imageUrl = widget.imageUrls[index].imageUrl.toString();

                                  return RepaintBoundary(
                                    key: previewContainer,
                                    child: Center(
                                      child: InteractiveViewer(
                                        transformationController: _transformationController,
                                        // boundaryMargin: const EdgeInsets.all(20),
                                        minScale: 1.0,
                                        maxScale: 10.0,
                                        panEnabled: true,
                                        // scaleEnabled: true,
                                        child:  CachedNetworkImage(
                                          imageUrl: imageUrl.toString(),
                                          height: MediaQuery.of(context).size.height ,
                                          width: MediaQuery.of(context).size.width,
                                          fit: BoxFit.fill,

                                          placeholder: (context, url) => Container(
                                            height: MediaQuery.of(context).size.height ,
                                            width: MediaQuery.of(context).size.width,
                                            color: AppColors.borderColor.withOpacity(.2),
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
                            );

                            ;
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
                            try {
                              RenderRepaintBoundary boundary =
                              previewContainer.currentContext!.findRenderObject() as RenderRepaintBoundary;

                              ui.Image image = await boundary.toImage(pixelRatio: .2);
                              ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                              Uint8List pngBytes = byteData!.buffer.asUint8List();

                              final directory = await getTemporaryDirectory();
                              final filePath = '${directory.path}/screenshot.png';
                              File imgFile = File(filePath);
                              await imgFile.writeAsBytes(pngBytes);

                              await Share.shareXFiles(
                                [XFile(filePath)],
                                text: 'Check this out!',
                              );
                            } catch (e) {
                              print("Error while capturing screenshot: $e");
                            }

                            // try {
                            //   // Download image
                            //   final response = await http.get(Uri.parse(widget.imageUrls[context.read<NewsPostsProvider>().currentPaperIndex].imageUrl.toString()));
                            //   final bytes = response.bodyBytes;
                            //
                            //   // Get temporary directory
                            //   final tempDir = await getTemporaryDirectory();
                            //   final file = File('${tempDir.path}/shared_image.jpg');
                            //
                            //   // Save image
                            //   await file.writeAsBytes(bytes);
                            //
                            //   // Share with text and image
                            //   await Share.shareXFiles(
                            //     [XFile(file.path)],
                            //     text: "gxfcgfgfgcuh",
                            //   );
                            // } catch (e) {
                            //   print('Sharing failed: $e');
                            // }

                            // sendShareDetails(context.read<FlipProvider>().userId, widget.postId, widget.postId.toString());

                            // Share.share('${widget.imageUrls[context.read<NewsPostsProvider>().currentPaperIndex].imageUrl}: ${widget.imageUrls[context.read<NewsPostsProvider>().currentPaperIndex].imageUrl}');


                            // try {
                            //   final image = await paperScreenShort.capture(
                            //     pixelRatio: 2,
                            //   );
                            //   if (image != null) {
                            //     final directory = await getTemporaryDirectory();
                            //     final imagePath = '${directory.path}/${widget.postId}.png';
                            //     final imageFile = File(imagePath);
                            //     await imageFile.writeAsBytes(image);
                            //
                            //     Share.shareXFiles([XFile(imageFile.path)],
                            //         text:  widget.imageUrls[context.read<NewsPostsProvider>().currentPaperIndex].imageUrl.toString());
                            //   } else {
                            //     CustomToast.showErrorToast(msg: "Failed to capture screenshot");
                            //   }
                            // } catch (e) {
                            //   CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                            // }
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
