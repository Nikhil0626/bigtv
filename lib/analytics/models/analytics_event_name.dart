abstract class AnalyticsEventName {
  // 2.1 App Lifecycle
  static const String appOpen           = 'app_open';
  static const String appFirstOpen      = 'app_first_open';
  static const String appSessionStart   = 'app_session_start';
  static const String appSessionEnd     = 'app_session_end';
  static const String appForeground     = 'app_foreground';
  static const String appBackground     = 'app_background';
  static const String appResume         = 'app_resume';
  static const String appDailyActivity  = 'app_daily_activity';

  // 2.2 Retention & Engagement
  static const String userFirstOpen       = 'user_first_open';
  static const String userReturn          = 'user_return';
  static const String userEngagement      = 'user_engagement';
  static const String userActivitySummary = 'user_activity_summary';

  // 2.3 Navigation & Screens
  static const String screenView      = 'screen_view';
  static const String navigationClick = 'navigation_click';
  static const String bottomNavClick  = 'bottom_navigation_click';
  static const String backNavigation  = 'back_navigation';

  // 2.4 Articles & News
  static const String articleOpen         = 'article_open';
  static const String articleReadStart    = 'article_read_start';
  static const String articleReadProgress = 'article_read_progress';
  static const String articleReadComplete = 'article_read_complete';
  static const String articleLike         = 'article_like';
  static const String articleUnlike       = 'article_unlike';
  static const String articleShare        = 'article_share';
  static const String articleFavorite     = 'article_favorite';
  static const String articleUnfavorite   = 'article_unfavorite';

  // 2.5 Notifications, Deep Links & Campaigns
  static const String notificationReceived  = 'notification_received';
  static const String notificationOpen      = 'notification_open';
  static const String notificationDismissed = 'notification_dismissed';
  static const String deepLinkOpen          = 'deep_link_open';
  static const String campaignEntry         = 'campaign_entry';

  // 2.6 Account & Profile
  static const String login                = 'login';
  static const String logout               = 'logout';
  static const String registrationComplete = 'registration_complete';
  static const String userProfileUpdate    = 'user_profile_update';
  static const String userLocationCaptured = 'user_location_captured';

  // 2.7 Language & Content Preferences
  static const String languageSelected          = 'language_selected';
  static const String languageChanged           = 'language_changed';
  static const String categorySelected          = 'category_selected';
  static const String categoryDeselected        = 'category_deselected';
  static const String categoryPreferenceUpdated = 'category_preference_updated';

  // 2.8 Live TV
  static const String liveTvOpen   = 'live_tv_open';
  static const String liveTvPlay   = 'live_tv_play';
  static const String liveTvPause  = 'live_tv_pause';
  static const String liveTvResume = 'live_tv_resume';
  static const String liveTvStop   = 'live_tv_stop';
  static const String liveTvShare  = 'live_tv_share';
  static const String liveTvError  = 'live_tv_error';

  // 2.9 Reels / Short Videos
  static const String reelOpen     = 'reel_open';
  static const String reelPlay     = 'reel_play';
  static const String reelPause    = 'reel_pause';
  static const String reelComplete = 'reel_complete';
  static const String reelRewatch  = 'reel_rewatch';
  static const String reelLike     = 'reel_like';
  static const String reelShare    = 'reel_share';
  static const String reelSkip     = 'reel_skip';

  // 2.10 ePaper
  static const String epaperOpen         = 'epaper_open';
  static const String epaperPageOpen     = 'epaper_page_open';
  static const String epaperPageChange   = 'epaper_page_change';
  static const String epaperReadComplete = 'epaper_read_complete';
  static const String epaperShare        = 'epaper_share';
  static const String epaperDownload     = 'epaper_download';

  // 2.11 Videos
  static const String videoOpen     = 'video_open';
  static const String videoPlay     = 'video_play';
  static const String videoPause    = 'video_pause';
  static const String videoResume   = 'video_resume';
  static const String videoProgress = 'video_progress';
  static const String videoComplete = 'video_complete';
  static const String videoReplay   = 'video_replay';
  static const String videoShare    = 'video_share';
  static const String videoError    = 'video_error';

  // 2.12 Games
  static const String gameListOpen      = 'game_list_open';
  static const String gameOpen          = 'game_open';
  static const String gameStart         = 'game_start';
  static const String gamePause         = 'game_pause';
  static const String gameResume        = 'game_resume';
  static const String gameComplete      = 'game_complete';
  static const String gameIncomplete    = 'game_incomplete';
  static const String gameExit          = 'game_exit';
  static const String gameScoreRecorded = 'game_score_recorded';

  // 2.13 Reporters & Creator Engagement
  static const String reporterListOpen    = 'reporter_list_open';
  static const String reporterProfileOpen = 'reporter_profile_open';
  static const String reporterContentOpen = 'reporter_content_open';
  static const String reporterFollow      = 'reporter_follow';
  static const String reporterUnfollow    = 'reporter_unfollow';
  static const String reporterShare       = 'reporter_share';

  // 2.14 Advertising
  static const String adRequest    = 'ad_request';
  static const String adLoaded     = 'ad_loaded';
  static const String adImpression = 'ad_impression';
  static const String adClicked    = 'ad_clicked';
  static const String adLoadFailed = 'ad_load_failed';
  static const String adDismissed  = 'ad_dismissed';
}
