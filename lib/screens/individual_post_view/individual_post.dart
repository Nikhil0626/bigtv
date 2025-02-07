import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../globel_keys/global_variables_data.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_no_data.dart';
import '../../utils/app_spaces.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_format.dart';
import '../../utils/image_view_popup.dart';
import '../flip_page/flipe_pannel.dart';
import '../home_screen/botton_actions.dart';
import '../home_screen/first_card_home_feeds.dart';
import '../home_screen/home_bloc.dart';
import '../home_screen/home_event.dart';
import '../home_screen/home_state.dart';
import '../videos_main/video_views/gallery_screen.dart';
import '../videos_main/video_views/video_preview.dart';

class IndividualPost extends StatefulWidget {
  final HomeScreenModel item;

  const IndividualPost({super.key,required this.item});

  @override
  State<IndividualPost> createState() => _IndividualPostState();
}

class _IndividualPostState extends State<IndividualPost> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: BlocBuilder<HomeBloc, HomeScreenState>(
        builder: (context, state) {
          if (state is LoadingHomeScreenState) {
            return const Center(child: AppLoadingScreen());
          } else if (state is SuccessHomeScreenState) {
            return Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        SizedBox(
                            child: state.pageType == "Video"
                                ? Container(
                                color: Colors.black,
                                child: Center(child: VideoPreview(url:  "")))
                                : CachedNetworkImage(
                              imageUrl:"",
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                    height: MediaQuery.of(context).size.height,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                              errorWidget: (context, url, error) => Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(32)),
                                ),
                                child: const Icon(
                                  Icons.account_box,
                                  size: 200,
                                ),
                              ),
                            )),
                        Positioned(
                            bottom: 1,
                            child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: AppColors.appButtonColor.withOpacity(.4),
                                    borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomLeft: Radius.circular(10))),
                                child: Image.asset("assets/images/brandlogo.png",))),
                        Positioned(
                            bottom: 10,
                            right: 10,
                            child: InkWell(
                                onTap: () {
                                  if (state.pageType == "Video") {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => VideoPreview(
                                            url: "",
                                            isVideoScreen: true,
                                          ),
                                        ));
                                  } else {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ImageViewPopup(
                                            imageUrl: "",
                                          ),
                                        ));
                                  }
                                },
                                child: const Center(
                                    child: Icon(
                                      Icons.zoom_out_map_sharp,
                                      color: AppColors.appButtonColor,
                                      size: 24,
                                    )))),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text( "No Title",
                              style: fontStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          height(height: 10),
                          Expanded(
                            child: Text("Posted ()",
                                style:
                                fontStyle(fontSize: 16, color: Colors.grey[800])),
                          ),
                          height(height: 4),
                          const Divider(color: AppColors.borderColor),
                          SizedBox(
                            height: 50,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                BottomActions(
                                    icon: "assets/svg/reload.svg",
                                    label: 'రిలోడ్ ',
                                    onTap: () {
                                      log("Refresh");
                                      context.read<HomeBloc>().add(GetAllNewsFeed());
                                    }),
                                BottomActions(
                                    icon:  "assets/svg/like.svg",
                                    label: 'లైక్',
                                    onTap: () {
                                      log(
                                        "Like",
                                      );
                                      // isLike = !isLike;
                                      setState(() {});
                                      // context.read<HomeBloc>().add(LikeByPost(isLike: true, postId: item.id.toString()));
                                    }),
                                BottomActions(
                                    icon: "assets/svg/comment.svg",
                                    label: 'కామెంట్',
                                    onTap: () {
                                      log("Comment");
                                      showComments(context, "");
                                      // context.read<HomeBloc>().add(GetAllNewsFeed());
                                    }),
                                BottomActions(
                                    icon: "assets/svg/share.svg",
                                    label: ' షేర్',
                                    onTap: () {
                                      log("Share");
                                      context.read<HomeBloc>().add(
                                          SendNewsToSocialMedia(
                                              id:""));
                                    }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          } else if (state is ErrorHomeScreenState) {
            return Center(child: AppNoData(data: state.getHomeScreenError,));
          } else {
            return const Center(child: AppNoData());
          }
        },
      ),
    );
  }
}
