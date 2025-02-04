// import 'package:chotanews/screens/chota_info_screens/chota_info.dart';
// import 'package:chotanews/screens/videos_main/video_views/devotional_screen.dart';
// import 'package:chotanews/screens/videos_main/video_views/gallery_screen.dart';
// import 'package:chotanews/screens/videos_main/video_views/myagazines_screen.dart';
// import 'package:chotanews/screens/videos_main/video_views/podcost_screen.dart';
// import 'package:chotanews/screens/videos_main/video_views/videos_view_screen.dart';
// import 'package:chotanews/utils/app_fonts.dart';
// import 'package:chotanews/utils/app_spaces.dart';
// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
//
// import '../../globel_keys/app_router.dart';
//
// class TabScreen extends StatefulWidget {
//   const TabScreen({super.key});
//
//   @override
//   State<TabScreen> createState() => _TabScreen();
// }
//
// class _TabScreen extends State<TabScreen> with SingleTickerProviderStateMixin {
//   late TabController tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 5, vsync: this);
//     tabController.addListener(() {
//       setState(() {});
//     });
//   }
//
//   @override
//   void dispose() {
//     tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 1,
//         centerTitle: true,
//         leading: InkWell(
//           onTap: (){
//
//           },
//           child: const Icon(Icons.arrow_back_ios,size: 24,),
//         ),
//         title:  const Text(
//           "Menu Screen",
//           style: TextStyle(
//             color: Colors.black,
//             fontSize: 14,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.settings,
//               size: 25,
//               color: Colors.black,
//             ),
//             onPressed: () {
//               final GoogleSignIn _googleSignIn = GoogleSignIn();
//               _googleSignIn.disconnect();
//               // Navigator.pushNamed(context, RoutesManager.login);
//
//             },
//           ),
//           width(width: 10)
//         ],
//         bottom: TabBar(
//           controller: tabController,
//           isScrollable: true,
//           tabAlignment: TabAlignment.center,
//           indicatorColor: Colors.lightBlue,
//           labelColor: Colors.lightBlue,
//
//           labelStyle:  fontStyle(
//             fontSize: 20,
//             fontWeight: FontWeight.w500,
//           ),
//           unselectedLabelStyle:  fontStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//           tabs: const [
//             Tab(text: "వీడియోలు"),
//             Tab(text: "గ్యాలరీ"),
//             Tab(text: "పాడ్‌కాస్ట్"),
//             Tab(text: "మ్యాగజైన్లు"),
//             Tab(text: "భక్తి"),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: TabBarView(
//               controller: tabController,
//               children: const [
//                 VideosScreen(),
//                 GalleryScreen(),
//                 PodcostScreen(),
//                 MyagazinesScreen(),
//                 DevotionalScreen(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chotanews/globel_keys/app_router.dart';
import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_bloc.dart';
import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_event.dart';
import 'package:chotanews/screens/videos_main/vodeo_bloc/videos_state.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/app_colors.dart';


class GetAllMenuItemScreen extends StatefulWidget {

  const GetAllMenuItemScreen({super.key,});

  @override
  State<GetAllMenuItemScreen> createState() => _GetAllMenuItemScreenState();
}

class _GetAllMenuItemScreenState extends State<GetAllMenuItemScreen> {
  @override
  void initState() {
    context.read<VideosBloc>().add(GetAllMenu());
    super.initState();
  }

  @override
  void didChangeDependencies() {
   log("iscallingggggggggg");
    super.didChangeDependencies();
  }
@override
  void didUpdateWidget(covariant GetAllMenuItemScreen oldWidget) {
  log("ksaiu;fofoihsv;ufiae;ufiowefivhsh");
    super.didUpdateWidget(oldWidget);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.appButtonColor,
        title: Text(
          "మెను",
          style: fontStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pushNamed(context, RoutesManager.homeScreen);
          },
          child: const Icon(
            color: Colors.white,
            Icons.arrow_back_ios,
            size: 18,
          ),
        ),
      ),
      body: BlocBuilder<VideosBloc, VideosState>(builder: (context, state) {

        if (state is LoadingState) {
          return const Center(child: AppLoadingScreen(),);
        }else if (state is MenuItemState) {
          if (state.getAllMenuList.isEmpty) {
            return const Center(child: Text('No menu items available.'));
          }

          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    separatorBuilder: (context, index) {
                      return const Divider(
                        color: AppColors.borderColor,
                      );
                    },
                    itemCount: state.getAllMenuList.length,
                    // Ensure proper item count
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          if (state.getAllMenuList[index].value == "gallery") {
                            Navigator.pushNamed(
                                context, RoutesManager.galleryScreen,arguments: { "postId": state.getAllMenuList[index].id.toString(),});
                          } else if (state.getAllMenuList[index].value ==
                              "bytes") {
                            Navigator.pushNamed(
                                context, RoutesManager.videoScreen,arguments: { "postId": state.getAllMenuList[index].id.toString(),});
                          } else if (state.getAllMenuList[index].value ==
                              "magazine") {
                            Navigator.pushNamed(
                                context, RoutesManager.magazineScreen,arguments: { "postId": state.getAllMenuList[index].id.toString(),});
                          } else if (state.getAllMenuList[index].value ==
                              "devotional") {
                            Navigator.pushNamed(
                                context, RoutesManager.devotionalScreen,arguments: { "postId": state.getAllMenuList[index].id.toString(),});
                          } else if (state.getAllMenuList[index].value ==
                              "podcast") {
                            Navigator.pushNamed(
                                context, RoutesManager.podcastScreen,arguments: { "postId": state.getAllMenuList[index].id.toString(),});
                          }
                        },
                        child: ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    state.getAllMenuList[index].imageUrl.isNotEmpty
                                        ? state.getAllMenuList[index].imageUrl
                                        : "https://example.com/default_image.png",
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )


                          ),
                          title: Text(
                            state.getAllMenuList[index].name,
                            style: fontStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 20,
                          ),

                        ),
                      );
                    },
                  ),
                ),
                const Divider(
                  color: AppColors.borderColor,
                ),
              ],
            ),
          );
        } else {
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          );
        }
      }),
    );
  }
}
