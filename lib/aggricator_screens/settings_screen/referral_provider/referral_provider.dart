import 'dart:convert';
import 'dart:developer';

import 'package:chotanews/aggricator_screens/settings_screen/referral_repo/referral_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferralProvider extends ChangeNotifier {
  bool isLoading = false;
  var referralData = {};
  List referralRewardsList = [];
  List<ProvidersNamesModel> allProvidersRechargeList = [];
  List<ProvidersNamesModel> allProvidersOttList = [];
  var referralRewardsClaimed = {};

  double progress = 0.0;
  String selectedOperator = "";
  int difference = 0;

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

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        referralData = data;
        progress = int.parse(referralData['downloads'].toString()) / (int.parse(referralData['needed'].toString()) + int.parse(referralData['downloads'].toString()));
        difference = referralData['needed'] ?? 0;
        progress = progress.clamp(0.0, 1.0);
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

  Future postClaimedRewards(reward, providerName,{bool isRecharge = false}) async {
    referralRewardsClaimed.clear();
    isLoading = true;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userId = preferences.getString("userId");
    Map<String, dynamic> body = {
      "user_id": userId,
      "reward_id": reward['id'],
      "provider_id": isRecharge?0:selectedOperator,
    };
    log('postClaminedRewardsbody $body');
    try {
      Response response = await ReferralRepo().postClaimedRewards(body);
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

  Future getAllProvidersNames() async {
    try {
      Response response = await ReferralRepo().getAllProvidersNames();
      print('Data: ${response.data}');
      final Map<String, dynamic> jsonMap = response.data;
      print('Data: $jsonMap');
      allProvidersRechargeList = (jsonMap['mobile'] as List)
          .map((item) => ProvidersNamesModel.fromJson(item))
          .toList();

      allProvidersOttList = (jsonMap['ott'] as List)
          .map((item) => ProvidersNamesModel.fromJson(item))
          .toList();

      print('OTT: ${allProvidersRechargeList.map((e) => e.name)}');
      print('Data: ${allProvidersOttList.map((e) => e.name)}');

    } on DioException catch (e, st) {
    } catch (e, st) {
    } finally {
      notifyListeners();
    }
  }


  void updateProvider(value){
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
