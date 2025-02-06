import 'package:chotanews/screens/videos_main/video_views/reels_view_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/video_preview.dart';
import 'package:chotanews/utils/app_strings.dart';
import 'package:chotanews/utils/date_conversion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../globel_keys/app_router.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_loading_screen.dart';
import '../../../utils/app_spaces.dart';
import '../vodeo_bloc/videos_bloc.dart';
import '../vodeo_bloc/videos_event.dart';
import '../vodeo_bloc/videos_state.dart';

class VideosScreen extends StatefulWidget {
  final String postId;

  const VideosScreen({super.key, required this.postId});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  @override
  void initState() {
    context.read<VideosBloc>().add(GetAllVideos(type: "2"));
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
            "Video Screen",
            style: fontStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ),
        body: BlocBuilder<VideosBloc, VideosState>(builder: (context, state) {
          if (state is LoadingState) {
            return const AppLoadingScreen();
          } else if (state is VideoSuccessState) {
            return ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider(
                  color: AppColors.borderColor,
                );
              },
              itemCount: state.getAllVideoList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    if (state.getAllVideoList[index].type.toString() ==
                        "Video") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPreview(
                            url: state.getAllVideoList[index].videoUrl!.url
                                .toString(),
                            isVideoScreen: true,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReelsViewScreen(
                              getReelDetails: state
                                  .getAllVideoList[index].videoUrl!.url
                                  .toString(),videoType: state.getAllVideoList[index].subType
                              .toString(),),
                        ),
                      );
                    }
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
                                style: const TextStyle(
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
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),Text(
                                  state.getAllVideoList[index].subType
                                      .toString(),
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
                  ),
                );

                //   Container(
                //   padding: const EdgeInsets.all(12),
                //   width: 300,
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       Stack(
                //         children: [
                //           ClipRRect(
                //             borderRadius:
                //                 const BorderRadius.all(Radius.circular(16)),
                //             child: Image.network(
                //               state.getAllVideoList[index].imageUrl!.url
                //                   .toString(),
                //               height: 200,
                //               width: MediaQuery.of(context).size.width,
                //               fit: BoxFit.fitWidth,
                //             ),
                //           ),
                //           Positioned.fill(
                //             child: InkWell(
                //               onTap: () {
                //                 if (state.getAllVideoList[index].type
                //                         .toString() ==
                //                     "Video") {
                //                   Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                       builder: (context) => VideoPreview(
                //                         url: state.getAllVideoList[index]
                //                             .videoUrl!.url
                //                             .toString(),
                //                         isVideoScreen: true,
                //                       ),
                //                     ),
                //                   );
                //                 } else {
                //                   Navigator.push(
                //                     context,
                //                     MaterialPageRoute(
                //                       builder: (context) => ReelsViewScreen(
                //                           getReelDetails: state
                //                               .getAllVideoList[index]
                //                               .videoUrl!
                //                               .url
                //                               .toString()),
                //                     ),
                //                   );
                //                 }
                //               },
                //               child: Center(
                //                 child: Icon(
                //                   Icons.play_circle_fill,
                //                   size: 70,
                //                   color: Colors.lightBlue.shade50,
                //                 ),
                //               ),
                //             ),
                //           ),
                //         ],
                //       ),
                //       Padding(
                //         padding: const EdgeInsets.all(12.0),
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             Container(
                //               decoration: BoxDecoration(
                //                 color: Colors.yellow[100],
                //                 border: Border.all(
                //                   width: 1,
                //                   color: Colors.yellow.shade700,
                //                 ),
                //                 borderRadius: BorderRadius.circular(40),
                //               ),
                //               child: Padding(
                //                 padding: const EdgeInsets.symmetric(
                //                     horizontal: 16, vertical: 10),
                //                 child: Text(
                //                   state.getAllVideoList[index].type.toString(),
                //                   style: const TextStyle(
                //                     color: Colors.black,
                //                     fontSize: 12,
                //                     fontWeight: FontWeight.bold,
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             const SizedBox(height: 7),
                //             Text(
                //               state.getAllVideoList[index].title.toString(),
                //               style: const TextStyle(
                //                 fontSize: 16,
                //                 fontWeight: FontWeight.bold,
                //               ),
                //             ),
                //             const SizedBox(height: 7),
                //             Text(
                //               dateConversion(
                //                 state.getAllVideoList[index].created.toString(),
                //               ),
                //               style: const TextStyle(
                //                 fontSize: 12,
                //                 color: Colors.grey,
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // );
              },
            );
          } else {
            return Container(
              child: const Center(child: Text(AppStrings.appNotWorking)),
            );
          }
        }));
  }
}
