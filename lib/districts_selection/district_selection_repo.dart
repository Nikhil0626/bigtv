import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:dio/dio.dart';

class DistrictSelectionRepo extends BaseService{
  Future getAllDistricts() async {
    Response response = await makeRequest(url:BaseUrls.getAllDistricts,method: RequestType.get );
    return response ;
  }
}