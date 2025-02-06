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
import '../chota_info_screens/chota_info.dart';
import '../profile_screen/profile_screen.dart';

class GetAllMenuItemScreen extends StatefulWidget {
  const GetAllMenuItemScreen({super.key});

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
        leading: const SizedBox(),
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, RoutesManager.homeScreen);
              },
              child: const Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "మెను",
              style: fontStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              Navigator.pushNamed(context, RoutesManager.settingsScreen);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: BlocBuilder<VideosBloc, VideosState>(builder: (context, state) {
          if (state is LoadingState) {
            return const Center(child: AppLoadingScreen());
          } else if (state is MenuItemState) {
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
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            if (state.getAllMenuList[index].value == "gallery") {
                              Navigator.pushNamed(
                                  context, RoutesManager.galleryScreen,
                                  arguments: {
                                    "postId":
                                    state.getAllMenuList[index].id.toString(),
                                  });
                            } else if (state.getAllMenuList[index].value == "bytes") {
                              Navigator.pushNamed(
                                  context, RoutesManager.videoScreen,
                                  arguments: {
                                    "postId":
                                    state.getAllMenuList[index].id.toString(),
                                  });
                            } else if (state.getAllMenuList[index].value == "magazine") {
                              Navigator.pushNamed(
                                  context, RoutesManager.magazineScreen,
                                  arguments: {
                                    "postId":
                                    state.getAllMenuList[index].id.toString(),
                                  });
                            } else if (state.getAllMenuList[index].value == "devotional") {
                              Navigator.pushNamed(
                                  context, RoutesManager.devotionalScreen,
                                  arguments: {
                                    "postId":
                                    state.getAllMenuList[index].id.toString(),
                                  });
                            } else if (state.getAllMenuList[index].value == "podcast") {
                              Navigator.pushNamed(
                                  context, RoutesManager.podcastScreen,
                                  arguments: {
                                    "postId":
                                    state.getAllMenuList[index].id.toString(),
                                  });
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
                              ),
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
      ),
    );
  }
}
