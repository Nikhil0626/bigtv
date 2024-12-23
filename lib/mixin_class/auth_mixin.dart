
import 'package:shared_preferences/shared_preferences.dart';


mixin AuthMixin {
  String? userName;
  String? lName;
  String? fName;
  String? userEmail;
  String? profilePic;
  String? userId;
  String? phoneNumber;

    Future<void> setUserData(String name, String email,String pic,String id,String phone,String lNames, String fNames) async {
    userName = name;
    lName = lNames;
    fName = fNames;
    userEmail = email;
    profilePic = pic;
    userId = id;
    phoneNumber = phone;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('lName', lNames);
    await prefs.setString('fName', fNames);
    await prefs.setString('userEmail', email);
    await prefs.setString('profilePic', pic);
    await prefs.setString('id', id);
    await prefs.setString('phoneNumber', phone);
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName');
    lName = prefs.getString('lName');
    fName = prefs.getString('fName');
    userEmail = prefs.getString('userEmail');
    profilePic = prefs.getString('profilePic');
    userId = prefs.getString('id');
    phoneNumber = prefs.getString('phoneNumber');
  }

  String getUserName() => userName ?? 'Guest';
  String getUserEmail() => userEmail ?? 'No email';
  String getUserUserId() => userId ?? 'No UserId';
  String getUserProfilePic() => profilePic ?? 'No pic';
  String getUserPhoneNumber() => phoneNumber ?? 'No Number';
  String getLastName() => lName ?? 'No Number';
  String getFirstName() => fName ?? 'No Number';
}
