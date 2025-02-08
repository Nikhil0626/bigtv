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
