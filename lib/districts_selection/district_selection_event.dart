abstract class DistrictSelectionEvent {}

class  GetAllDistricts extends DistrictSelectionEvent{}


class SelectedDistrictsUpdate extends DistrictSelectionEvent{
 final int selectedDistrict;
 SelectedDistrictsUpdate ({required this.selectedDistrict});
}
class SearchDistricts extends DistrictSelectionEvent{
final String searchName ;
SearchDistricts({required this.searchName});
}