import 'package:chotanews/aggricator_screens/video_image_screen/video_provider.dart';
import 'package:provider/provider.dart';

import '../aggricator_screens/ad_manager_screen/ad_provider/ad_mob_banner_provider.dart';
import '../aggricator_screens/ad_manager_screen/ad_provider/banner_ads_provider.dart';
import '../aggricator_screens/auth_screens/authentication_provider/authentication_provider.dart';
import '../aggricator_screens/contest_screen/contest_provider.dart';
import '../aggricator_screens/e_papers_screens/paper_provider/epapers_provider.dart';
import '../aggricator_screens/home_screen/home_provider/home_provider.dart';
import '../aggricator_screens/home_screen/home_provider/news_posts_provider.dart';
import '../aggricator_screens/polls_screens/poll_provider.dart';
import '../aggricator_screens/rating_screen/rating_provider/rating_provider.dart';
import '../aggricator_screens/reels_screens/reels_provider/reels_providers.dart';
import '../aggricator_screens/referral_screen/referral_provider/referral_provider.dart';
import '../aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import '../aggricator_screens/settings_screen/settings_provider/settings_provider.dart';
import '../aggricator_screens/test_screens/language_screen.dart';



class AppProviders {
  static List<ChangeNotifierProvider> all = [
    ChangeNotifierProvider<EPapersProvider>(create: (_) => EPapersProvider()),
    ChangeNotifierProvider<HomeProvider>(create: (_) => HomeProvider()),
    ChangeNotifierProvider<NewsPostsProvider>(create: (_) => NewsPostsProvider()),
    ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider()),
    ChangeNotifierProvider<ReelsProviders>(create: (_) => ReelsProviders()),
    ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
    ChangeNotifierProvider<ProfileProvider>(create: (_) => ProfileProvider()),
    ChangeNotifierProvider<ReferralProvider>(create: (_) => ReferralProvider()),
    ChangeNotifierProvider<RatingProvider>(create: (_) => RatingProvider()),
    ChangeNotifierProvider<BannerAdsProvider>(create: (_) => BannerAdsProvider()),
    ChangeNotifierProvider<PollProvider>(create: (_) => PollProvider()),
    ChangeNotifierProvider<AdProvider>(create: (_) => AdProvider()),
    ChangeNotifierProvider<AdsContestProvider>(create: (_) => AdsContestProvider()),
    ChangeNotifierProvider<AdMobBannerProvider>(create: (_) => AdMobBannerProvider()),
    ChangeNotifierProvider<VideoProvider>(create: (_) => VideoProvider()),
  ];
}
