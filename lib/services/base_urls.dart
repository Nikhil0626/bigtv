class BaseUrls {
 //
 /// Dev Base Url
  static const String baseUrl = "https://devtwitter.chotanews.com/api";


  // /// Prod Base url
  //  static const String baseUrl = "https://twitter.chotanews.com/api";


  /// Auth Apis
  static const String login = "/login";
  static const String verifyOtp = "/verifyotp";
  static const String sendOtp = "/sendMail";
  static const String changePassword = "/password/resets";

  /// Home Apis
  static const String home = "/home";


  /// Tweet Generate Apis
  static const String tweetGenerate = "/tweet/generate";
  static const String publish = "/publish";
  static const String publishTweet = "/scheduledtweet";

  ///Tweet Handles Apis
  static const String getTwitterHandles = "/gettwitterhandles";
  static const String deleteHandle = "/deletehandle";
  static const String editHandle = "/edithandle/";
  static const String addHandle = "/addhandle";


  ///Get All publish Tweets Apis
  static const String getTweetMetric = "/gettweetmetric";

  /// Get All User Apis
  static const String getSettingsUser = "/getsettingsuser";
  static const String addUser = "/addsettingsuser";
  static const String editUser = "/editsettingsuser";
  static const String deleteSettingUser = "/deletesettingsuser";
  static const String blockUser = "/blockuser";
  static const String unbBlockUser = "/unblockuser";

  /// Delete Tweets Apis
  static const String deleteTweet = "/deletetweet";

  ///Content Configuration Apis
  static const String getSettingsId = "/getConfigration";
  static const String updateWords = "/updateWords";

  /// Get Mobile Version Details
  static const String getMobileVersions = "/getmobileversions";


}