
import 'dart:io';
import 'dart:typed_data';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';




/// Create A Pdf Single News Article
Future<void> convertImageUrlToPdfAndShare(BuildContext context,  article) async {
  try {
    final response = await http.get(Uri.parse(article.imageUrl.url.toString(),));

    if (response.statusCode == 200) {
      final Uint8List imageData = response.bodyBytes;

      final pdf = pw.Document();

      final pdfImage = pw.MemoryImage(imageData);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.FullPage(
              ignoreMargins: true, // Ensures full coverage
              child: pw.Image(
                pdfImage,
                fit: pw.BoxFit.cover, // Covers the full page
              ),
            );;
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final filePath = "${directory.path}/";

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      print("PDF saved at: $filePath");

      // final DynamicLinkParameters parameters = DynamicLinkParameters(
      //   uriPrefix: 'https://chotanews.page.link', // Make sure this matches Firebase Console
      //   link: Uri.parse('https://chotanews.com/store?postId=${article.id}'), // Ensure this is a valid URL
      //   androidParameters: const AndroidParameters(
      //     packageName: 'com.chotanews', // Ensure this matches your AndroidManifest.xml
      //   ),
      //   iosParameters: const IOSParameters(
      //     bundleId: 'com.chotanewstelugu.app', // Ensure this matches Firebase Console
      //     appStoreId: '1631068092',
      //   ),
      // );
      //
      // final ShortDynamicLink shortLink =
      // await FirebaseDynamicLinks.instance.buildShortLink(parameters);
      // print("Short Link Created: ${shortLink.shortUrl}");
      // Share.shareXFiles([XFile(filePath)], text: "${shortLink.shortUrl}");
    } else {
      CustomToast.showErrorToast(msg: "Failed to load image");

    }
  } catch (e) {
    print("Error: $e");
    CustomToast.showErrorToast(msg: "Error: $e");
  }
}

/// Take A Screen News Article
Future<void> takeScreenshotAndShare( article,screenshotController, ) async {
  
  try {

    final image = await screenshotController.capture(
      pixelRatio: 1.5,
    );
    if (image != null) {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/${article.id}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      Share.shareXFiles([XFile(imageFile.path)], text:Platform.isIOS?article.linkURLIos.toString(): article.linkURLAndroid.toString());

    } else {
      CustomToast.showErrorToast(msg: "Failed to capture screenshot.123");
    }
  } catch (e) {
    CustomToast.showErrorToast(msg: "Failed to capture screenshot.");
  }
}




/// Create A Pdf Multiple News Article
Future<void> createAndSharePdf(BuildContext context, article ) async {


  List imageData = article['gallery'];
  try {
    final pdf = pw.Document();

    for (var item in imageData) {
      String imageUrl = item['Url'].toString() ?? '';
      print("pdfff ${imageUrl}");
      if (imageUrl.isNotEmpty) {
        final response = await http.get(Uri.parse(imageUrl));

        if (response.statusCode == 200) {
          final Uint8List imageData = response.bodyBytes;
          final pdfImage = pw.MemoryImage(imageData);

          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.FullPage(
                  ignoreMargins: true, // Ensures full coverage
                  child: pw.Image(
                    pdfImage,
                    fit: pw.BoxFit.fill, // Covers the full page
                  ),
                );
              },
            ),
          );
        } else {
          print("Failed to load image: $imageUrl");
        }
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/${article['id']}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    print("PDF saved at: $filePath");

    await Share.shareXFiles([XFile(filePath)], text: "https://apps.signitivessoft.com/individualPage");

  } catch (e) {
    print("Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

