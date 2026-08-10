import 'dart:core';

class BaseUrls {


  /// event states
  static const String eventUrl = "/events";


  /// Reels Apis
  static const String getAllReels = "/reels";

  /// all posts
  static const String getNews = "/allposts";
  static const String getPostById = "/post";
  static const String getAllDistricts = "/user";

  static const String updateDistricts = "/upsert/location";

  static const String getAllVideos = "/menuposts";
  static const String appMenu = "/app/menu";

  ///Add Comment
  static const String addComment = "/addcomment";
  static const String commentGet = "/post/";

  ///getUserDetail
  static const String userInfo = "/userinfo";
  static const String addDevice = "/adddevice";

  ///like post
  static const String likePost = "/post/likes";

  ///Auth Apis
  static const String sendOtp = "/generateOtp";
  static const String sendCode = "/validateReferalCode";
  static const String validateOtp = "/validateOtp";

  static const String aboutPage = "https://chotanews.com/about-us";
  static const String contactPage = "https://chotanews.com/contact-us";
  static const String advertisePage = "https://chotanews.com/advertise";
  static const String termsPage = "https://chotanews.com/terms-conditions";
  static const String privacyPage = "https://chotanews.com/privacy-policy";

  ///  https://chn-app-be-dev.azurewebsites.net/api/menuposts?type=2

  /// Python live apis
  static const String baseUrlAwsDev = "https://apidev.chotanews.com";

  /// New Server API
  static const String newServerBaseUrl = "http://192.168.70.251";
  static const String deviceDetails = "/api/v1/deviceDetails";
  /// Python Dev Apis
  // static const String baseUrlAwsDev = "https://devapi.chotanews.com";

  ///Login login
  static const String sendOtpPy = "/send-otp";
  static const String validateOtpPy = "/validate-otp";

  ///FeedBack
  static const String getFeedback = "/feedback";

  ///FeedBack
  static const String getAllPost = "/allposts";
  static const String aiTags = "/aitags";
  static const String aiTagsById = "/aitag/content";

  ///Rating
  static const String postRating = "/moviereviews/submit";
  static const String getReviewsById = "/moviereviews/";
  static const String postPoll ="/polls/submit";
  static const String getPollCommentsById = "/polls/";
  static const String postProcessReferral = "/process-referral";


  ///Categories Apis
  static const String getAllCategories = "/categories";

  ///Categories Apis
  static const String surveyApi = "/survey";

  ///Location Apis
  static const String getAllLocation = "/locations";
  static const String getStateLocation = "/state_locations";
  static const String getAllLanguages = "/languages";

  ///Bookmarks Apis
  static const String getAllBookMarks = "/bookmark";

  ///Comments Apis
  static const String getAllComments = "/comments";

  ///Like Apis
  static const String like = "/like";

  /// Polls apis
  static const String submitPolls="/polls/submit";
  static const String getAllPolls="/polls";

  ///Update profile
  static const String getProfile = "/profile";

  ///Referral Apis
  static const String getReferralStats = "/referral/stats";
  static const String deviceInfoIOS = "/device-info";
  static const String getAvailableRewards = "/rewards/available";
  static const String getClaimedReward = "/rewards/claim";
  static const String serviceProviders = "/service_providers";
  static const String contestClick = "/contest/click";
  static const String adContestClick = "/contest/participation/";
  static const String test = "/test";

  /// Premium Content Apis
  static const String seriesContent = "/api/content";
}


