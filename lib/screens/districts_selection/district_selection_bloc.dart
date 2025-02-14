import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../globel_keys/global_variables_data.dart';
import 'district_selection_event.dart';
import 'district_selection_model.dart';
import 'district_selection_repo.dart';
import 'district_selection_state.dart';

class DistrictSelectionBloc
    extends Bloc<DistrictSelectionEvent, DistrictSelectionState> {
  DistrictSelectionBloc() : super(InitialDistrictsState()) {
    List<DistrictModel> districtList = [];
    List<DistrictModel> filterDistrictsList = [];
    List<String> selectedDistrictList = [];

    on<SelectedDistrictsUpdate>((event, emit) async {
      if (selectedDistrictList.contains(event.selectedDistrict)) {
        log("remove ${event.selectedDistrict.toString()}");

        selectedDistrictList.remove(event.selectedDistrict);

        emit(SuccessDistrictsState(
            districtList: districtList,
            selectedDistrictList: selectedDistrictList,
            filterDistrictsList: filterDistrictsList));
      } else {
        log("add ${event.selectedDistrict.toString()}");

        selectedDistrictList.add(event.selectedDistrict.toString());
        emit(SuccessDistrictsState(
            districtList: districtList,
            selectedDistrictList: selectedDistrictList,
            filterDistrictsList: filterDistrictsList));
      }
    });

    on<GetAllDistricts>((event, emit) async {
      emit(LoadingDistrictsState());
      try {
        print("selectedDistrictList.toString()");
        SharedPreferences sharedPreferences =
            await SharedPreferences.getInstance();
        String result = sharedPreferences.getString("locationId") ?? "";
        print("selectedDistrictList.toString()   $result");
        selectedDistrictList = result.toString().isEmpty?[]:result.split(',');
        print(selectedDistrictList.toString());
        Response response = await DistrictSelectionRepo().getAllDistricts();
        log(response.data.toString());
        List getData = response.data;

        districtList = getData
            .map(
              (e) => DistrictModel.fromJson(e),
            )
            .toList();
        filterDistrictsList = districtList;
        emit(SuccessDistrictsState(
            districtList: districtList,
            selectedDistrictList: selectedDistrictList,
            filterDistrictsList: filterDistrictsList));
      } catch (e, st) {
        emit(ErrorDistrictsState(message: 'No Districts Available'));
      }
    });

    on<SearchDistricts>((event, emit) async {
      log(event.searchName);
      filterDistrictsList = districtList.where((user) {
        final query = event.searchName.toLowerCase();
        return user.value.toLowerCase().contains(query);
      }).toList();
      emit(SuccessDistrictsState(
          districtList: districtList,
          selectedDistrictList: selectedDistrictList,
          filterDistrictsList: filterDistrictsList));
    });

    on<SubmitDistricts>((event, emit) async {
      emit(SubmitLoadingState());
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.remove(
        "locationId",
      );
      String result = selectedDistrictList.toSet().join(',');
      sharedPreferences.setString("locationId", result);
      log(result);
      String? deviceId = GlobalVariables().deviceId;
      print("Device ID: ${deviceId}");
      var body = {
        "deviceId": deviceId.toString(),
        "isFollowed": "true",
        "locationId": result,
        "type": "bulk",
      };
      try {
        Response response =
            await DistrictSelectionRepo().updateDistrictsList(body);
        log(response.data.toString());
        selectedDistrictList = [];
        emit(SubmitSuccessState(className:event.className));
      } catch (e, st) {}
    });
  }
}
