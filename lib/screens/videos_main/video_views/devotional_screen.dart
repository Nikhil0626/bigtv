import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/date_conversion.dart';
import '../vodeo_bloc/videos_bloc.dart';
import '../vodeo_bloc/videos_event.dart';
import '../vodeo_bloc/videos_state.dart';

class DevotionalScreen extends StatefulWidget {
  final String postId;
  const DevotionalScreen({super.key, required this.postId});

  @override
  State<DevotionalScreen> createState() => _DevotionalScreenState();
}

class _DevotionalScreenState extends State<DevotionalScreen> {
  @override
  void initState() {
    context.read<VideosBloc>().add(GetAllVideos(type: widget.postId));

    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: InkWell(
        onTap: () {
          Navigator.pushNamed(context, RoutesManager.getAllMenuItemScreen);
        },
        child: const Icon(
          color: Colors.white,
          Icons.arrow_back_ios,
          size: 18,
        ),
      ),backgroundColor: AppColors.appButtonColor,title: Text("Devotional View",style: fontStyle(fontSize: 16,fontWeight: FontWeight.w600,color: Colors.white),),),

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
                  Container(
                    height: 120,
                    width: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          state.getAllVideoList[index].imageUrl!.url!.isNotEmpty
                              ?  state.getAllVideoList[index].imageUrl!.url.toString()
                              : "https://example.com/default_image.png",
                        ),
                        fit: BoxFit.cover,
                      ),
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
