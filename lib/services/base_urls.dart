import 'dart:core';

class BaseUrls {

  /// Dev Base Url
  //   static const String baseUrl = "https://chotanews-fdcscrezbfd4befm.z01.azurefd.net/api";
  static const String baseUrl = "https://chotanews-prod-api.azurewebsites.net/api";

  static const String baseUrlAws = "http://35.174.155.208/api";

  /// event states
   static const String baseUrlAwsDev = "http://52.207.134.157/api";
   static const String eventUrl = "/logs";



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
  // static const String aboutPage = "https://settingsfiles.s3.us-east-1.amazonaws.com/Terms.html";
  static const String contactPage ="https://settingsfiles.s3.us-east-1.amazonaws.com/Contact.html";
  static const String advertisePage =  "https://settingsfiles.s3.us-east-1.amazonaws.com/Advertise.html";
  static const String termsPage =  "https://settingsfiles.s3.us-east-1.amazonaws.com/Terms.html";
  static const String privacyPage = "https://settingsfiles.s3.us-east-1.amazonaws.com/Privacy.html";



///  https://chn-app-be-dev.azurewebsites.net/api/menuposts?type=2



}