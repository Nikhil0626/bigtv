import 'dart:core';

class BaseUrls {

 /// Dev Base Url
 //   static const String baseUrl = "https://chotanews-fdcscrezbfd4befm.z01.azurefd.net/api";
  static const String baseUrl = "https://chotanews-prod-api.azurewebsites.net/api";
  static const String baseUrlAws = "https://devchota.signitivessoft.com/api";


  static const String getNews = "/allposts";
  static const String getPostById = "/post";
static const String getAllDistricts = "/user/1/locations";

static const String updateDistricts ="/upsert/location";

  static const String getAllVideos = "/menuposts";
  static const String appMenu = "/app/menu";


  ///Add Comment
  static const String addComment = "/addcomment";

  ///getUserDetail
  static const String userInfo = "/userinfo";
  static const String addDevice = "/adddevice";

  ///like post
  static const String likePost = "/post/likes";

  ///Auth Apis
  static const String sendOtp = "/generateOtp";
  static const String sendCode= "/validateReferalCode";
  static const String validateOtp = "/validateOtp";

  ///  https://chn-app-be-dev.azurewebsites.net/api/menuposts?type=2



}