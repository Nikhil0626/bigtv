import 'district_selection_model.dart';

abstract class DistrictSelectionState {}

class InitialDistrictsState extends DistrictSelectionState {}

class LoadingDistrictsState extends DistrictSelectionState {}

class SuccessDistrictsState extends DistrictSelectionState {
  final List<DistrictModel> districtList;
  final List<DistrictModel> filterDistrictsList;
  final List<int> selectedDistrictList;
  SuccessDistrictsState({required this.districtList,required this.filterDistrictsList,required this.selectedDistrictList});
}
class ErrorDistrictsState extends DistrictSelectionState {
   String message;
  ErrorDistrictsState({required this.message});
}






class SubmitLoadingState extends DistrictSelectionState{}
class SubmitSuccessState extends DistrictSelectionState{}
class SubmitErrorState extends DistrictSelectionState{}




