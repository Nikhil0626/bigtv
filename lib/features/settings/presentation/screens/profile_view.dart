import 'package:chotanews/aggricator_screens/events_data/event_repo.dart';
import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import 'package:chotanews/features/auth/presentation/providers/authentication_provider.dart';
import 'package:chotanews/services/webengage_notification.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webengage_flutter/webengage_flutter.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  final FocusNode dayFocusNode = FocusNode();
  final FocusNode monthFocusNode = FocusNode();
  final FocusNode yearFocusNode = FocusNode();

  @override
  void initState() {
    context.read<ProfileProvider>().getProfile();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF1E2026) : const Color(0xFFF1F5F9);
    final textPrimaryColor = isDark ? Colors.white : Colors.black87;
    final textSecondaryColor = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF64748B);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0F0F0F) : Colors.white,
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
              child: Icon(
                Icons.arrow_back_outlined,
                size: 24.sp,
                color: textPrimaryColor,
              ),
            ),
          ),
          centerTitle: false,
          title: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              "Profile",
              style: newAppFont(
                color: textPrimaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        body: Consumer<ProfileProvider>(
          builder: (_, profileProvider, __) {
            return SafeArea(
              child: profileProvider.isMainLoading
                  ? Center(child: AppLoadingScreen())
                  : Column(
                      children: [
                        SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Stack(
                                    children: [
                                      SizedBox(
                                        height: 100,
                                        width: 100,
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(Radius.circular(50)),
                                          child: profileProvider.isProfileLoading
                                              ? AppLoadingScreen()
                                              : profileProvider.uploadImageUrl == ""
                                                  ? Icon(
                                                      Icons.person,
                                                      size: 100,
                                                      color: isDark ? Colors.white54 : Colors.grey,
                                                    )
                                                  : Image.network(
                                                      profileProvider.uploadImageUrl,
                                                      fit: BoxFit.fill,
                                                    ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: GestureDetector(
                                          onTap: () {
                                            profileProvider.pickAndUploadFile();
                                          },
                                          child: CircleAvatar(
                                            radius: 15.r,
                                            backgroundColor: isDark ? const Color(0xFF2E2E2E) : Colors.grey.shade400,
                                            child: Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: isDark ? Colors.white : Colors.black,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                height(height: 10.h),
                                Center(
                                  child: Text(
                                    profileProvider.profileData != null
                                        ? profileProvider.profileData['profile']['name'] ?? ""
                                        : "user",
                                    style: newAppFont(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w500,
                                      color: textPrimaryColor,
                                    ),
                                  ),
                                ),
                                height(height: 20.h),
                                Text(
                                  " Name",
                                  style: newAppFont(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: textSecondaryColor,
                                  ),
                                ),
                                height(height: 5.h),
                                TextField(
                                  controller: profileProvider.nameController,
                                  style: TextStyle(color: textPrimaryColor),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: cardBgColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10.r),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                                height(height: 20.h),
                                Text(
                                  "Date of Birth",
                                  style: newAppFont(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: textSecondaryColor,
                                  ),
                                ),
                                height(height: 5.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: profileProvider.dayController,
                                        focusNode: dayFocusNode,
                                        keyboardType: TextInputType.number,
                                        maxLength: 2,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: textPrimaryColor),
                                        decoration: InputDecoration(
                                          labelText: "DD",
                                          labelStyle: TextStyle(color: textSecondaryColor),
                                          counterText: "",
                                          filled: true,
                                          fillColor: cardBgColor,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value.length == 2) {
                                            FocusScope.of(context).requestFocus(monthFocusNode);
                                          }
                                        },
                                      ),
                                    ),
                                    width(width: 10.w),
                                    Expanded(
                                      child: TextField(
                                        controller: profileProvider.monthController,
                                        focusNode: monthFocusNode,
                                        keyboardType: TextInputType.number,
                                        maxLength: 2,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: textPrimaryColor),
                                        decoration: InputDecoration(
                                          labelText: "MM",
                                          labelStyle: TextStyle(color: textSecondaryColor),
                                          counterText: "",
                                          filled: true,
                                          fillColor: cardBgColor,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.r),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          if (value.length == 2) {
                                            FocusScope.of(context).requestFocus(yearFocusNode);
                                          }
                                        },
                                      ),
                                    ),
                                    width(width: 10.w),
                                    Expanded(
                                      child: TextField(
                                        controller: profileProvider.yearController,
                                        focusNode: yearFocusNode,
                                        keyboardType: TextInputType.number,
                                        maxLength: 4,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: textPrimaryColor),
                                        decoration: InputDecoration(
                                          labelText: "YYYY",
                                          labelStyle: TextStyle(color: textSecondaryColor),
                                          counterText: "",
                                          filled: true,
                                          fillColor: cardBgColor,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.r),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                height(height: 20.h),
                                Text(
                                  "Mobile Number",
                                  style: newAppFont(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: textSecondaryColor,
                                  ),
                                ),
                                height(height: 5.h),
                                Container(
                                  height: 55.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    color: cardBgColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 38.h,
                                        width: 90.w,
                                        margin: const EdgeInsets.symmetric(horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.r),
                                          color: isDark ? const Color(0xFF2E2E2E) : Colors.white,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 18.h,
                                              width: 24.w,
                                              child: SvgPicture.asset(
                                                'assets/svg/indianFlag.svg',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                            width(width: 4.w),
                                            Text(
                                              "+91",
                                              style: newAppFont(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold,
                                                color: textPrimaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: TextFormField(
                                          controller: profileProvider.phoneController,
                                          keyboardType: TextInputType.phone,
                                          readOnly: true,
                                          maxLength: 10,
                                          style: TextStyle(color: textPrimaryColor),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            counterText: "",
                                            hintText: "",
                                            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                          child: InkWell(
                            onTap: () {
                              if (!profileProvider.isProfileLoading) {
                                profileProvider.postProfile();
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 42.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFFED1C24),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Center(
                                child: profileProvider.isProfileLoading
                                    ? AppLoadingScreen()
                                    : Text(
                                        'Update',
                                        style: newAppFont(
                                          fontSize: 16.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6),
                          child: InkWell(
                            onTap: () {
                              if (!profileProvider.isProfileLoading) {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: isDark ? const Color(0xFF1E2026) : Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                                  ),
                                  builder: (BuildContext context1) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
                                          height(height: 12),
                                          Text(
                                            "Delete Account?",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: textPrimaryColor,
                                            ),
                                          ),
                                          height(height: 8),
                                          Text(
                                            "Are you sure you want to delete your account? This action cannot be undone.",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textSecondaryColor,
                                            ),
                                          ),
                                          height(height: 24),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  style: OutlinedButton.styleFrom(
                                                    side: BorderSide(color: isDark ? const Color(0xFF3E3E3E) : Colors.grey.shade300),
                                                  ),
                                                  child: Text(
                                                    "Cancel",
                                                    style: fontStyle(
                                                      color: textPrimaryColor,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              width(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                  ),
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    SharedPreferences preferences = await SharedPreferences.getInstance();
                                                    profileProvider.deleteAccount().then((value) {
                                                      if (!context.mounted) return;
                                                      closeSubscribe();

                                                      String? deviceId = preferences.getString("deviceId");
                                                      String? userId = preferences.getString("userId");

                                                      WebEngagePlugin.trackEvent('logout_user', {
                                                        "device_id": "$deviceId",
                                                        "date_time": DateTime.now().toString(),
                                                        "user_id": userId ?? "",
                                                      });
                                                      WebEngagePlugin.userLogout();
                                                      context.read<AuthenticationProvider>().setLogOutStatus(context, false);
                                                      EventRepo().addEvent({
                                                        "loginType": "Delete",
                                                        "mobileNumber": "",
                                                        "createAt": DateTime.now().toString(),
                                                      }, "delete_account");
                                                      preferences.clear();
                                                    });
                                                  },
                                                  child: Text(
                                                    "Delete",
                                                    style: fontStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          height(height: 10),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 42.h,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF251315) : const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(8.r),
                                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.5), width: 1),
                              ),
                              child: Center(
                                child: profileProvider.isProfileLoading
                                    ? AppLoadingScreen()
                                    : Text(
                                        'Delete account',
                                        style: newAppFont(
                                          fontSize: 16,
                                          color: const Color(0xFFEF4444),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}
