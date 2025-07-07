import 'dart:developer';

import 'package:chotanews/aggricator_screens/settings_screen/referral_repo/referral_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralProvider extends ChangeNotifier{
  bool isLoading = false;
  var referralData = {};
  List referralRewardsList = [];
  List referralRewardsClaimed = [];
  Future getReferralStats() async {
    isLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? deviceId = preferences.getString("deviceId");
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId ?? "0",

    };

    try {
      Response response = await ReferralRepo().getReferralStats(userId);
      log("Referral posted successfully: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        referralData = data;
        notifyListeners();

      } else {
        log("Failed to post referral: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      log("Dio error while posting referral: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while posting referral: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future getAvailableRewards() async {
    referralRewardsList.clear();
    isLoading = true;
    try {
      Response response = await ReferralRepo().getAvailableRewards();
      log("Rewards posted successfully: ${response.data}");
      if (response.statusCode == 200) {
        referralRewardsList.addAll(response.data);
        log("Rewards list updated: ${referralRewardsList} items");
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
    referralRewardsClaimed.clear();
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
        referralRewardsClaimed.addAll(response.data);
        log("Get Rewards list updated: ${referralRewardsClaimed} items");
      } else {
        log("Failed to Get Rewards: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
      log("Dio error while getting Rewards: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while getting Rewards: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future postClaimedRewards(reward,providerName, otherNumber, isMyNumber) async {
    referralRewardsClaimed.clear();
    isLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body ={
      "user_id": userId ,
      "reward_id": reward['id'],
      "recharge_on_own_number": isMyNumber,
      "new_recharge_number": otherNumber,
      "service_provider": providerName,
      "ott_platform": "aha"
    };
    log('postClaminedRewardsbody $body');
    try {
      Response response = await ReferralRepo().getClaimedRewards(body);
      log("Rewards posted successfully: ${response.data}");
      if (response.statusCode == 200) {
        referralRewardsClaimed.addAll(response.data);
        log("Rewards list updated: ${referralRewardsClaimed} items");
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

  // final currentDownloads = referralProvider.referralData['downloads'];
  // final requiredReferrals = reward['required_referrals'] ?? 0;
  // SharedPreferences prefs = await SharedPreferences.getInstance();
  // await prefs.setString("rewardId", reward['id'].toString());
  // await referralProvider.postClaimedRewards();
  // if (currentDownloads >= requiredReferrals){
  // CustomToast.showSuccessToast(msg: "You have claimed reward successfully");
  // } else {
  // CustomToast.showErrorToast(msg: "You need ${requiredReferrals - currentDownloads} more referrals to claim this reward");
  // }

}

