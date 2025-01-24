import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:chotanews/screens/home_screen/home_bloc.dart';
import 'package:chotanews/screens/home_screen/home_state.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../testing_screen/test_bloc.dart';
import '../testing_screen/test_event.dart';
import '../testing_screen/test_state.dart';
import 'home_event.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  final AppinioSwiperController controller = AppinioSwiperController();
  int indexUP = 0;

  @override
  void initState() {
    context.read<HomeBloc>().add(GetAllNewsFeed());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<HomeBloc, HomeScreenState>(
        builder: (context, state) {
          if (state is InitialHomeScreenState) {
            return Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (state is SuccessHomeScreenState) {
            return AppinioSwiper(
              invertAngleOnBottomDrag: false,
              swipeOptions: SwipeOptions.symmetric(
                  horizontal: false,
                  vertical:  true),
              controller: controller,
              onCardPositionChanged: (SwiperPosition position) {},
              onSwipeEnd: (
                previousIndex,
                targetIndex,
                activity,
              ) {
                context.read<HomeBloc>().add(OnSwipeCard(
                    previousIndex: previousIndex,
                    targetIndex: targetIndex,
                    activity: activity,
                    totalPosts: state.getAllHomeScreenNews.length));
              },
              // onEnd:  () => context.read<HomeBloc>().add(OnSwipeEndCard( data: state.getAllHomeScreenNews.last,)),
              allowUnSwipe: false,
              loop: false,
              cardCount: state.getAllHomeScreenNews.length,
              cardBuilder: (context, index) {
                return state.pageType == "Gallery"
                    ? Container(
                        height:300,
                        width: double.infinity,
                        color: AppColors.appButtonColor,
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            state.getAllHomeScreenNews[index].imageUrl?.url
                                        .toString() !=
                                    null
                                ? Image.network(
                                    state.getAllHomeScreenNews[index].imageUrl!
                                        .url
                                        .toString(),
                                    fit: BoxFit.cover,
                                    width: MediaQuery.of(context).size.width,
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                  )
                                : const SizedBox.shrink(),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.pageType ?? "No Title",
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  height(height: 16),
                                  Text(
                                    state.getAllHomeScreenNews[index].content ??
                                        "No Description",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
              },
            );
          } else {
            return Container(
              color: Colors.grey,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(
                child: Text(
                  "Something went wrong. Please try again.",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
