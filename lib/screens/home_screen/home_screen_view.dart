import 'package:chotanews/screens/home_screen/botton_actions.dart';
import 'package:chotanews/screens/home_screen/home_bloc.dart';
import 'package:chotanews/screens/home_screen/home_state.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import '../../utils/app_colors.dart';
import '../../utils/bottom_navigation_items.dart';
import '../videos_main/video_views/video_preview.dart';
import 'home_event.dart';
import 'images_view.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  final CardSwiperController controller = CardSwiperController();
  bool _areRowsVisible = true; // State to toggle visibility

  @override
  void initState() {
    context.read<HomeBloc>().add(GetAllNewsFeed());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          BlocConsumer<HomeBloc, HomeScreenState>(
              listener: (context, state) {},
              builder: (context, state) {
                return Container(
                  color: Colors.transparent,
                  // Avoid null or fully transparent color
                  width: double.infinity,
                  height: double.infinity,
                  child: state is InitialHomeScreenState
                      ? Container(
                          color: Colors.grey,
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : state is SuccessHomeScreenState
                          ? CardSwiper(
                              controller: controller,
                              cardsCount: state.getAllHomeScreenNews.length,
                              onSwipe:
                                  (previousIndex, currentIndex, direction) {
                                context.read<HomeBloc>().add(OnSwipeCard(
                                    previousIndex: previousIndex,
                                    currentIndex: currentIndex!,
                                    direction: direction));
                                return true;
                              },
                              onUndo: _onUndo,
                              numberOfCardsDisplayed: 2,
                              maxAngle: 0,
                              threshold: 1,
                              isLoop: false,
                              allowedSwipeDirection:
                                  const AllowedSwipeDirection.symmetric(
                                      vertical: true),
                              padding: const EdgeInsets.all(0),
                              cardBuilder: (
                                context,
                                index,
                                horizontalThresholdPercentage,
                                verticalThresholdPercentage,
                              ) =>
                                  GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () {
                                  setState(() {
                                    _areRowsVisible = !_areRowsVisible;
                                  });
                                },
                                child: state.pageType == "Image"
                                    ? ClipRRect(
                                        child: Image.network(
                                          state.getAllHomeScreenNews[index]
                                              .imageUrl.url
                                              .toString(),
                                          fit: BoxFit.fill,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      )
                                    : state.pageType == "Gallery"
                                        ? CarouselScreen(
                                            imageList: state
                                                    .getAllHomeScreenNews[index]
                                                    .gallery ??
                                                [],
                                          )
                                        : Container(
                                            decoration: BoxDecoration(
                                              color: state.pageType == "Video"
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                            child: Stack(
                                              // crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      2,
                                                  child: state.pageType ==
                                                          "Video"
                                                      ? VideoPreview(
                                                          url: state
                                                              .getAllHomeScreenNews[
                                                                  index]
                                                              .videoUrl!
                                                              .url
                                                              .toString(),
                                                        )
                                                      : state
                                                                  .getAllHomeScreenNews[
                                                                      index]
                                                                  .imageUrl
                                                                  .url
                                                                  .toString() !=
                                                              null
                                                          ? Image.network(
                                                              state
                                                                  .getAllHomeScreenNews[
                                                                      index]
                                                                  .imageUrl
                                                                  .url
                                                                  .toString(),
                                                              fit: BoxFit.cover,
                                                              width:
                                                                  MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width,
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height /
                                                                  2,
                                                            )
                                                          : const SizedBox
                                                              .shrink(),
                                                ),
                                                Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 16,
                                                        vertical: 8),
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            2,
                                                    decoration: const BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        30),
                                                                topRight: Radius
                                                                    .circular(
                                                                        30))),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          state
                                                                  .getAllHomeScreenNews[
                                                                      index]
                                                                  .title ??
                                                              "No Title",
                                                          style: fontStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        height(height: 10),
                                                        Text(
                                                          state.pageType ??
                                                              "No Title",
                                                          style: fontStyle(
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        height(height: 16),
                                                        Text(
                                                          state
                                                              .getAllHomeScreenNews[
                                                                  index]
                                                              .content,
                                                          style: fontStyle(
                                                            fontSize: 16,
                                                            color: Colors
                                                                .grey[800],
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        const Divider(
                                                          color: AppColors
                                                              .borderColor,
                                                        ),
                                                        height(height: 4),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            BottomActions(
                                                              icon:
                                                                  Icons.refresh,
                                                              label: 'రిలోడ్',
                                                              onTap: () {},
                                                            ), // Reload
                                                            BottomActions(
                                                              icon: Icons
                                                                  .thumb_up,
                                                              label: 'లైక్',
                                                              onTap: () {},
                                                            ), // Like
                                                            BottomActions(
                                                              icon:
                                                                  Icons.comment,
                                                              label: 'కామెంట్',
                                                              onTap: () {},
                                                            ), // Comment
                                                            BottomActions(
                                                              icon: Icons.share,
                                                              label: 'షేర్',
                                                              onTap: () {},
                                                            ), // Share
                                                          ],
                                                        ),
                                                        height(height: 10)
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                              ),
                            )
                          : Container(
                              color: Colors.grey,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              child: const Center(
                                child: Text(
                                  "Something went wrong. Please try again.",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                );
              }),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                // Animation duration
                opacity: _areRowsVisible ? 1.0 : 0.0,
                // Opacity based on state
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: Colors.black.withOpacity(0.7),
                      child: const Text(
                        'Top Row Content',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 500), // Animation duration
              opacity: _areRowsVisible ? 1.0 : 0.0,
              child: BottomNavigationItems(),
              // Opacity based on state
            ),
          ),
        ],
      ),
    );
  }

  bool _onUndo(
    int? previousIndex,
    int currentIndex,
    CardSwiperDirection direction,
  ) {
    debugPrint(
      'The card $currentIndex was undod from the ${direction.name}',
    );
    return true;
  }
}
