import 'dart:developer';

import 'package:chotanews/districts_selection/district_selection_event.dart';
import 'package:chotanews/districts_selection/district_selection_repo.dart';
import 'package:chotanews/districts_selection/district_selection_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'district_selection_model.dart';

class DistrictSelectionBloc
    extends Bloc<DistrictSelectionEvent, DistrictSelectionState> {
  DistrictSelectionBloc() : super(InitialDistrictsState()) {
    List<DistrictModel> getAllDistrictsModelList = [];
    List<DistrictModel> filterDistrictsList = [];
    List<int> selectedDistrictList = [];

    on<SelectedDistrictsUpdate>((event, emit) async {
      if (selectedDistrictList.contains(event.selectedDistrict)) {
        log("remove ${event.selectedDistrict.toString()}");

        selectedDistrictList.remove(event.selectedDistrict);

        emit(SuccessDistrictsState(
            districtList: getAllDistrictsModelList,
            selectedDistrictList: selectedDistrictList, filterDistrictsList: filterDistrictsList));
      } else {
        log("add ${event.selectedDistrict.toString()}");

        selectedDistrictList.add(event.selectedDistrict);
        emit(SuccessDistrictsState(
            districtList: getAllDistrictsModelList,
            selectedDistrictList: selectedDistrictList, filterDistrictsList: filterDistrictsList));
      }
    });

    on<GetAllDistricts>((event, emit) async {
      emit(LoadingDistrictsState());
      try {
        Response response = await DistrictSelectionRepo().getAllDistricts();
        log(response.data.toString());
        List getData = response.data;
        getAllDistrictsModelList = getData
            .map(
              (e) => DistrictModel.fromJson(e),
            )
            .toList();
        filterDistrictsList =getAllDistrictsModelList;
        emit(SuccessDistrictsState(
            districtList: getAllDistrictsModelList, selectedDistrictList: [], filterDistrictsList: filterDistrictsList));
      } catch (e, st) {
        emit(ErrorDistrictsState(message: 'No Districts Available'));
      }
    });

    on<SearchDistricts>((event, emit) async {
      log(event.searchName);
      filterDistrictsList = getAllDistrictsModelList.where((user) {
        final query = event.searchName.toLowerCase();
        return user.value.toLowerCase().contains(query);
      }).toList();
      emit(SuccessDistrictsState(
          districtList: getAllDistrictsModelList, selectedDistrictList: selectedDistrictList, filterDistrictsList: filterDistrictsList));});
  }
}
