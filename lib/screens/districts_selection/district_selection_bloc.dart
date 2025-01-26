import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'district_selection_event.dart';
import 'district_selection_model.dart';
import 'district_selection_repo.dart';
import 'district_selection_state.dart';

class DistrictSelectionBloc
    extends Bloc<DistrictSelectionEvent, DistrictSelectionState> {
  DistrictSelectionBloc() : super(InitialDistrictsState()) {
    List<DistrictModel> districtList = [];
    List<DistrictModel> filterDistrictsList = [];
    List<int> selectedDistrictList = [];

    on<SelectedDistrictsUpdate>((event, emit) async {
      if (selectedDistrictList.contains(event.selectedDistrict)) {
        log("remove ${event.selectedDistrict.toString()}");

        selectedDistrictList.remove(event.selectedDistrict);

        emit(SuccessDistrictsState(
            districtList: districtList,
            selectedDistrictList: selectedDistrictList, filterDistrictsList: filterDistrictsList));
      } else {
        log("add ${event.selectedDistrict.toString()}");

        selectedDistrictList.add(event.selectedDistrict);
        emit(SuccessDistrictsState(
            districtList: districtList,
            selectedDistrictList: selectedDistrictList, filterDistrictsList: filterDistrictsList));
      }
    });

    on<GetAllDistricts>((event, emit) async {
      emit(LoadingDistrictsState());
      try {
        Response response = await DistrictSelectionRepo().getAllDistricts();
        log(response.data.toString());
        List getData = response.data;

        districtList = getData
            .map(
              (e) => DistrictModel.fromJson(e),
            )
            .toList();
        filterDistrictsList =districtList;
        emit(SuccessDistrictsState(
            districtList: districtList, selectedDistrictList: [], filterDistrictsList: filterDistrictsList));
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
          districtList: districtList, selectedDistrictList: selectedDistrictList, filterDistrictsList: filterDistrictsList));});


    on<SubmitDistricts>((event, emit) async {
      emit(SubmitLoadingState());

      String result = selectedDistrictList.join(', ');
      log(result);
      var body={
        "deviceId":"2f6a5caebb387fee",
        "isFollowed":"true",
        "locationId":result,
        "type":"bulk",
      };
      try {
        Response response = await DistrictSelectionRepo().updateDistrictsList(body);
        log(response.data.toString());
        emit(SubmitSuccessState());
      } catch (e, st) {
      }
    });
  }
}
