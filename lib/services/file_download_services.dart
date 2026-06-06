import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

Future<String?> getDownloadDirectory() async {
  Directory? directory;
  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
    directory ??= Directory("/storage/emulated/0/Download");
  } else {
    directory = await getApplicationDocumentsDirectory();
  }

  return directory.path;
}

Future<void> downloadFile(String fileUrl, String fileName) async {
  String? directoryPath = await getDownloadDirectory();
  if (directoryPath == null) {
    print("❌ Unable to get directory.");
    return;
  }

  String filePath = "$directoryPath/$fileName";

  try {
    var response = await http.get(Uri.parse(fileUrl));

    if (response.statusCode == 200) {
      File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      print("✅ File downloaded to: $filePath");
    } else {
      print("❌ Download failed: ${response.statusCode} - ${response.reasonPhrase}");
    }
  } catch (e) {
    print("❌ Download error: $e");
  }
}
