import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../globel_keys/globel_keys.dart';
import '../../../utils/app_toasts.dart';
import '../referral_repo/referral_repo.dart';

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

  Future getReferralStats() async {
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
      // Response response = await ReferralRepo().getReferralStats(userId);
      //
      // if (response.statusCode == 200) {
      //   final data = response.data as Map<String, dynamic>;
      //   referralData = data;
      //   progress = int.parse(referralData['downloads'].toString()) / (int.parse(referralData['needed'].toString()));
      //   difference = int.parse(referralData['needed'].toString()) - int.parse(referralData['downloads'].toString());
      //   progress = progress.clamp(0.0, 1.0);
      } else {
        log("Failed to post referral: ${response.statusCode}");
      }
    } on DioException catch (e, st) {
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
    } on DioException catch (e, st) {
      log("Dio error while getting Rewards: ${e.toString()} ---- ${st.toString()}");
    } catch (e, st) {
      log("Unexpected error while getting Rewards: ${e.toString()} ---- ${st.toString()}");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future postClaimedRewards(reward, providerName, {bool isRecharge = false}) async {
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
        getReferralStats();
        if(!isRecharge) {
          Navigator.pop(mainNavigatorKey.currentContext!);
        }
        CustomToast.showSuccessToast(msg: "Reward Claimed Successfully");
        log("Rewards list updated: $referralRewardsClaimed items");
      } else {
        CustomToast.showErrorToast(msg: "${response.data["detail"] }", timeDuration: 3);
        log("Failed to post Rewards: ${response.statusCode}");
      }
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

  Future<void> postProcessReferral() async {
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
        getReferralStats();
      } else {}
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
