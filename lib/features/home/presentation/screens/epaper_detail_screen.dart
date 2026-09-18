import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/features/home/presentation/providers/epaper_provider.dart';
import 'package:chotanews/services/epaper_share_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';


class EpaperDetailScreen extends StatefulWidget {
  final Map<String, dynamic> epaper;

  const EpaperDetailScreen({super.key, required this.epaper});

  @override
  State<EpaperDetailScreen> createState() => _EpaperDetailScreenState();
}

class _EpaperDetailScreenState extends State<EpaperDetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    context.read<EpaperProvider>().resetDetailState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> paperImages = widget.epaper['paperImages'] ?? [];

    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<EpaperProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              paperImages.isEmpty
                  ? const Center(
                      child: Text("No images found",
                          style: TextStyle(color: Colors.white)))
                  : PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(), // Blocks swipe, forces arrow usage
                      itemCount: paperImages.length,
                      onPageChanged: (index) {
                        provider.setCurrentPage(index);
                      },
                      itemBuilder: (context, index) {
                        final imageUrl = paperImages[index];
                        return InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 8.0,
                          child: GestureDetector(
                            onTap: () {
                              provider.toggleOverlay();
                            },
                            child: SizedBox(
                              width: size.width,
                              height: size.height,
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.fill, // Ensures no blank spaces and no content is cropped
                                  placeholder: (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey[800]!,
                                    highlightColor: Colors.grey[600]!,
                                    child: Container(color: Colors.black),
                                  ),
                                  errorWidget: (context, url, error) => const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error, color: Colors.white, size: 40),
                                      SizedBox(height: 8),
                                      Text("Failed to load image",
                                          style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                            ),
                          ),
                        );
                      },
                    ),
              
              // Back Button
              if (provider.showOverlay)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 16,
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                    ),
                  ),
                ),

              // Top Right Action Buttons (WhatsApp Direct Share & General Share)
              if (provider.showOverlay)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          EpaperShareHelper.shareIndividualPage(
                            context: context,
                            epaper: widget.epaper,
                            pageIndex: provider.currentPage,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset("assets/images/WhatsApp_icon.png", height: 24, width: 24),
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          _showShareBottomSheet(context, widget.epaper, provider.currentPage);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.share, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
                
              // Left Arrow
              if (provider.showOverlay && provider.currentPage > 0)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: InkWell(
                      onTap: () {
                        if (provider.currentPage > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 12),
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
                
              // Right Arrow
              if (provider.showOverlay && provider.currentPage < paperImages.length - 1)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: InkWell(
                      onTap: () {
                        if (provider.currentPage < paperImages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 12),
                        decoration: const BoxDecoration(
                          color: Colors.grey,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),

              if (provider.showOverlay && paperImages.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 140,
                    color: Colors.black.withValues(alpha: 0.7),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: SafeArea(
                      top: false,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: paperImages.length,
                        itemBuilder: (context, index) {
                          final imageUrl = paperImages[index];
                          return GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                index,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8.0),
                              width: 80,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: provider.currentPage == index
                                      ? const Color(0xFFE31E24) // AppColorTokens.primaryRed
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Shimmer.fromColors(
                                  baseColor: Colors.grey[800]!,
                                  highlightColor: Colors.grey[600]!,
                                  child: Container(color: Colors.black),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error, color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showShareBottomSheet(BuildContext context, Map<String, dynamic> epaper, int currentPage) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Share E-Paper',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image.asset("assets/images/WhatsApp_icon.png", height: 32, width: 32),
                  ),
                  title: const Text('Share Current Page to WhatsApp', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Share page image directly with URL link'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    EpaperShareHelper.shareIndividualPage(
                      context: context,
                      epaper: epaper,
                      pageIndex: currentPage,
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE31E24),
                    child: Icon(Icons.picture_as_pdf, color: Colors.white),
                  ),
                  title: const Text('Share Full E-Paper (PDF)', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Compile all pages into a single PDF document'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    EpaperShareHelper.shareAsPdf(
                      context: context,
                      epaper: epaper,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
