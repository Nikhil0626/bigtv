import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../globel_keys/global_variables_data.dart';
import '../../../screens/home_screen/home_provider/provider.dart';
import '../../../screens/home_screen/home_repo/event_repo.dart';
import '../../../services/webengage_event_tracks.dart';
import '../../../utils/app_fonts.dart';
import '../../../utils/app_spaces.dart';
import '../../../utils/app_toasts.dart';

class PapersScreenPreview extends StatefulWidget {
  final String postId;
  final String imageUrl;
  final String name;
  const PapersScreenPreview({super.key, required this.imageUrl,  this.name="Paper",required this.postId});

  @override
  State<PapersScreenPreview> createState() => _PapersScreenPreviewState();
}

class _PapersScreenPreviewState extends State<PapersScreenPreview> {
  final ScreenshotController paperScreenShort = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Better visibility
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10, right: 10),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_back_outlined,
                    size: 24,
                  ),
                  width(width: 20),
                  Text(
                    widget.name,
                    style: fontStyle(fontSize: 20),
                  )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Screenshot(
                    controller: paperScreenShort,
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(6),
                      minScale: 1.0,
                      maxScale: 10.0, // Maximum zoom level
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.fill, // Adjust for better fit
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: GestureDetector(
                      onTap: () async{
                        EventRepo().sendEvent({
                          "key": "share_via_articles",
                          "data": {
                            "device_id": "${GlobalVariables().deviceId}",
                            "userId": context.read<FlipProvider>().userId ?? "",
                            "postId": widget.postId .toString(),
                            "isWhatAppShare": false,
                          }
                        });

                        sendShareDetails(context.read<FlipProvider>().userId, widget.postId ,
                            widget.postId  .toString());
                        try {
                          final image = await paperScreenShort.capture(
                            pixelRatio: 0.5,
                          );
                          if (image != null) {
                            final directory = await getTemporaryDirectory();
                            final imagePath = '${directory.path}/${widget.postId }.png';
                            final imageFile = File(imagePath);
                            await imageFile.writeAsBytes(image);

                            Share.shareXFiles([XFile(imageFile.path)],
                                text:  widget.imageUrl);
                          } else {
                            CustomToast.showErrorToast(msg: "Failed to capture screenshot");
                          }
                        } catch (e) {
                          CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
                        }

                      },
                      child: Container(
                        padding: EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.bookmark,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
