


import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:http/http.dart';

class PollRepo extends BaseService{

  Future  submitPolls(body) async{
    Response response = await makeRequest(baseUrl: BaseUrls.baseUrlAwsDev,url: BaseUrls.submitPolls, body: body, method: RequestType.post);
    return response;
  }
}