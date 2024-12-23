
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../mixin_class/auth_mixin.dart';
import '../../utils/app_fonts.dart';
import '../../utils/common_appbar.dart';
import '../articles_view/articles_screen.dart';
import '../dashboard_view/dashboard_view.dart';
import '../settings_view/setting_provider.dart';
import '../settings_view/settings_screen.dart';
import '../x_handles_view/x_handle_provider.dart';
import '../x_handles_view/x_handles_screen.dart';
import '../x_tweete_view/x_tweet_screen.dart';
import 'home_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AuthMixin{
  int? _currentIndex;
  String screenName = "Viral Tweets";
  @override
  void initState() {
    _currentIndex = 0;
    loadUserData();
    context.read<HomeProvider>().initialPage();
    context.read<HomeProvider>().getEngageTweets();
    context.read<XHandleProvider>().getTwitterHandles();
    context.read<HomeProvider>().getTweetMetric();
    context.read<SettingProvider>().getSettingsUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
              appBar: CommonAppbar(screenName: screenName,),
              body: Column(
                children: [
                  Expanded(
                    child: PageView(
                      allowImplicitScrolling: false,
                      controller: context.read<HomeProvider>().pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: const [
                        DashboardScreen(),
                        ArticlesPage(),
                        XHandlesScreen(),
                        XTweetScreen(),
                        SettingsScreen(),
                      ],
                    ),
                  ),
                ],
              ),

              bottomNavigationBar:BottomNavigationBar(
                backgroundColor: Colors.white,
                currentIndex: _currentIndex??0, // Track active tab
                onTap: (index) {
                  setState(() {
                    index == 0?
                      screenName = 'Viral Tweets': index == 1?screenName = "Articles":index == 2?screenName = 'XHandles':index==3?screenName = "XTweet":screenName ="Settings";
                    _currentIndex = index;
                    context.read<HomeProvider>().pageChange(index); // Update active tab
                  });
                },
                selectedItemColor: Colors.blue, // Color for selected items
                unselectedItemColor: Colors.black, // Color for inactive items
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: fontStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 14),
                iconSize: 20,
                items: [
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      "assets/house.svg",
                      width: 20,
                      height: 20,
                      color: _currentIndex == 0 ? Colors.blue : Colors.black, // Dynamic color
                    ),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      "assets/article.svg",
                      width: 20,
                      height: 20,
                      color: _currentIndex == 1 ? Colors.blue : Colors.black, // Dynamic color
                    ),
                    label: "Articles",
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      "assets/x_hamdles.svg",
                      width: 20,
                      height: 20,
                      color: _currentIndex == 2 ? Colors.blue : Colors.black, // Dynamic color
                    ),
                    label: "XHandles",
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      "assets/x-logo.svg",
                      width: 20,
                      height: 20,
                      color: _currentIndex == 3 ? Colors.blue : Colors.black, // Dynamic color
                    ),
                    label: "XTweets",
                  ),
                  BottomNavigationBarItem(
                    icon: SvgPicture.asset(
                      "assets/user_settings.svg",
                      width: 20,
                      height: 20,
                      color: _currentIndex == 4 ? Colors.blue : Colors.black, // Dynamic color
                    ),
                    label: "Settings",
                  ),
                ],
              )



          )),
    );
  }
}
