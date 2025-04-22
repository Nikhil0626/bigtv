import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/e_papers_screens/paper_provider/epapers_provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../home_screen/news_posts_provider.dart';
import '../../settings_screen/settings_provider/settings_provider.dart';
import '../paper_models/single_paper_model.dart';

class PapersScreenPreview extends StatefulWidget {
  final String postId;
  final List<PageData> imageUrls;
  final String name;

  PapersScreenPreview({super.key, required this.imageUrls, this.name = "Back", required this.postId});

  @override
  State<PapersScreenPreview> createState() => _PapersScreenPreviewState();
}

class _PapersScreenPreviewState extends State<PapersScreenPreview> {
  final GlobalKey _repaintKey = GlobalKey();
  final PageController _pageController = PageController();
  List<TransformationController> _controllers = [];
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    context.read<NewsPostsProvider>().currentPaperIndex = 0;
    context.read<NewsPostsProvider>().currentPaper = widget.imageUrls[0].imageUrl.toString();

    _controllers = List.generate(
      widget.imageUrls.length,
          (_) => TransformationController(),
    );

    _controllers[0].addListener(_zoomListener);
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
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: Stack(
              children: [
                Column(
                  children: [
                    // Header
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        children: [
                          width(width: 20),
                          const Icon(Icons.arrow_back_outlined, size: 24),
                          width(width: 20),
                          Text(widget.name, style: fontStyle(fontSize: 20)),
                        ],
                      ),
                    ),

                    // PageView
                    Expanded(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: newsPostsProvider.isPaperShowing,
                            onScaleStart: (details) {
                              if (details.pointerCount == 2) {
                                setState(() {
                                  _isZoomed = true;
                                });
                              }
                            },
                            onScaleEnd: (details) {
                              setState(() {
                                _isZoomed = false;
                              });
                            },
                            onHorizontalDragEnd: (details) {
                              if (!_isZoomed) {
                                if (details.primaryVelocity! < 0 && _pageController.page != widget.imageUrls.length - 1) {
                                  _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                                } else if (details.primaryVelocity! > 0 && _pageController.page != 0) {
                                  _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                                }
                              }
                            },
                            child: PageView.builder(
                              controller: _pageController,
                              physics: _isZoomed
                                  ? const NeverScrollableScrollPhysics()
                                  : const BouncingScrollPhysics(),
                              itemCount: widget.imageUrls.length,
                              onPageChanged: (index) {
                                _controllers[newsPostsProvider.currentPaperIndex].removeListener(_zoomListener);

                                newsPostsProvider.currentPaperIndex = index;
                                newsPostsProvider.currentPaper = widget.imageUrls[index].imageUrl.toString();

                                _controllers[index].addListener(_zoomListener);
                              },
                              itemBuilder: (context, index) {
                                final imageUrl = widget.imageUrls[index].imageUrl;
                                return InteractiveViewer(
                                  transformationController: _controllers[index],
                                  minScale: 1.0,
                                  maxScale: 10.0,
                                  panEnabled: true,
                                  child: RepaintBoundary(
                                    key: _repaintKey,
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height,
                                      child: Image.network(
                                       imageUrl.toString(),
                                        fit: BoxFit.fill, // Adjust for better fit
                                        width: MediaQuery.of(context).size.width,
                                        height: MediaQuery.of(context).size.height,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null) return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress.expectedTotalBytes != null
                                                  ? loadingProgress.cumulativeBytesLoaded /
                                                  (loadingProgress.expectedTotalBytes ?? 1)
                                                  : null,
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
                                  ),
                                );
                              },
                            ),
                          ),

                          // Bookmark
                          Positioned(
                            top: 20,
                            right: 20,
                            child: Consumer<EPapersProvider>(
                                builder: (_, ePapersProvider, __) {
                                  return GestureDetector(
                                  onTap: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    final userId = prefs.getString("userId");
                                    final deviceId = prefs.getString("deviceId");
                                    EventRepo().sendEvent({
                                      "key": "share_via_articles",
                                      "data": {
                                        "device_id": deviceId,
                                        "userId": userId ?? "",
                                        "postId": widget.postId,
                                        "isWhatAppShare": false,
                                      }
                                    });
                                    context.read<EPapersProvider>().isBookMarkPost(widget.imageUrls[newsPostsProvider.currentPaperIndex],context);
                                  },
                                  child:Container(
                                    padding: EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: (ePapersProvider.isBookMark.contains(widget.imageUrls[newsPostsProvider.currentPaperIndex].id.toString()) || widget.imageUrls[newsPostsProvider.currentPaperIndex].id== 1)
                                          ? AppColors.appButtonColor
                                          : Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      (ePapersProvider.isBookMark.contains(widget.imageUrls[newsPostsProvider.currentPaperIndex].id.toString()) || widget.imageUrls[newsPostsProvider.currentPaperIndex].id == 1)
                                          ? Icons.bookmark
                                          : Icons.bookmark_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                );
                              }
                            ),
                          ),

                          // Share
                          Positioned(
                            top: 20,
                            right: 80,
                            child: InkWell(
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                final userId = prefs.getString("userId");
                                final deviceId = prefs.getString("deviceId");

                                EventRepo().sendEvent({
                                  "key": "share_via_widget.articles",
                                  "data": {
                                    "device_id": deviceId,
                                    "userId": userId ?? "",
                                    "postId": widget.imageUrls[newsPostsProvider.currentPaperIndex].id,
                                    "isWhatAppShare": false,
                                  }
                                });

                                sendShareDetails(userId, widget.imageUrls[newsPostsProvider.currentPaperIndex].id, "");

                                try {
                                  RenderRepaintBoundary boundary = _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                  var image = await boundary.toImage(pixelRatio: 2.0);
                                  ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
                                  Uint8List pngBytes = byteData!.buffer.asUint8List();

                                  final directory = await getTemporaryDirectory();
                                  final imagePath = File('${directory.path}/${widget.imageUrls[newsPostsProvider.currentPaperIndex].id.toString()}.png');
                                  await imagePath.writeAsBytes(pngBytes);

                                  await Share.shareXFiles(
                                    [XFile(imagePath.path)],
                                    text: '${widget.imageUrls[newsPostsProvider.currentPaperIndex].imageUrl}',
                                  );
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
                                  height: 20,
                                  width: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Bottom Thumbnails
                if (newsPostsProvider.isBottomIsShow)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      height: 170,
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(color: AppColors.ePaperCardColor),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.imageUrls.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              newsPostsProvider.paperSet(widget.imageUrls[index].imageUrl, index);
                              newsPostsProvider.isPaperShowing();
                              _pageController.jumpToPage(index);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: widget.imageUrls[index].imageUrl.toString(),
                                  height: 150,
                                  width: 100,
                                  fit: BoxFit.fill,
                                  placeholder: (context, url) => Container(color: Colors.grey.shade200),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.image, size: 100, color: Colors.grey.shade300),
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
          );
        },
      ),
    );
  }
}
