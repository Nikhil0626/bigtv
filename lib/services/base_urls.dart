import 'dart:core';

class BaseUrls {

  /// Dev Base Url
  //   static const String baseUrl = "https://chotanews-fdcscrezbfd4befm.z01.azurefd.net/api";
  static const String baseUrl = "https://chotanews-prod-api.azurewebsites.net/api";

  static const String baseUrlAws = "https://prodchotanews.signitivessoft.com/api";



  /// event states
   static const String eventUrl = "/logs";
///ENewsPapers
  static const String getMainEPapers = "/enewspaper/first_pages";
  static const String getSingleEPapers = "/enewspapers";

/// all posts
  static const String getNews = "/allposts";
  static const String getPostById = "/post";
  static const String getAllDistricts = "/user";

  static const String updateDistricts ="/upsert/location";

  static const String getAllVideos = "/menuposts";
  static const String appMenu = "/app/menu";


  ///Add Comment
  static const String addComment = "/addcomment";
  static const String commentGet ="/post/";


  ///getUserDetail
  static const String userInfo = "/userinfo";
  static const String addDevice = "/adddevice";

  ///like post
  static const String likePost = "/post/likes";

  ///Auth Apis
  static const String sendOtp = "/generateOtp";
  static const String sendCode= "/validateReferalCode";
  static const String validateOtp = "/validateOtp";

  ///Web Pages
  static const String aboutPage = "https://uploadsmedia.s3.us-east-1.amazonaws.com/About+5.html";
  static const String contactPage = "https://uploadsmedia.s3.us-east-1.amazonaws.com/ContactPage+2.html";
  static const String advertisePage = "https://uploadsmedia.s3.us-east-1.amazonaws.com/AdvertisePage+2.html";
  static const String termsPage = "https://uploadsmedia.s3.us-east-1.amazonaws.com/Terms%26Conditions+1.html";
  static const String privacyPage = "https://uploadsmedia.s3.us-east-1.amazonaws.com/Privacy+5.html";



///  https://chn-app-be-dev.azurewebsites.net/api/menuposts?type=2




/// Python apis
  static const String ePaperBaseUrlAws = "http://65.2.63.103:8000";
  static const String baseUrlAwsDev = "http://13.203.77.182:8000";


  ///Login login
  static const String sendOtpPy = "/send-otp/";
  static const String validateOtpPy = "/validate-otp/";

  ///Categories Apis
  static const String getAllCategories = "/admin/categories";

  ///Location Apis
  static const String getAllLocation= "/admin/locations";



}