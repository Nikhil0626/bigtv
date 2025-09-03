import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_provider/epapers_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../events_data/event_repo.dart';
import '../../home_screen/home_provider/home_provider.dart';
import '../../home_screen/home_provider/news_posts_provider.dart';

class PapersScreenPreview extends StatefulWidget {
  final String postId;
  final int isBookmarked;
  final List imageUrls;
  final String name;

  PapersScreenPreview({
    super.key,
    required this.imageUrls,
    this.name = "Back",
    required this.postId,
    this.isBookmarked = 0,
  });

  @override
  State<PapersScreenPreview> createState() => _PapersScreenPreviewState();
}

class _PapersScreenPreviewState extends State<PapersScreenPreview> {
  final GlobalKey _repaintKey = GlobalKey();
  final PageController _pageController = PageController();
  List<TransformationController> _controllers = [];
  bool _isZoomed = false;
  String postId = '0';
  int isBookmarked = 0;
  int currentIndex = 0;
  List<bool> _isImageLoaded = [];

  @override
  void initState() {
    super.initState();

    context.read<NewsPostsProvider>().currentPaperIndex = 0;
    context.read<NewsPostsProvider>().currentPaper = widget.imageUrls[0].imageUrl.toString();

    _controllers = List.generate(widget.imageUrls.length, (_) => TransformationController());
    _isImageLoaded = List.generate(widget.imageUrls.length, (_) => false);

    _controllers[0].addListener(_zoomListener);
    postId = widget.postId;
    isBookmarked = widget.isBookmarked;
  }

  void _zoomListener() {
    final zoom = _controllers[context.read<NewsPostsProvider>().currentPaperIndex].value.getMaxScaleOnAxis();
    if (zoom <= 1.0 && _isZoomed) {
      setState(() => _isZoomed = false);
    } else if (zoom > 1.0 && !_isZoomed) {
      setState(() => _isZoomed = true);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<NewsPostsProvider>(
        builder: (_, newsPostsProvider, __) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 6),
            child: Stack(
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          width(width: 20),
                          const Icon(Icons.arrow_back_outlined, size: 20),
                          width(width: 20),
                          Text(widget.name, style: newAppFont(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: newsPostsProvider.isPaperShowing,
                            child: PageView.builder(
                              controller: _pageController,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.imageUrls.length,
                              itemBuilder: (context, index) {
                                final imageUrl = widget.imageUrls[index].imageUrl;
                                return KeepAlive(
                                  keepAlive: true,
                                  child: InteractiveViewer(
                                    transformationController: _controllers[index],
                                    minScale: 1.0,
                                    maxScale: 6.0,
                                    panEnabled: true,
                                    child: RepaintBoundary(
                                      key: _repaintKey,
                                      child: SizedBox(
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        child: Stack(
                                          children: [
                                            ExtendedImage.network(
                                              imageUrl.toString(),
                                              fit: BoxFit.fill,
                                              width: MediaQuery.of(context).size.width,
                                              height: MediaQuery.of(context).size.height,
                                              loadStateChanged: (state) {
                                                switch (state.extendedImageLoadState) {
                                                  case LoadState.loading:
                                                    return const Center(child: CircularProgressIndicator());
                                                  case LoadState.completed:
                                                    return state.completedWidget;
                                                  case LoadState.failed:
                                                    return const Center(
                                                      child: Text(
                                                        'Failed to load image',
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    );
                                                }
                                              },
                                            ),
                                            Positioned(
                                              top: 20,
                                              right: 20,
                                              child: InkWell(
                                                onTap: () async {
                                                  // final url = 'https://enewspapers.s3.amazonaws.com/swetcha/2025-05-03/telangana/page_001.webp';
                                                  // final filename = 'page_001.webp';
                                                  //
                                                  // final dir = await getTemporaryDirectory();
                                                  // final filePath = '${dir.path}/$filename';
                                                  // final file = File(filePath);
                                                  //
                                                  // // Download only if not cached
                                                  // if (!await file.exists()) {
                                                  //   final response = await http.get(Uri.parse(url));
                                                  //   await file.writeAsBytes(response.bodyBytes);
                                                  // }
                                                  //
                                                  // // Share the cached or newly downloaded file
                                                  // Share.shareXFiles(
                                                  //   [XFile(file.path)],
                                                  //   text: 'Check out today’s front page!${url}',
                                                  // );

                                                  final prefs = await SharedPreferences.getInstance();
                                                  final userId = prefs.getString("userId");

                                                  sendShareDetails(userId, widget.imageUrls[newsPostsProvider.currentPaperIndex + 1].id, "");

                                                  try {
                                                    RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                                    var image = await boundary.toImage(pixelRatio: 3.0);
                                                    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
                                                    Uint8List pngBytes = byteData!.buffer.asUint8List();

                                                    final directory = await getTemporaryDirectory();
                                                    final imagePath = File('${directory.path}/${widget.imageUrls[newsPostsProvider.currentPaperIndex + 1].id.toString()}.png');
                                                    await imagePath.writeAsBytes(pngBytes);

                                                    await Share.shareXFiles(
                                                      [XFile(imagePath.path)],
                                                      text: '${widget.imageUrls[newsPostsProvider.currentPaperIndex + 1].imageUrl}',
                                                    );
                                                     EventRepo().addEvent({
                                                      "share": "Epaper",
                                                      "postId": widget.imageUrls[newsPostsProvider.currentPaperIndex],
                                                      "createAt": DateTime.now().toString(),
                                                       "postTitle":"",




                                                     }, "shared_article");
                                                  } catch (e) {
                                                    print("Error capturing image: $e");
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(10),
                                                  decoration: const BoxDecoration(
                                                    color: Colors.black54,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    "assets/svg/share.svg",
                                                    height: 16,
                                                    width: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (currentIndex != 0)
                            Positioned(
                              left: 10.sp,
                              top: MediaQuery.of(context).size.height / 2 - 50.sp,
                              child: Consumer<EPapersProvider>(
                                builder: (_, ePapersProvider, __) {
                                  return GestureDetector(
                                    onTap: () async {
                                      context.read<HomeProvider>().flipEvent('paper', widget.imageUrls[currentIndex].id, false);

                                      log("current ++= $currentIndex ---- lase    ${widget.imageUrls.length}");
                                      postId = widget.imageUrls[currentIndex].id.toString();
                                      isBookmarked = widget.imageUrls[currentIndex].isBookmarked == 0 ? 0 : 1;
                                      newsPostsProvider.paperSet(widget.imageUrls[currentIndex].imageUrl, currentIndex);
                                      currentIndex = currentIndex - 1;
                                      _pageController.jumpToPage(currentIndex);
                                      setState(() {});
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(20.r)),
                                      child: Container(
                                        height: 40.sp,
                                        width: 40.sp,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                        ),
                                        child: Center(
                                            child: Icon(
                                          Icons.arrow_back_ios_outlined,
                                          size: 20.sp,
                                          color: Colors.white,
                                        )),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (currentIndex != widget.imageUrls.length - 1)
                            Positioned(
                              right: 10.sp,
                              top: MediaQuery.of(context).size.height / 2 - 50.sp,
                              child: InkWell(
                                onTap: () async {
                                  context.read<HomeProvider>().flipEvent('paper', widget.imageUrls[currentIndex].id, true);
                                  log("current ++= $currentIndex ---- lase    ${widget.imageUrls.length}");
                                  postId = widget.imageUrls[currentIndex].id.toString();
                                  isBookmarked = widget.imageUrls[currentIndex].isBookmarked == 0 ? 0 : 1;
                                  newsPostsProvider.paperSet(widget.imageUrls[currentIndex].imageUrl, currentIndex);
                                  currentIndex = currentIndex + 1;
                                  _pageController.jumpToPage(currentIndex);
                                  setState(() {});
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(Radius.circular(20.r)),
                                  child: Container(
                                    height: 40.sp,
                                    width: 40.sp,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                    ),
                                    child: Center(
                                        child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 20.sp,
                                      color: Colors.white,
                                    )),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
