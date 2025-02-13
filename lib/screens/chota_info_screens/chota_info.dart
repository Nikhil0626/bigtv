import 'dart:developer';

import 'package:chotanews/screens/chota_info_screens/about_us.dart';
import 'package:chotanews/screens/chota_info_screens/advertise_with_us.dart';
import 'package:chotanews/screens/chota_info_screens/contact_us.dart';
import 'package:chotanews/screens/chota_info_screens/privacy_policy.dart';
import 'package:chotanews/screens/chota_info_screens/terms_conditions.dart';
import 'package:chotanews/screens/home_screen/home_screen_view.dart';
import 'package:chotanews/screens/profile_screen/profile_screen.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:chotanews/utils/app_toasts.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

import '../../globel_keys/app_router.dart';
import '../new_refer_earn_screen/new_refer_earn_screen.dart';
import '../videos_main/tab_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.settingsPageBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.appButtonColor,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
        title: Row(
          children: [
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                "సెట్టింగ్స్",
                style: fontStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          spacing: 16,
          children: [
            // InkWell(
            //
            //     onTap: () async{
            //       SharedPreferences sp = await SharedPreferences.getInstance();
            //       String? getCode= sp.getString("referralCode");
            //       String loginId = sp.getString("loginId")??"";
            //       if ( loginId.isEmpty) {
            //         CustomToast.showErrorToast(msg: "Without login we can't referral");
            //       } else {
            //
            //      final DynamicLinkParameters parameters = DynamicLinkParameters(
            //        uriPrefix: 'https://chotanews.page.link', // Make sure this matches Firebase Console
            //        link: Uri.parse('https://chotanews.com/store?referralCode=$getCode'), // Ensure this is a valid URL
            //        androidParameters: const AndroidParameters(
            //          packageName: 'com.chotanews', // Ensure this matches your AndroidManifest.xml
            //        ),
            //        iosParameters: const IOSParameters(
            //          bundleId: 'com.chotanewstelugu.app', // Ensure this matches Firebase Console
            //          appStoreId: '1631068092',
            //        ),
            //      );
            //
            //      try {
            //        final ShortDynamicLink shortLink =
            //        await FirebaseDynamicLinks.instance.buildShortLink(parameters);
            //        print("Short Link Created: ${shortLink.shortUrl}");
            //        Navigator.push(
            //          context,
            //          MaterialPageRoute(
            //              builder: (context) =>  NewReferEarnScreen(shortLink:shortLink.shortUrl.toString(),getCode:getCode.toString())),
            //        );
            //      } catch (e) {
            //        print("Error creating dynamic link: $e");
            //      }
            //    }
            //
            //
            //     },
            //     child: Container(
            //       decoration: BoxDecoration(
            //         color: isDarkTheme ? Colors.grey[800] : Colors.white,
            //         borderRadius: BorderRadius.circular(8),
            //         boxShadow: const [
            //           BoxShadow(
            //             color: Colors.black12,
            //             blurRadius: 20,
            //             spreadRadius: 1,
            //             offset: Offset(0, 4), // Adjust shadow position
            //           ),
            //         ],
            //       ),
            //       margin: const EdgeInsets.symmetric(horizontal: 8),
            //       child: Padding(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //         child: Row(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             SvgPicture.asset(
            //               'assets/settings_icons/refer_earn.svg',
            //               height: 40,
            //               width: 40,
            //             ),
            //             SizedBox(width: 16),
            //             Text(
            //               'Refer&Earn',
            //               style: fontStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w500,
            //                 color: isDarkTheme ? Colors.white : Colors.black,
            //               ),
            //             ),
            //             Spacer(),
            //             const Icon(
            //               Icons.arrow_forward_ios,
            //               size: 20,
            //             ),
            //           ],
            //         ),
            //       ),
            //     )),
            // InkWell(
            //     onTap: () async{
            //       SharedPreferences sp = await SharedPreferences.getInstance();
            //       String? getCode= sp.getString("referralCode");
            //       final DynamicLinkParameters parameters = DynamicLinkParameters(
            //         uriPrefix: 'https://chotanews.page.link', // Make sure this matches Firebase Console
            //         link: Uri.parse('https://chotanews.com/store?referralCode=$getCode'), // Ensure this is a valid URL
            //         androidParameters: const AndroidParameters(
            //           packageName: 'com.chotanews', // Ensure this matches your AndroidManifest.xml
            //         ),
            //         iosParameters: const IOSParameters(
            //           bundleId: 'com.chotanewstelugu.app', // Ensure this matches Firebase Console
            //           appStoreId: '1631068092',
            //         ),
            //       );
            //
            //       try {
            //         final ShortDynamicLink shortLink =
            //             await FirebaseDynamicLinks.instance.buildShortLink(parameters);
            //         print("Short Link Created: ${shortLink.shortUrl}");
            //         Share.share('${shortLink.shortUrl}');
            //       } catch (e) {
            //         print("Error creating dynamic link: $e");
            //       }
            //     },
            //     child: Container(
            //       decoration: BoxDecoration(
            //         color: isDarkTheme ? Colors.grey[800] : Colors.white,
            //         borderRadius: BorderRadius.circular(8),
            //         boxShadow: const [
            //           BoxShadow(
            //             color: Colors.black12,
            //             blurRadius: 20,
            //             spreadRadius: 1,
            //             offset: Offset(0, 4), // Adjust shadow position
            //           ),
            //         ],
            //       ),
            //       margin: const EdgeInsets.symmetric(horizontal: 8),
            //       child: Padding(
            //         padding:
            //             const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //         child: Row(
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             SvgPicture.asset(
            //               'assets/settings_icons/shareapp_icon.svg',
            //               height: 40,
            //               width: 40,
            //             ),
            //             width(width: 16),
            //             Text(
            //               'Share app',
            //               style: fontStyle(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w500,
            //                 color: isDarkTheme ? Colors.white : Colors.black,
            //               ),
            //             ),
            //             Spacer(),
            //             const Icon(
            //               Icons.arrow_forward_ios,
            //               size: 20,
            //             ),
            //           ],
            //         ),
            //       ),
            //     )),
            InkWell(
                onTap: ()async {
                  if (await canLaunch(BaseUrls.contactPage)) {
                    await launch(BaseUrls.contactPage);
                  } else {
                    CustomToast.showErrorToast(msg: "Could not launch ${BaseUrls.contactPage}");}
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => const ContactUs()),
                  // );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: Offset(0, 4), // Adjust shadow position
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/settings_icons/contactus_icon.svg',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'కాంటాక్ట్ అస్',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:  Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () async {
                  if (await canLaunch(BaseUrls.advertisePage)) {
                    await launch(BaseUrls.advertisePage);
                  } else {
                    CustomToast.showErrorToast(msg: "Could not launch ${BaseUrls.advertisePage}");}
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const AdvertiseWithUs()),
                  // );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:  Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: Offset(0, 4), // Adjust shadow position
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/settings_icons/advertise_icon.svg',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'ఆడ్వర్టైజ్ విత్ అస్',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(

                onTap: () async {
                  if (await canLaunch(BaseUrls.termsPage)) {
                    await launch(BaseUrls.termsPage);
                  } else {
                    CustomToast.showErrorToast(msg: "Could not launch ${BaseUrls.termsPage}");}
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const AdvertiseWithUs()),
                  // );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color:Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/settings_icons/terms_conditions_icon.svg',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'టర్మ్స్ అండ్ కండీషన్స్',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
                onTap: () async {
                  if (await canLaunch(BaseUrls.privacyPage)) {
                    await launch(BaseUrls.privacyPage);
                  } else {
                    CustomToast.showErrorToast(msg: "Could not launch ${BaseUrls.privacyPage}");}
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const AdvertiseWithUs()),
                  // );
                },

                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => const PrivacyPolicy()),
                //   );
                // },
                child: Container(
                  decoration: BoxDecoration(
                    color:  Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 1,
                        offset: Offset(0, 4), // Adjust shadow position
                      ),
                    ],
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/settings_icons/privacy_policy.svg',
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'ప్రైవసీ పాలసీ',
                          style: fontStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color:  Colors.black,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                )),
            InkWell(
              onTap: () async {
                WebEngagePlugin.userLogout();
                SharedPreferences sp = await SharedPreferences.getInstance();
                await sp.remove("loginId"); // Remove only loginId
                setState(() {}); // Force UI update after logout
                Navigator.pushNamed(context, RoutesManager.signInScreen);
              },
              child:  Container(
                decoration: BoxDecoration(
                  color:  Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/settings_icons/logout_icon.svg',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isLogin? 'లాగౌట్':'లాగిన్',
                        style: fontStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),




            const Spacer(),
            Container(
                height: 40,
                padding: const EdgeInsets.only(bottom: 20),
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "App Version: 1.0.0+6",
                  style: fontStyle(
                    fontSize: 14,
                  ),
                ))
          ],
        ),
      ),
    );
  }
  bool isLogin=false;
  Future  getLogin()  async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String loginId = sharedPreferences.getString("loginId")??"";
    log(loginId.toString());
    if ( loginId.isNotEmpty && loginId != "Skip") {
      isLogin=true;
    } else {
      isLogin=false;
    }
    setState(() {

    });
  }
}
