import 'package:chotanews/services/base_service.dart';
import 'package:chotanews/services/base_urls.dart';
import 'package:chotanews/utils/app_enums.dart';
import 'package:http/http.dart';

class AuthenticationRepo extends BaseService {
  Future sendOtp(Map<String, dynamic> body) async {
    Response response = await makeRequest(url: BaseUrls.sendOtp, method: RequestType.post,
        body: body, baseUrl: BaseUrls.baseUrlAws);
    return response;
  }
}
