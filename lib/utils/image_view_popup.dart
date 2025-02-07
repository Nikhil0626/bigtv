import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

void showZoomedImage(BuildContext context, String imageUrl, type) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width, // Adjust the width as needed
        height: MediaQuery.of(context).size.height / 2,
        child: Stack(
          children: [
            Container(
              // Adjust the height as needed
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(4)),
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.fill, // Ensures the image covers the entire area
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.cancel,
                      size: 24,
                      color: Colors.red,
                    )),
              ),
            )
          ],
        ),
      ),
    ),
  );
}

class ImageViewPopup extends StatelessWidget {
  final String imageUrl;

  const ImageViewPopup({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.appButtonColor,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
        ),
        title:  Text("Image View",style: fontStyle(fontWeight: FontWeight.w600,fontSize: 18,color: Colors.white),),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width, // Adjust the width as needed
          height: MediaQuery.of(context).size.height/1.5,

          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            color: Colors.black,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              // fit: BoxFit.fill, // Ensures the image covers the entire area
            ),
          ),
        ),
      ),
    );
  }
}
