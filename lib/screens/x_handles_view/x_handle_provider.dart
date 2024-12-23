import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:tweetai/screens/x_handles_view/x_handles_model.dart';
import 'package:tweetai/utils/app_toasts.dart';

import '../auth/auth_repo.dart';

class XHandleProvider extends ChangeNotifier {
  List<XHandlesTweetsModel> getTwitterHandlesList = [];
  List<XHandlesTweetsModel> filterTwitterHandlesList = [];
  TextEditingController xHandleSearchController =  TextEditingController();
  bool isEngageTweetsLoading = false;
  bool addXHandleLoading = false;

  /// Get All XHandles
  Future getTwitterHandles() async {
    isEngageTweetsLoading = true;
    try {
      Response response = await AppRepo().getTwitterHandles();

      if (response.statusCode == 200) {
        List data = response.data;
        getTwitterHandlesList = data
            .map(
              (e) => XHandlesTweetsModel.fromJson(e),
            )
            .toList();

        filterTwitterHandlesList = getTwitterHandlesList;
        log("getTwitterHandlesList---- ${getTwitterHandlesList.length}");
        isEngageTweetsLoading = false;
        notifyListeners();
      }
    } on DioException catch (e, st) {
      log("dio error --- ${st}");
    } catch (e, st) {
      log("error --- ${st}");
    } finally {
      isEngageTweetsLoading = false;
      notifyListeners();
    }
  }

  /// delete xHandle
  Future deleteHandle(
      index, XHandlesTweetsModel item, BuildContext context) async {
    addXHandleLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> body = {
        "ids": [item.id]
      };
      log(body.toString());
      Response response = await AppRepo().deleteHandle(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        filterTwitterHandlesList.removeAt(index);
        addXHandleLoading = false;
        notifyListeners();
        CustomToast.showSuccessToast(msg: response.data['message']).then((value) =>   Navigator.pop(context),);
      
      }
    } on DioException catch (e, st) {
      log(st.toString());
      log(e.toString());
    } catch (e, st) {
      log(st.toString());
      log(e.toString());
    } finally {
      addXHandleLoading = false;
      notifyListeners();
    }
  }

  Future editHandle(item, id, context) async {
    addXHandleLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> body = {"url": item};
      log(body.toString());
      Response response = await AppRepo().editHandle(body, id);

      if (response.statusCode == 200) {
        addXHandleLoading = false;
        notifyListeners();

       await getTwitterHandles().then((val) =>
            CustomToast.showSuccessToast(msg: response.data['message']).then((value) =>   Navigator.pop(context),));
      }
    } on DioException catch (e, st) {
      log(st.toString());
      log(e.toString());
    } catch (e, st) {
      log(st.toString());
      log(e.toString());
    } finally {
      addXHandleLoading = false;
      notifyListeners();
    }
  }

  Future addHandle(item, context) async {
    addXHandleLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> body = {
        "handles": [
          {"url": item}
        ]
      };
      log(body.toString());
      Response response = await AppRepo().addHandle(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        addXHandleLoading = false;
        notifyListeners();
        await getTwitterHandles().then((val) =>
            CustomToast.showSuccessToast(msg: response.data['message']).then((value) =>   Navigator.pop(context),));
      }
    } on DioException catch (e, st) {
      log(st.toString());
      log(e.toString());
    } catch (e, st) {
      log(st.toString());
      log(e.toString());
    } finally {
      addXHandleLoading = false;
      notifyListeners();
    }
  }

  Future statusChangeUser(id, context) async {
    addXHandleLoading = true;
    notifyListeners();
    try {
      Map<String, dynamic> body = {
        "ids": [id],
        "path": true
      };
      log(body.toString());
      Response response = await AppRepo().blockUser(body);
      log(response.data.toString());
      if (response.statusCode == 200) {
        addXHandleLoading = false;
        notifyListeners();
        await getTwitterHandles().then((val) {
           Navigator.pop(context);
            CustomToast.showSuccessToast(msg: response.data['message']);});
      }
    } on DioException catch (e, st) {
      log(st.toString());
      log(e.toString());
    } catch (e, st) {
      log(st.toString());
      log(e.toString());
    } finally {
      addXHandleLoading = false;
      notifyListeners();
    }
  }

  /// search XHandles
  void searchXHandle(String value, BuildContext context) {
    log(value);
    filterTwitterHandlesList = getTwitterHandlesList.where((xHandle) {
      final query = value.toLowerCase();
      return xHandle.profileName.toString().toLowerCase().contains(query)||
      xHandle.username.toString().toLowerCase().contains(query)||
      xHandle.url.toString().toLowerCase().contains(query);
    }).toList();
    notifyListeners();
  }
}
