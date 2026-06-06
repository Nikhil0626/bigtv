import 'dart:async';
import 'dart:developer';

import 'package:chotanews/features/auth/presentation/widgets/login_background_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../globel_keys/globel_keys.dart';
import '../../../utils/app_toasts.dart';
import '../../events_data/event_repo.dart';
import '../referral_repo/referral_repo.dart';
import '../referral_view/refer_earn.dart';

class ReferralProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isDataLoading = false;
  var referralData = {};
  List referralRewardsList = [];
  List<ProvidersNamesModel> allProvidersRechargeList = [];
  List<ProvidersNamesModel> allProvidersOttList = [];
  var referralRewardsClaimed = {};
  int totalRewards = 0;

  double progress = 0.0;
  String selectedOperator = "";
  int difference = 0;
  int _timercount = 10;
  Timer? _timer;

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timercount == 0) {
        _timer!.cancel();
      } else {
        _timercount--;
        if(_timercount == 0){
          Navigator.pop(mainNavigatorKey.currentContext!);
          Navigator.pushAndRemoveUntil(mainNavigatorKey.currentContext!, MaterialPageRoute(builder: (contexts) => LoginBackgroundView()), (route) => false);
        }
        notifyListeners();
      }
    });
  }

  void getData(SharedPreferences? preferences) async {
    myReferralCode = preferences!.getString("myReferralCode") ?? "N/A";
    myReferralLink = preferences!.getString("myReferralLink") ?? "N/A";
    userId = preferences!.getString("userId") ?? "N/A";
    log("get code $myReferralCode /////  get my link $myReferralLink");
    notifyListeners();
  }

  String? myReferralCode;
  String? myReferralLink;
  String? userId;

  Future getReferralStats(context,{bool isHome = false}) async {
    _timercount = 10;
    isDataLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");

    try {
      Response response = await ReferralRepo().getReferralStats(userId);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        referralData = data;
        progress = int.parse(referralData['balance_points'].toString()) / (int.parse(referralData['needed'].toString()) + int.parse(referralData['balance_points'].toString()));
        difference = int.parse(referralData['needed'].toString()) - int.parse(referralData['downloads'].toString());
        totalRewards = int.parse(referralData['balance_points'].toString()) + int.parse(referralData['needed'].toString());
        progress = progress.clamp(0.0, 1.0);
        log("Nikhil Goud: ${referralData['referral_code']}");
        log("Nikhil Goud k: ${referralData['referral_link']}");
        preferences.setString("myReferralCode", referralData['referral_code'].toString() ?? "");
        preferences.setString("myReferralLink", referralData['referral_link'].toString() ?? "");
        getData(preferences);
        if(isHome){
        ShareResult result = await Share.share(referralData['referral_link']);
        if (result.status == ShareResultStatus.success) {
          postProcessReferral(context);
          Navigator.push(
            (context),
            MaterialPageRoute(builder: (context) => ReferEarn()),
          );
        }
        }
      } else {
        log("Failed to post referral: ${response.statusCode}");
        if(response.statusCode == 404 && response.data['detail'] == "user not found or may be logged out,please login again"){
          referralData = {};
          startTimer();
          showUserInvalidPopUp(context);
        }
      }
      EventRepo().addEvent({
        "user_id": userId??"0",
        "referral_code": "${referralData['referral_code']}"
      }, "check_referral");
    } on DioException catch (e, st) {
      log("Failed to post referral: ${e.response?.statusCode}");
      log("Dio error while posting referral: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while posting referral: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isDataLoading = false;
      notifyListeners();
    }
  }

  Future getAvailableRewards() async {
    referralRewardsList = [];
    isLoading = true;
    try {
      Response response = await ReferralRepo().getAvailableRewards();
      log("Rewards posted successfully: ${response.data}");
      if (response.statusCode == 200) {
        referralRewardsList.addAll(response.data);
        log("Rewards list updated: $referralRewardsList items");
      } else {
        log("Failed to post Rewards: ${response.statusCode}");
      }

    } on DioException catch (e, st) {
      log("Dio error while posting Rewards: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while posting Rewards: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future getClaimedRewards() async {
    referralRewardsClaimed = {};
    isLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId ?? "0",
    };
    try {
      Response response = await ReferralRepo().getClaimedRewards(body);
      log("Rewards posted successfully: ${response.data}");
      if (response.statusCode == 200) {
        referralRewardsClaimed = response.data;
        log("Get Rewards list updated: $referralRewardsClaimed items");
      } else {
        log("Failed to Get Rewards: ${response.statusCode}");
      }

      EventRepo().addEvent({
        "user_id": userId??"0",
        "referral_code": "${referralData['referral_code']}"
      }, "check_claimed_rewards");
    } on DioException catch (e, st) {
      log("Dio error while getting Rewards: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while getting Rewards: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future postClaimedRewards(reward, providerName, {bool isRecharge = false} ) async {
    referralRewardsClaimed.clear();
    isLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId,
      "reward_id": reward['id'],
      "provider_id": isRecharge ? providerName : selectedOperator,
    };
    log('Calamined Rewards Body $body');
    try {
      Response response = await ReferralRepo().postClaimedRewards(body);
      log("Rewards posted successfully: ${response.data}");
      if (response.statusCode == 200) {
        referralRewardsClaimed.addAll(response.data);
        getReferralStats(mainNavigatorKey.currentContext!);
        if(!isRecharge) {
          Navigator.pop(mainNavigatorKey.currentContext!);
        }
        CustomToast.showSuccessToast(msg: "Reward Claimed Successfully");
        log("Rewards list updated: $referralRewardsClaimed items");
      } else {
        CustomToast.showErrorToast(msg: "${response.data["detail"] }", timeDuration: 3);
        log("Failed to post Rewards: ${response.statusCode}");
      }
      EventRepo().addEvent({
        "user_id": userId,
        "reward_id": reward['id'],
        "provider_id": isRecharge ? providerName : selectedOperator,
      }, "claimed_rewards");
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(msg: e.toString());
      log("Dio error while posting Rewards: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      CustomToast.showErrorToast(msg: e.toString());
      log("Unexpected error while posting Rewards: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future getAllProvidersNames() async {
    try {
      Response response = await ReferralRepo().getAllProvidersNames();
      log('Data: ${response.data}');
      final Map<String, dynamic> jsonMap = response.data;
      log('Data: $jsonMap');
      allProvidersRechargeList = (jsonMap['mobile'] as List).map((item) => ProvidersNamesModel.fromJson(item)).toList();

      allProvidersOttList = (jsonMap['ott'] as List).map((item) => ProvidersNamesModel.fromJson(item)).toList();

      log('OTT: ${allProvidersRechargeList.map((e) => e.name)}');
      log('Data: ${allProvidersOttList.map((e) => e.name)}');
    } on DioException catch (e, st) {
      log('error : ${e.toString()} --- ${st.toString()}');
    } catch (e, st) {
      log('error : ${e.toString()} --- ${st.toString()}');
    } finally {
      notifyListeners();
    }
  }

  Future<void> postProcessReferral(context) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? myReferralCode = preferences.getString("myReferralCode");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId??"0",
      "referral_code": "$myReferralCode"
    };
    log(body.toString());
    try {
      Response response = await ReferralRepo().postProcessReferral(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        getReferralStats(context);
      } else {}
      EventRepo().addEvent({
        "user_id": userId??"0",
        "referral_code": "$myReferralCode"
      }, "send_referral");
    } on DioException catch (e, st) {
      CustomToast.showErrorToast(msg: "something went wrong");
      log("Dio error while posting like: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      print(e.toString());
      print(st.toString());
    }finally{
      notifyListeners();
    }
  }

  void updateProvider(value) {
    selectedOperator = value;
    notifyListeners();
  }

  void showUserInvalidPopUp(contexti) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    showModalBottomSheet(
      context: contexti,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.7), // Optional: darker backdrop
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext contexts) {
        return PopScope(
          canPop: false, // Prevent back button
          child: Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 60,
                ),
                SizedBox(height: 16),
                Text(
                  "Referral Program Unavailable",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "The referral program is currently not available. Please try logging in again and joining the contest.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Consumer<ReferralProvider>(
                    builder: (context,referralProvider,__) {
                      return ElevatedButton(
                          onPressed: () {
                            // Restore system UI when navigating away
                            SystemChrome.setEnabledSystemUIMode(
                              SystemUiMode.edgeToEdge, // Restore normal UI mode
                            );
                            Navigator.pop(contexts);
                            Navigator.pushAndRemoveUntil(
                                contexts,
                                MaterialPageRoute(builder: (contexts) => LoginBackgroundView()),
                                    (route) => false
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Go to Login $_timercount",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                      );
                    }
                ),
                SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      // Ensure system UI is restored even if modal is dismissed unexpectedly
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }
}

class ProvidersNamesModel {
  final String name;
  final int id;

  ProvidersNamesModel({required this.name, required this.id});

  factory ProvidersNamesModel.fromJson(Map<String, dynamic> json) {
    return ProvidersNamesModel(
      name: json['name'],
      id: json['id'],
    );
  }
}
