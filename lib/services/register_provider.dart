import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:chotanews/aggricator_screens/splash_screen/splash_provider.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/features/reels/presentation/providers/reels_provider.dart';
import 'package:provider/provider.dart';


import '../aggricator_screens/contest_screen/contest_provider.dart';
import 'package:chotanews/features/home/presentation/providers/home_provider.dart';
import 'package:chotanews/features/home/presentation/providers/news_posts_provider.dart';
import '../aggricator_screens/polls_screens/poll_provider.dart';
import '../aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import '../aggricator_screens/referral_screen/referral_provider/referral_provider.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import 'package:chotanews/features/home/presentation/providers/epaper_provider.dart';


import '../core/providers/web_view_provider.dart';
import '../core/theme/theme_provider.dart';

class AppProviders {
  static List<ChangeNotifierProvider> all = [
    ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
    ChangeNotifierProvider<EpaperProvider>(create: (_) => EpaperProvider()),
    ChangeNotifierProvider<NewsPostsProvider>(create: (_) => NewsPostsProvider()),
    ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
    ChangeNotifierProvider<ReelsProviders>(create: (_) => ReelsProviders()),
    ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
    ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider()),
    ChangeNotifierProvider<ReferralProvider>(create: (_) => ReferralProvider()),
    ChangeNotifierProvider<RatingProvider>(create: (_) => RatingProvider()),

    ChangeNotifierProvider<PollProvider>(create: (_) => PollProvider()),
    ChangeNotifierProvider<AdsContestProvider>(create: (_) => AdsContestProvider()),

    ChangeNotifierProvider<VideoProvider>(create: (_) => VideoProvider()),
    ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
    ChangeNotifierProvider<WebViewProvider>(create: (_) => WebViewProvider()),
    ChangeNotifierProvider<SplashProvider>(create: (_) => SplashProvider()),
  ];
}
