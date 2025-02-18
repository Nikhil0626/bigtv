import 'package:flutter/cupertino.dart';

abstract class DistrictSelectionEvent {}

class  GetAllDistricts extends DistrictSelectionEvent{}


class SelectedDistrictsUpdate extends DistrictSelectionEvent{
 final String selectedDistrict;
 SelectedDistrictsUpdate ({required this.selectedDistrict});
}


class SearchDistricts extends DistrictSelectionEvent{
final String searchName ;
SearchDistricts({required this.searchName});
}


class SubmitDistricts extends DistrictSelectionEvent{
 final String className ;
 final BuildContext context;
 SubmitDistricts({required this.className,required this.context,});
}