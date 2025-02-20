import 'dart:developer';

import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../globel_keys/app_router.dart';
import '../screens/videos_main/video_bloc/videos_state.dart';

class ReferralCode extends StatefulWidget {
  final String mobileNumber;

  const ReferralCode({super.key, required this.mobileNumber});

  @override
  State<ReferralCode> createState() => _ReferralCodeState();
}

class _ReferralCodeState extends State<ReferralCode> {
  TextEditingController referralCode = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _mobileNumberError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/svg/Chota_news_logo.svg',
                  height: 24,
                  width: 166,
                ),
                height(height: 34),
                Text(
                  "Sign in",
                  style: fontStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                height(height: 7),
                Text(
                  "Please enter the referral code shared by your friend. If you don’t have one, proceed with skip",
                  maxLines: 3,
                  style: fontStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                height(height: 20),
                Text(
                  "Apply Referral Code",
                  style: fontStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                height(height: 5),
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextFormField(
                    controller: referralCode,
                    keyboardType: TextInputType.text,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      counterText: "",
                      hintText: "Enter Referral Code",
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: (value) {
                      if (value.length == 8) {
                        _mobileNumberError = null;
                      }
                      setState(() {});
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() {
                          _mobileNumberError = "Please enter your Referral Code";
                        });
                        return "";
                      } else if (value.length != 8) {
                        setState(() {
                          _mobileNumberError = "Please enter a valid 8-digit Referral Code";
                        });
                        return "";
                      }
                      setState(() {
                        _mobileNumberError = null;
                      });
                      return null;
                    },
                  ),
                ),
                if (_mobileNumberError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 10.0),
                    child: Text(
                      _mobileNumberError!,
                      style: fontStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                height(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: referralCode.text.length == 8
                        ? () {
                      if (_formKey.currentState!.validate()) {
                        log("Referral Code: \${referralCode.text}");
                      }
                    }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: referralCode.text.length == 8
                          ? Colors.lightBlue
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Submit",
                      style: fontStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                height(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () async {
                      SharedPreferences sp = await SharedPreferences.getInstance();
                      sp.remove("sharedReferralCode");
                      if (!context.mounted) return;
                      Navigator.pushNamed(context, RoutesManager.districtSelectionScreen);
                    },
                    child: Text(
                      "Skip",
                      style: fontStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }
}
