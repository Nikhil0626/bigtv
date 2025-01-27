import 'package:chotanews/screens/videos_main/video_views/reels_view_screen.dart';
import 'package:chotanews/screens/videos_main/video_views/video_preview.dart';
import 'package:chotanews/utils/app_strings.dart';
import 'package:chotanews/utils/date_conversion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/app_loading_screen.dart';
import '../vodeo_bloc/videos_bloc.dart';
import '../vodeo_bloc/videos_event.dart';
import '../vodeo_bloc/videos_state.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

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
    return Scaffold(body: BlocBuilder<VideosBloc, VideosState>(builder: (context, state) {
      if (state is LoadingState) {
        return const AppLoadingScreen();
      } else if (state is VideoSuccessState) {
        return ListView.builder(
          itemCount: state.getAllVideoList.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(12),
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: Image.network(
                          state.getAllVideoList[index].imageUrl!.url.toString(),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      Positioned.fill(
                        child: InkWell(
                          onTap: () {
                            if (state.getAllVideoList[index].type.toString() == "Video") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPreview(url: state.getAllVideoList[index].videoUrl.toString(), ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReelsViewScreen(getReelDetails: state.getAllVideoList[index].videoUrl!.url.toString()),
                                ),
                              );
                            }
                          },
                          child: Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 70,
                              color: Colors.lightBlue.shade50,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow[100],
                            border: Border.all(
                              width: 1,
                              color: Colors.yellow.shade700,
                            ),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text(
                              state.getAllVideoList[index].type.toString(),
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          state.getAllVideoList[index].title.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          dateConversion(
                            state.getAllVideoList[index].created.toString(),
                          ),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
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
          child: const Center(child: Text(AppStrings.appNotWorking)),
        );
      }
    }));
  }
}
