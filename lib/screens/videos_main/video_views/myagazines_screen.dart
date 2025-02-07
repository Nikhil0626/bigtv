import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../globel_keys/app_router.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/date_conversion.dart';
import '../vodeo_bloc/videos_bloc.dart';
import '../vodeo_bloc/videos_event.dart';
import '../vodeo_bloc/videos_state.dart';
import 'gallery_screen.dart';

class MyagazinesScreen extends StatefulWidget {
  final String postId;

  const MyagazinesScreen({super.key, required this.postId});

  @override
  State<MyagazinesScreen> createState() => _MyagazinesScreen();
}

class _MyagazinesScreen extends State<MyagazinesScreen> {
  @override
  void initState() {
    print(widget.postId);
    context.read<VideosBloc>().add(GetAllVideos(type: widget.postId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamed(context, RoutesManager.getAllMenuItemScreen);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Navigator.pushNamed(context, RoutesManager.getAllMenuItemScreen);
            },
            child: const Icon(
              color: Colors.white,
              Icons.arrow_back_ios,
              size: 18,
            ),
          ),
          backgroundColor: AppColors.appButtonColor,
          title: Text(
            "Magazine View",
            style: fontStyle(
                fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        body: BlocBuilder<VideosBloc, VideosState>(
          builder: (context, state) {
            if (state is LoadingState) {
              return AppLoadingScreen();
            } else if (state is VideoSuccessState) {
              return ListView.separated(
                itemCount: state.getAllVideoList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullPageCarousel(
                                imageUrls:
                                    state.getAllVideoList[index].gallery ?? [],className: "Magazine View",),
                          ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4)),
                            child: Image.network(
                              state.getAllVideoList[index].imageUrl!.url
                                  .toString(),
                              height: 110,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          width(width: 15),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.getAllVideoList[index].title.toString(),
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                height(height: 10),
                                Text(
                                  dateFormat(
                                    state.getAllVideoList[index].created
                                        .toString(),
                                  ),
                                  style: fontStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.grey,
                    thickness: 1.0,
                    height: 5.0,
                  );
                },
              );
            }
            return Container(
              child: const Center(child: Text(AppStrings.appNotWorking)),
            );
          },
        ),
      ),
    );
  }
}
