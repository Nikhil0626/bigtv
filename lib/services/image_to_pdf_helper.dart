import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

/// Create A Pdf Multiple News Article
Future<void> createAndSharePdf(BuildContext context, dynamic article) async {
  List imageData = article['gallery'];
  try {
    final pdf = pw.Document();

    for (var item in imageData) {
      String imageUrl = item['Url'].toString();
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
          log("Failed to load image: $imageUrl");
        }
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}/${article['id']}.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    log("PDF saved at: $filePath");

    await Share.shareXFiles([XFile(filePath)], text: "${article['id']}");
  } catch (e) {
    log("Error: $e");
    if (context.mounted) {
      CustomToast.showErrorToast(msg: "Error: $e");
    }
  }
}
