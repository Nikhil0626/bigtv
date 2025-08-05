import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/aggricator_screens/polls_screens/poll_provider.dart';
import 'package:chotanews/aggricator_screens/polls_screens/polls_view/polls_comments.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_toasts.dart';
import '../../../utils/date_format.dart';
import '../../events_data/event_repo.dart';

class PollScreenDesign extends StatefulWidget {
  final dynamic artical;
  final int? index; // Changed to dynamic since the type isn't specified
  const PollScreenDesign({super.key, required this.artical, required this.index});

  @override
  State<PollScreenDesign> createState() => _PollScreenDesignState();
}

class _PollScreenDesignState extends State<PollScreenDesign> {
  int? selectId;
  ScreenshotController adsScreenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    context.read<PollProvider>().addData(widget.artical);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PollProvider>(builder: (_, pollProvider, __) {
      final article = pollProvider.localArticle;

      final pollData = article['pollData'];

      if (article == null || pollData == null) {
        return AppLoadingScreen();
      }

      final hasVoted = pollData['userHasVoted'] == true;

      return Screenshot(
        controller: adsScreenshotController,
        child: hasVoted ? _buildResultsView(pollProvider, adsScreenshotController) : _buildVotingView(pollProvider, adsScreenshotController),
      );
    });
  }

  Widget _buildVotingView(PollProvider pollProvider, ScreenshotController adsScreenshotController) {
    final options = pollProvider.localArticle['pollData']['options'] as List;
    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: pollProvider.localArticle['image_url'] ?? "",
            fit: BoxFit.fill,
            placeholder: (context, url) => Container(color: AppColors.borderColor.withOpacity(.2)),
            errorWidget: (context, url, error) => Center(child: Icon(Icons.image, size: 80, color: Colors.grey.shade300)),
          ),
        ),
        Positioned(
          top: 9,
          right: 5,
          child: Padding(
            padding: EdgeInsets.only(top: 8, right: 12),
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.9), shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(Icons.ios_share_outlined, color: Colors.white, size: 22),
                onPressed: () async {
                  SharedPreferences sp = await SharedPreferences.getInstance();
                  String? userId = sp.getString("userId");

                  sendShareDetails(userId, pollProvider.localArticle['id'], pollProvider.localArticle['content'].toString());

                  if (pollProvider.localArticle['type'] == "Standard" || pollProvider.localArticle['type'] == "Video" || pollProvider.localArticle['type'] == "Image") {
                    try {
                      final image = await adsScreenshotController.capture(
                        pixelRatio: 2.0,
                      );
                      if (image != null) {
                        final directory = await getTemporaryDirectory();
                        final imagePath = '${directory.path}/${pollProvider.localArticle['id']}.png';
                        final imageFile = File(imagePath);
                        await imageFile.writeAsBytes(image);

                        Share.shareXFiles([XFile(imageFile.path)], text: pollProvider.localArticle['linkURLAndroid'].toString());
                      } else {
                        CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                      }
                    } catch (e) {
                      CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                    }
                  }
                  EventRepo().addEvent(
                      {"share": "news", "postId": pollProvider.localArticle['id'].toString(), "createAt": DateTime.now().toString(), "postTitle": pollProvider.localArticle['title'].toString()},
                      "shared_article");
                },
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(.4), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    pollProvider.localArticle['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final bool isSelected = pollProvider.tempSelectedOptionId == option['id'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          pollProvider.tempSelectedOptionId = option['id'];
                          selectId = index;
                        });
                      },
                      child: Container(
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.8) : Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade700),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option['text'],
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // if (isSelected) const Icon(Icons.check_circle, color: Colors.black),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // const SizedBox(height: 12),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 10),
                //   child: SizedBox(
                //     width: double.infinity,
                //     height: 46,
                //     child: ElevatedButton(
                //       onPressed: pollProvider.tempSelectedOptionId == null
                //           ? null
                //           : () async {
                //               pollProvider.submitPolls(widget.artical['id'], selectId!, pollProvider.tempSelectedOptionId);
                //             },
                //       style: ElevatedButton.styleFrom(
                //         backgroundColor: Colors.lightBlue,
                //         disabledBackgroundColor: Colors.grey.shade800,
                //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                //       ),
                //       child: const Text("Submit", style: TextStyle(color: Colors.white)),
                //     ),
                //   ),
                // ),
                height(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: pollProvider.commentController,
                    style: fontStyle(fontSize: 14, color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type your comment here (optional)",
                      hintStyle: fontStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey.shade900,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                height(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: InkWell(
                      onTap: pollProvider.tempSelectedOptionId != null
                          ? () async {
                              SharedPreferences sp = await SharedPreferences.getInstance();
                              bool isLogin = sp.getString("loginType") != "login" ? true : false;

                              if (isLogin) {
                                CustomToast.showErrorToast(msg: "Your a guest user, Please login to submit poll");
                              } else {
                                pollProvider.submitPolls(
                                  pollProvider.localArticle['id'],
                                  selectId!,
                                  pollProvider.localArticle['pollData']['options'][selectId]['id'],
                                );
                              }
                            }
                          : null,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: pollProvider.tempSelectedOptionId != null ? Colors.lightBlue : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text("Submit", style: fontStyle(color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                if (pollProvider.localArticle['topComments'].isNotEmpty) ...[
                  height(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text("Top Comments", style: fontStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        Spacer(),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PollsComments(postId: pollProvider.localArticle['id'].toString()),
                                ),
                              );
                            },
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PollsComments(postId: pollProvider.localArticle['id'].toString()),
                                  ),
                                );
                              },
                              child: Text(
                                "More >",
                                style: fontStyle(
                                  color: Colors.lightBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  height(height: 6),
                  if (pollProvider.localArticle['topComments'].isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: pollProvider.localArticle['topComments'].length,
                          itemBuilder: (context, index) {
                            final comment = pollProvider.localArticle['topComments'][index];
                            return Container(
                              width: MediaQuery.of(context).size.width - 40,
                              height: 80,
                              margin: EdgeInsets.only(right: 8),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(.5),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_circle, size: 20),
                                      width(width: 5),
                                      Text(comment["userName"] ?? "", style: fontStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                    ],
                                  ),
                                  height(height: 4),
                                  Text(
                                    comment["comment"] ?? "",
                                    style: fontStyle(fontSize: 13, color: Colors.black),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  height(height: 4),
                                  Text(
                                    " ${formatTimeDifference(comment["createdAt"].toString())}",
                                    style: fontStyle(color: Colors.black, fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
                if (widget.index == 0) height(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsView(PollProvider pollProvider, ScreenshotController adsScreenshotController) {
    final options = pollProvider.localArticle['pollData']['options'] as List;
    final totalVotes = pollProvider.localArticle['pollData']['totalVotes'] ?? 0;

    return Stack(
      children: [
        Positioned.fill(
          child: CachedNetworkImage(
            imageUrl: pollProvider.localArticle['image_url'] ?? "",
            fit: BoxFit.fill,
            placeholder: (context, url) => Container(color: AppColors.borderColor.withOpacity(.2)),
            errorWidget: (context, url, error) => Center(child: Icon(Icons.image, size: 80, color: Colors.grey.shade300)),
          ),
        ),
        Positioned(
          top: 9,
          right: 5,
          child: Padding(
            padding: EdgeInsets.only(top: 8, right: 12),
            child: Container(
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.9), shape: BoxShape.circle),
              child: IconButton(
                icon: Icon(Icons.ios_share_outlined, color: Colors.white, size: 22),
                onPressed: () async {
                  SharedPreferences sp = await SharedPreferences.getInstance();
                  String? userId = sp.getString("userId");

                  sendShareDetails(userId, pollProvider.localArticle['id'], pollProvider.localArticle['content'].toString());

                  if (pollProvider.localArticle['type'] == "Standard" || pollProvider.localArticle['type'] == "Video" || pollProvider.localArticle['type'] == "Image") {
                    try {
                      final image = await adsScreenshotController.capture(
                        pixelRatio: 2.0,
                      );
                      if (image != null) {
                        final directory = await getTemporaryDirectory();
                        final imagePath = '${directory.path}/${pollProvider.localArticle['id']}.png';
                        final imageFile = File(imagePath);
                        await imageFile.writeAsBytes(image);

                        Share.shareXFiles([XFile(imageFile.path)], text: pollProvider.localArticle['linkURLAndroid'].toString());
                      } else {
                        CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
                      }
                    } catch (e) {
                      CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                    }
                  }
                  EventRepo().addEvent(
                      {"share": "news", "postId": pollProvider.localArticle['id'].toString(), "createAt": DateTime.now().toString(), "postTitle": pollProvider.localArticle['title'].toString()},
                      "shared_article");
                },
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(.4), Colors.black],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    pollProvider.localArticle['title'],
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final double percentage = (option['percentage'] ?? 0.0).toDouble();
                    final bool isVotedOption = option['id'] == pollProvider.userVotedOptionId;

                    return Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isVotedOption ? Colors.blue : Colors.black
                          ..withOpacity(.1),
                        border: Border.all(
                          color: isVotedOption ? Colors.blue : Colors.grey.shade700,
                          width: isVotedOption ? 2.0 : 1.0,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          FractionallySizedBox(
                            widthFactor: percentage / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  option['text'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isVotedOption ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${percentage.toStringAsFixed(1)}%",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: isVotedOption ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    // if (isVotedOption) const SizedBox(width: 8),
                                    // if (isVotedOption)
                                    //   const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                if (pollProvider.localArticle['topComments'].isNotEmpty) ...[
                  height(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Text("Top Comments", style: fontStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        Spacer(),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PollsComments(postId: pollProvider.localArticle['id'].toString()),
                                ),
                              );
                            },
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PollsComments(postId: pollProvider.localArticle['id'].toString()),
                                  ),
                                );
                              },
                              child: Text(
                                "More >",
                                style: fontStyle(
                                  color: Colors.lightBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                  height(height: 6),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: pollProvider.localArticle['topComments'].length,
                        itemBuilder: (context, index) {
                          final comment = pollProvider.localArticle['topComments'][index];
                          return Container(
                            width: MediaQuery.of(context).size.width - 40,
                            height: 80,
                            margin: EdgeInsets.only(right: 8),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.account_circle, size: 20),
                                    width(width: 5),
                                    Text(comment["userName"] ?? "", style: fontStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                                  ],
                                ),
                                height(height: 4),
                                Text(
                                  comment["comment"] ?? "",
                                  style: fontStyle(fontSize: 13, color: Colors.black),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                height(height: 4),
                                Text(
                                  " ${formatTimeDifference(comment["createdAt"].toString())}",
                                  style: fontStyle(color: Colors.black, fontSize: 11),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                if (widget.index == 0) height(height: 60),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
