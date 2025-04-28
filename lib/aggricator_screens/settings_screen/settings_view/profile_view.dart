import 'dart:io';

import 'package:chotanews/aggricator_screens/settings_screen/settings_provider/profile_provider.dart';
import 'package:chotanews/screens/profile_screen/profile_screen.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../utils/app_colors.dart';
import '../settings_provider/settings_provider.dart';
import 'settings_view.dart';

class ProfileView extends StatefulWidget {
  ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context,
                MaterialPageRoute(builder: (context) => SettingsView()));
          },
        ),
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            "Profile",
            style: newAppFont(
                color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (_,profileProvider,__) {
          return SafeArea(
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
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
                             borderRadius: BorderRadius.all(Radius.circular(50)),
                              child:profileProvider.isProfileLoading?AppLoadingScreen():profileProvider.uploadImageUrl == ""?Icon(Icons.person,size: 100,): Image.network(profileProvider.uploadImageUrl,fit: BoxFit.fill,),
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
                                backgroundColor: Colors.grey.shade400,
                                child:
                                    Icon(Icons.edit, size: 18, color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    height(height: 10.h),
                    Center(
                      child: Text(
                        profileProvider.profileData !=null? profileProvider.profileData['profile']['name']??"":"user",
                        style: newAppFont(
                            fontSize: 20.sp, fontWeight: FontWeight.w500),
                      ),
                    ),
                    height(height: 20.h),

                    Text(" Name",
                        style: newAppFont(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                    height(height: 5.h),
                    TextField(
                      controller: profileProvider.nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.cardBackgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    height(height: 20.h),

                    // Date of Birth Fields
                    Text("Date of Birth",
                        style: newAppFont(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
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
                            decoration: InputDecoration(
                              labelText: "DD",
                              counterText: "",
                              filled: true,
                              fillColor: AppColors.cardBackgroundColor,
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
                            decoration: InputDecoration(
                              labelText: "MM",
                              counterText: "",
                              filled: true,
                              fillColor: AppColors.cardBackgroundColor,
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
                            decoration: InputDecoration(
                              labelText: "YYYY",
                              counterText: "",
                              filled: true,
                              fillColor: AppColors.cardBackgroundColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    height(height: 15.h),

                    // Mobile Number Field
                    Text("Mobile Number",
                        style: newAppFont(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87)),
                    height(height: 5.h),
                    Container(
                      height: 55.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        // border: Border.all(color: Colors.grey.shade300),
                        color:AppColors.cardBackgroundColor,
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 38.h,
                            width: 90.w,
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              color: Colors.white,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                SizedBox(
                                  height: 18.h,
                                  width: 24.w,
                                  child: SvgPicture.asset(
                                      'assets/svg/indianFlag.svg',
                                      fit: BoxFit.contain),
                                ),
                                width(width: 4.w),
                                Text("+91",
                                    style: newAppFont(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),

                              ],
                            ),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: profileProvider.phoneController,
                              keyboardType: TextInputType.phone,
                              readOnly: true,
                              maxLength: 10,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                counterText: "",
                                hintText: "",
                                fillColor: AppColors.cardBackgroundColor,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 18, horizontal: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    height(height: 100.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          profileProvider.isProfileLoading?Colors.grey: Colors.blue ,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.r)),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed:(){
                          if(profileProvider.isProfileLoading){}else {
                            profileProvider.postProfile();
                          }
                        },
                        child: profileProvider.isProfileLoading?AppLoadingScreen():Text('Update',
                            style: newAppFont(
                                fontSize: 18.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
