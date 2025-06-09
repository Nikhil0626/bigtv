import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'home_provider/home_provider.dart';
import 'main_screen_byts_view.dart';

/// ✅ Custom scroll physics to increase flipping speed
class FastPageScrollPhysics extends PageScrollPhysics {
  const FastPageScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  FastPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return FastPageScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Duration get transitionDuration => Duration.zero;}

class MainScreenPageView extends StatefulWidget {
  final int startIndex;
  final bool isAiTags;
  final String tagName;
  final String tagId;

  const MainScreenPageView({
    super.key,
    this.startIndex = 0,
    this.isAiTags = false,
    this.tagName = "",
    this.tagId = "",
  });

  @override
  _MainScreenPageViewState createState() => _MainScreenPageViewState();
}

class _MainScreenPageViewState extends State<MainScreenPageView> {
  late PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.startIndex);
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          if (homeProvider.getAllPostList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final articles = homeProvider.getAllPostList;

          return Column(
            children: [
              if (widget.isAiTags)
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Row(
                      children: [
                        width(width: 10),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        width(width: 10),
                        Expanded(
                          child: Text(
                            widget.tagName,
                            style: fontStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(2.sp),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: AppColors.loginNumberBg,
                          ),
                          child: Text(
                            "${(widget.startIndex + 1)}/${articles.length}",
                            style: fontStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.textColor,
                            ),
                          ),
                        ),
                        width(width: 10),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: Stack(
                  children: [
                    ...List.generate(articles.length, (index) {
                      final double position = index - _currentPage;

                      if (position < -1 || position > 1) return const SizedBox();

                      if (position <= 0) {
                        return Positioned.fill(
                          child: MainScreenBytView(
                            article: articles[index],
                          ),
                        );
                      }

                      final double visiblePortion = (1 - position).clamp(0.0, 1.0);
                      final double topOffset = screenHeight * (1 - visiblePortion);

                      return Positioned(
                        top: topOffset,
                        left: 0,
                        right: 0,
                        height: screenHeight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(32),
                            ),
                            child: MainScreenBytView(
                              article: articles[index],
                            ),
                          ),
                        ),
                      );
                    }),

                    // Transparent PageView to handle vertical scroll with faster speed
                    PageView.builder(
                      controller: _pageController,
                      scrollDirection: Axis.vertical,
                      physics: const FastPageScrollPhysics(),
                      itemCount: articles.length,
                      itemBuilder: (_, __) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
