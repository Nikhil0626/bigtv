import sys

file_path = 'lib/features/home/presentation/widgets/main_screen_byts_view.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

replacement = '''                                                                      if (widget.article['type'] != 'ImageAd' && widget.article['subType'] != 'ImageAd')
                                                                        Padding(
                                                                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                                                          child: Container(
                                                                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                                                                            decoration: BoxDecoration(
                                                                              color: Colors.white,
                                                                              borderRadius: BorderRadius.circular(16.0),
                                                                              border: Border.all(color: Colors.grey.shade300, width: 1.0),
                                                                            ),
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              children: [
                                                                                /// Like Icon
                                                                                Consumer<SettingsProvider>(builder: (_, settingsProvider, __) {
                                                                                  return InkWell(
                                                                                    onTap: () async {
                                                                                      log("Like");
                                                                                      settingsProvider.isLikePost(widget.article);
                                                                                      EventRepo().addEvent({
                                                                                        "isLike": !settingsProvider.isLikeList.contains(widget.article['id'].toString()),
                                                                                        "postId": widget.article['id'].toString() ?? "000",
                                                                                        "createAt": DateTime.now().toString(),
                                                                                        "postTitle": widget.article['title'].toString()
                                                                                      }, "liked_article");
                                                                                    },
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            SvgPicture.asset(
                                                                                              settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? "assets/svg/like_full.svg" : "assets/svg/like.svg",
                                                                                              height: 22, width: 22,
                                                                                              color: settingsProvider.isLikeList.contains(widget.article['id'].toString()) ? AppColorTokens.primaryRed : AppColorTokens.primaryRed,
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(height: 4),
                                                                                        Text("Like", style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                }),
                                                                                Container(width: 1, height: 32, color: Colors.grey.shade300),
                                                                                /// Comment Icon
                                                                                InkWell(
                                                                                  onTap: () {
                                                                                    log("Comment...");
                                                                                    if (context.mounted) {
                                                                                      context.read<AuthenticationProvider>().sendEvent("CommentPage");
                                                                                      showComments(context, widget.article['id'], widget.article['title']);
                                                                                    }
                                                                                  },
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisSize: MainAxisSize.min,
                                                                                        children: [
                                                                                          SvgPicture.asset("assets/svg/new_comment.svg", height: 22, width: 22, color: const Color(0xFFED1C24)),
                                                                                        ],
                                                                                      ),
                                                                                      const SizedBox(height: 4),
                                                                                      Text("Comment", style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Container(width: 1, height: 32, color: Colors.grey.shade300),
                                                                                /// Reload Icon
                                                                                Consumer<HomeProvider>(builder: (_, homeProvide, __) {
                                                                                  return InkWell(
                                                                                    onTap: () async {
                                                                                      log("Refresh");
                                                                                      EventRepo().addEvent({
                                                                                        "refresh": true,
                                                                                        "createAt": DateTime.now().toString()
                                                                                      }, "reload_article");
                                                                                      homeProvide.isReloadData();
                                                                                      if (homeProvide.isAiTagDataLoaded) {
                                                                                        homeProvide.getAllPostsByAiId(homeProvide.selectedTagId.toString());
                                                                                        homeProvide.isReloadFalse();
                                                                                      } else {
                                                                                        homeProvide.getAllPostList = [];
                                                                                        homeProvide.getAllPost();
                                                                                      }
                                                                                    },
                                                                                    child: Column(
                                                                                      mainAxisSize: MainAxisSize.min,
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: [
                                                                                            homeProvide.isReload
                                                                                                ? const SizedBox(height: 22, width: 22, child: AppLoadingScreen())
                                                                                                : SvgPicture.asset("assets/svg/new_refresh.svg", height: 22, width: 22, color: const Color(0xFFED1C24)),
                                                                                          ],
                                                                                        ),
                                                                                        const SizedBox(height: 4),
                                                                                        Text("Reload", style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                                                                                      ],
                                                                                    ),
                                                                                  );
                                                                                }),
                                                                                Container(width: 1, height: 32, color: Colors.grey.shade300),
                                                                                /// WhatsApp Icon
                                                                                InkWell(
                                                                                  onTap: () async {
                                                                                    try {
                                                                                      final String title = widget.article['title']?.toString() ?? "";
                                                                                      final String link = widget.article['linkURLAndroid']?.toString() ?? "";
                                                                                      final String shareText = title + "\\n" + link;
                                                                                      final imageBytes = await adsScreenshotController.capture(delay: const Duration(milliseconds: 10));
                                                                                      if (imageBytes != null) {
                                                                                        final directory = await getTemporaryDirectory();
                                                                                        final imagePath = await File(directory.path + "/screenshot_" + DateTime.now().millisecondsSinceEpoch.toString() + ".png").create();
                                                                                        await imagePath.writeAsBytes(imageBytes);
                                                                                        try {
                                                                                          const platform = MethodChannel('com.chotanews/whatsapp');
                                                                                          await platform.invokeMethod('shareToWhatsApp', {'imagePath': imagePath.path, 'text': shareText});
                                                                                        } catch (e) {
                                                                                          if (e is PlatformException && e.code == "APP_NOT_INSTALLED") {
                                                                                            CustomToast.showInfoToast(msg: "WhatsApp is not installed");
                                                                                          } else {
                                                                                            await Share.shareXFiles([XFile(imagePath.path)], text: shareText);
                                                                                          }
                                                                                        }
                                                                                      } else {
                                                                                        final url = "whatsapp://send?text=" + Uri.encodeComponent(shareText);
                                                                                        if (await canLaunchUrl(Uri.parse(url))) {
                                                                                          await launchUrl(Uri.parse(url));
                                                                                        } else {
                                                                                          CustomToast.showInfoToast(msg: "WhatsApp is not installed");
                                                                                        }
                                                                                      }
                                                                                    } catch (e) {
                                                                                      debugPrint("WhatsApp share error: " + e.toString());
                                                                                    }
                                                                                  },
                                                                                  child: Column(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      Image.asset("assets/images/WhatsApp_icon.png", height: 24, width: 24),
                                                                                      const SizedBox(height: 4),
                                                                                      Text("Share", style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.grey.shade600)),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
'''

new_lines = lines[:887] + [replacement] + lines[1045:]

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(''.join(new_lines))

print("Replaced lines 888 to 1045 successfully")
