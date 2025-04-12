import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/screens/home_screen/home_provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_screen_byts_view.dart';

class MainScreenPageView extends StatefulWidget {
  final int startIndex; // 👈 Accept index to start from

  const MainScreenPageView({super.key, this.startIndex = 0});

  @override
  _MainScreenPageViewState createState() => _MainScreenPageViewState();
}

class _MainScreenPageViewState extends State<MainScreenPageView> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(widget.startIndex);
    });
  }

  void _scrollToIndex(int index) {
    if (index >= 0) {
      _pageController.jumpToPage(index); // For instant scroll
      // _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeInOut); // Smooth scroll
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HomeProvider>(
        builder: (_, homeProvider, __) {
          if (homeProvider.getAllPostList.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: homeProvider.getAllPostList.length,
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double position = 1.0;

                  if (_pageController.hasClients && _pageController.position.haveDimensions) {
                    double? page = _pageController.page ?? 0;
                    position = (1 - (page - index).abs()).clamp(0.0, 1.0);
                  }

                  return Opacity(
                    opacity: position,
                    child: Transform.translate(
                      offset: Offset(0, 50 * (1 - position)),
                      child: Container(
                        color: Colors.white,
                        child: MainScreenBytView(article: homeProvider.getAllPostList[index]),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
