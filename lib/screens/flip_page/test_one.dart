// import 'dart:developer';
//
// import 'package:dio/dio.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../globel_keys/global_variables_data.dart';
// import '../home_screen/home_screen_model.dart';
// import '../home_screen/home_repo.dart';
//
// // Article Events
// abstract class ArticleEvent {}
//
// class FetchArticles extends ArticleEvent {
//   final int index;
//   final bool isTab;
//
//   FetchArticles({this.index = 0, this.isTab = false});
// }
//
// // Article States
// abstract class ArticleState {}
//
// class ArticleInitial extends ArticleState {}
//
// class ArticleLoading extends ArticleState {}
//
// class ArticleLoaded extends ArticleState {
//   final List<HomeScreenModel> articles;
//   ArticleLoaded({required this.articles});
// }
//
// class ArticleError extends ArticleState {
//   final String message;
//   ArticleError(this.message);
// }
//
// // Article Bloc
// class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
//   final HomeRepo api;
//   List<HomeScreenModel>? articlesData = [];
//
//   ArticleBloc({required this.api}) : super(ArticleInitial()) {
//     on<FetchArticles>(_fetchArticles);
//   }
//
//   Future<void> _fetchArticles(FetchArticles event, Emitter<ArticleState> emit) async {
//     try {
//       emit(ArticleLoading()); // Emit loading state
//
//       SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//       String locationId = sharedPreferences.getString("locationId") ?? "64";
//       String deviceId = GlobalVariables().deviceId ?? "";
//       String platform = GlobalVariables().platForm ?? "";
//
//       final Map<String, dynamic> queryParams = {
//         'userid': "1",
//         'postid': "0",
//         'lpostid': "0",
//         'includeHomePage': "0",
//         'isByNotification': "false",
//         'deviceid': deviceId,
//         'platform': "android",
//         'homefeed': "0",
//         // 'hasAds': true,
//         // 'locationIds': '21,22,43,44,55,64',
//         // "debugMode": true
//       };
//
//       log("Fetching articles: $queryParams");
//       Response response = await api.getAllNewsFeeds(queryParams);
//       List jsonList = response.data['posts'];
//       articlesData = jsonList.map((item) => HomeScreenModel.fromJson(item)).toList();
//
//       emit(ArticleLoaded(articles: articlesData!)); // Emit loaded state with data
//     } catch (e) {
//       log("Error fetching articles: $e");
//       emit(ArticleError("Failed to fetch articles")); // Emit error state
//     }
//   }
// }


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../services/file_download_services.dart';
import '../../services/permission_handler_services.dart';
import '../../utils/app_fonts.dart';

class DownloadApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DownloadScreen(),
    );
  }
}

class DownloadScreen extends StatefulWidget {
  @override
  _DownloadScreenState createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  String _status = "Click below to download";

  void _downloadFile(String url, String fileName, String fileType) async {
    await requestManageStoragePermission();
   await requestStoragePermission();
    setState(() {
      _status = "Downloading...";
    });

     downloadFile('https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', 'sample.pdf');

    // setState(() {
    //   _status = filePath != null ? "Downloaded to: $filePath" : "Download Failed!";
    // });
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Download PDF & Image")),
      body: Center(
        child: Padding(
          padding:  EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_status, textAlign: TextAlign.center, style: fontStyle(fontSize: 16)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _downloadFile(
                    "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
                    "sample_pdf",
                    "pdf"
                ),
                child: Text("Download PDF"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _downloadFile(
                    "https://unsplash.com/photos/young-asian-travel-woman-is-enjoying-with-beautiful-place-in-bangkok-thailand-_Fqoswmdmoo",
                    "sample_image",
                    "jpg"
                ),
                child: Text("Download Image"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}