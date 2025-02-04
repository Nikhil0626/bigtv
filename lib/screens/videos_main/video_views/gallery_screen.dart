import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_bloc.dart';
import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_state.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../globel_keys/app_router.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/date_conversion.dart';
import '../vodeo_bloc/videos_event.dart';

class GalleryScreen extends StatefulWidget {
  final String postId;

  const GalleryScreen({super.key, required this.postId});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    context.read<VideosBloc>().add(GetAllVideos(type: widget.postId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Gallery View",
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
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        child: Image.network(
                          state.getAllVideoList[index].imageUrl!.url.toString(),
                          height: 120,
                          width: 80,
                          fit: BoxFit.fill,
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
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            height(height: 10),
                            Text(
                              dateFormat(
                                state.getAllVideoList[index].created.toString(),
                              ),
                              style: const TextStyle(
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
    );
  }
}
