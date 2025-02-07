import 'dart:developer';
import 'package:chotanews/screens/Auth_module/auth_screen.dart';
import 'package:chotanews/screens/home_screen/home_bloc.dart';
import 'package:chotanews/screens/home_screen/home_state.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/bottom_navigation_items.dart';
import '../flip_page/articals_bloc.dart';
import '../flip_page/article_bloc_provider.dart';
import 'flip_way2news.dart';
import 'home_repo.dart';
import 'home_screen_view.dart';

class HomeTopTabs extends StatefulWidget {
  final String tab;
  const HomeTopTabs({super.key, this.tab = "0"});

  @override
  State<HomeTopTabs> createState() => _HomeTopTabsState();
}

class _HomeTopTabsState extends State<HomeTopTabs> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isChange = true;

  @override
  void initState() {
    super.initState();
    log(widget.tab);
    initDynamicLinks();
    // initUniLinks();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: int.parse(widget.tab) ?? 0,
    );

  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData? data) {
      log("Dynamic Links  ${data?.link}");
      final Uri? deepLink = data?.link;
      if (deepLink != null) {
        handleDeepLink(deepLink);
      }
    }).onError((error) {
      print('Dynamic Link Failed: $error');
    });

    final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink?.link != null) {
      handleDeepLink(initialLink!.link!);
    }
  }

  // Handling Deep Links from Custom URL Schemes
  // void initUniLinks() async {
  //   try {
  //     final Uri? initialUri = await getInitialUri();
  //     if (initialUri != null) {
  //       handleDeepLink(initialUri);
  //     }
  //   } catch (e) {
  //     print('UniLinks Error: $e');
  //   }
  //
  //   linkStream.listen((String? link) {
  //     if (link != null) {
  //       handleDeepLink(Uri.parse(link));
  //     }
  //   }, onError: (err) {
  //     print('UniLinks Stream Error: $err');
  //   });
  // }

  // Function to handle deep links
  void handleDeepLink(Uri deepLink) {
    String url = "https://chotanews.com/store?postId=3604374";
    Uri uri = Uri.parse(url);

    String? postId = uri.queryParameters["postId"];

    print(postId);
    print('Deep Link: $deepLink');

    if (postId != null) {
      String productId = deepLink.pathSegments.last;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    HomeRepo api = HomeRepo();
    ArticleBloc bloc = ArticleBloc(api: api);

    if(widget.tab =="1"){
      bloc.getArticles(isTab: true);
    }else{
      bloc.getArticles();

    }
    return ArticleBlocProvider(
      bloc: bloc,
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            body: BlocConsumer<HomeBloc, HomeScreenState>(
              listener: (context, state) {
                if (state is SuccessHomeScreenState) {
                  if (isChange != state.isChange) {
                    setState(() {
                      isChange = state.isChange;
                    });
                  }
                }
              },
              builder: (context, state) {
                return Stack(
                  children: [
                    TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        // MyHomePage1(tabName: "Home"),
                        // MyHomePage1(tabName: ""),
                        HomePage(),
                        HomePage(),
                      ],
                    ),
                    if(isChange)
                    Positioned(
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isChange ? 1.0 : 0.0,
                        child: Material(
                          color: Colors.white,
                          child: TabBar(
                            onTap: (val){
                              if(val == 0) {
                                bloc.getArticles();
                              }else{
                                bloc.getArticles(isTab: true);
                              }
                            },
                            controller: _tabController,
                            isScrollable: false, // Disable scrolling of the TabBar
                            unselectedLabelColor: Colors.black,
                            indicatorColor: Colors.blue,
                            unselectedLabelStyle: fontStyle(color: Colors.black,fontSize: 14,fontWeight: FontWeight.normal),
                            labelStyle: fontStyle(color: Colors.blue,fontSize: 16,fontWeight: FontWeight.bold),
                            tabs: const [
                              Tab(text: 'న్యూస్'),
                              Tab(text: 'జిల్లాలు'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if(isChange)
                    Positioned(
                      bottom: 1,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: isChange ? 1.0 : 0.0,
                        child: const BottomNavigationItems(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
