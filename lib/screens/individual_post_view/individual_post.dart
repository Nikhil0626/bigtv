import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/screens/home_screen/home_screen_model.dart';
import 'package:chotanews/screens/individual_post_view/individual_post_event.dart';
import 'package:chotanews/screens/individual_post_view/individual_post_state.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../globel_keys/app_router.dart';
import '../../globel_keys/global_variables_data.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_no_data.dart';
import '../../utils/app_spaces.dart';
import '../../utils/commant_screen.dart';
import '../../utils/date_format.dart';
import '../../utils/image_view_popup.dart';
import '../flip_page/district_flip_panel.dart';
import '../home_screen/botton_actions.dart';
import '../home_screen/first_card_home_feeds.dart';
import '../home_screen/home_bloc.dart';
import '../home_screen/home_event.dart';
import '../home_screen/home_state.dart';
import '../videos_main/video_views/gallery_screen.dart';
import '../videos_main/video_views/video_preview.dart';
import 'individual_post_bloc.dart';

class IndividualPost extends StatefulWidget {
  final String postId;

  const IndividualPost({super.key,required this.postId});

  @override
  State<IndividualPost> createState() => _IndividualPostState();
}

class _IndividualPostState extends State<IndividualPost> {
  @override
  void initState() {
    context.read<IndividualPostBloc>().add(GetSinglePost(postId: widget.postId));
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
appBar: AppBar(
  leading: Padding(
    padding: const EdgeInsets.only(left: 14),
    child: IconButton(
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(context, RoutesManager.homeScreen,(route) => false,);
      },
      icon: const Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.white,
        size: 20,
      ),
    ),
  ),
  backgroundColor: AppColors.appButtonColor,
  title: Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      "Home Feeds",
      style: fontStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
    ),
  ),
),
      body: SafeArea(
        child: BlocBuilder<IndividualPostBloc, IndividualPostState>(
          builder: (context, state) {
            if (state is LoadingPostState) {
              return const Center(child: AppLoadingScreen());
            } else if (state is SuccessPostState) {
              return Container(
                color: state.getPost.subType ==
                    "BigBlackStandard"
                    ? Colors.black
                    : Colors.white,
                height:
                MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      // height: MediaQuery.of(context).size.height/2.35,
                      flex: state.getPost.subType ==
                          "BigBlackStandard"
                          ? 8
                          : 4,
                      child: Stack(
                        children: [
                          SizedBox(
                            child: state.getPost.type ==
                                "Video"
                                ? Container(
                                color: Colors.black,
                                child: Center(
                                    child: VideoPreview(
                                        url: state.getPost
                                            .videoUrl
                                            ?.url ??
                                            "")))
                                : Image.network(
                              state.getPost
                                  .imageUrl.url,
                              key: ValueKey(state.getPost
                                  .imageUrl
                                  .url),
                              fit: BoxFit.cover,
                              width:
                              double.infinity,
                              height:
                              double.infinity,
                            ),
                          ),
                          Positioned(
                              bottom: -12,
                              child: Container(
                                  margin: const EdgeInsets
                                      .all(8),
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                      horizontal: 8),
                                  height: 30,
                                  width: 100,
                                  decoration:
                                  const BoxDecoration(
                                      color: Colors
                                          .white,
                                      borderRadius:
                                      BorderRadius
                                          .only(topLeft:
                                      Radius
                                          .circular(
                                          10),
                                          topRight: Radius.circular(10)
                                      )),
                                  child: Image.asset(
                                    "assets/images/brandlogo.png",
                                  ))),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding:
                        const EdgeInsets.symmetric(
                            vertical: 8.0,
                            horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.start,
                          children: [
                            Text(
                                state.getPost.title ??
                                    "No Title",
                                style: homeScreenFontStyle(
                                    color:state.getPost
                                        .subType ==
                                        "BigBlackStandard"
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: 18,
                                    fontWeight:
                                    FontWeight.w600)),
                            height(height: 8),
                            Expanded(
                              child:
                              state.getPost
                                  .subType ==
                                  "BulletPost"
                                  ? ListView(
                                physics:
                                const NeverScrollableScrollPhysics(),
                                children: state.getPost
                                    .bulletPoints!
                                    .map<Widget>(
                                        (item) {
                                      // Explicitly specify <Widget>
                                      return Padding(
                                        padding: const EdgeInsets
                                            .symmetric(
                                            vertical:
                                            4.0),
                                        child: Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            const Text(
                                                "• ",
                                                style:
                                                TextStyle(fontSize: 24)),
                                            // Bullet point
                                            Expanded(
                                              child:
                                              Text(
                                                item,
                                                style:
                                                fontStyle(fontSize: 16),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(), // Ensure it is converted to List<Widget>
                              )
                                  : RichText(
                                text: TextSpan(
                                  text: '',
                                  children:
                                  _parseText(
                                    context,
                                    '${state.getPost.content}',
                                    state.getPost
                                        .links,
                                      state.getPost
                                  ),
                                ),
                              ),
                            ),
                            Text(
                                "\nPosted ${formatTimeDifference(state.getPost.created)}",
                                style: fontStyle(
                                    fontSize: 12,
                                    color: state.getPost
                                        .subType ==
                                        "BigBlackStandard"
                                        ? Colors.white
                                        : Colors
                                        .grey[800])),
                            height(height: 1)

                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (state is ErrorPostState) {
              return Center(child: AppNoData(data: state.error??""));
            } else {
              return const Center(child: AppNoData());
            }
          },
        ),
      ),
    );
  }

  List<TextSpan> _parseText(
      BuildContext context, String text, List<LinkModel>? links, HomeScreenModel getPost) {
    RegExp linkRegExp =
    RegExp(r'(https?:\/\/[^\s]+|<link\d+>(.*?)<\/link\d+>)');
    List<TextSpan> spans = [];

    text.splitMapJoin(
      linkRegExp,
      onMatch: (match) {
        String link = match.group(0)!;

        if (link.contains('<link1>')) {
          log("click linkss    ${links!.first.value.toString()}");
          link = links!.first.value.toString();
        }
        spans.add(TextSpan(
          text: match
              .group(0)
              .toString()
              .replaceFirst('<link1>', '')
              .replaceFirst('</link1>', '')
              .replaceFirst('<link2>', '')
              .replaceFirst('</link2>', '')
              .replaceFirst('<link3>', '')
              .replaceFirst('</link3>', ''),
          style: fontStyle(
            color: Colors.blue,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              print("ghhgjjkjjhg $link");
              if (await canLaunch(link)) {
                await launch(link);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not launch $link")));
              }
            },
        ));
        return "";
      },
      onNonMatch: (nonMatch) {
        spans.add(TextSpan(
            text: nonMatch,
            style: homeScreenFontStyle(
              color: getPost.subType == "BigBlackStandard"
                  ? Colors.white
                  : Colors.black,
              fontSize: 16,
            )));
        return "";
      },
    );

    return spans;
  }
}
