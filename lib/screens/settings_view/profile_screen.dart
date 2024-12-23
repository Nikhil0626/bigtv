import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tweetai/screens/settings_view/setting_provider.dart';

import '../../mixin_class/auth_mixin.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_spaces.dart';
import '../auth/login_screen.dart';
import '../home_screen/home_provider.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> with AuthMixin {
  String? pic;
  String? name;
  String? number;
  String? email;

  @override
  void initState() {
    loadUserData().then(
      (value) {
        name = userName!.toString();
        pic = profilePic!.toString();
        number = phoneNumber!.toString();
        email = userEmail!.toString();
        setState(() {});
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                height(height: 20),

                Center(
                  child: pic != null
                      ? ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    child: Image.network(
                      pic.toString(),
                      fit: BoxFit.cover,
                      height: 100,
                      width:100,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            "assets/chota.png",
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ); // Display an error icon
                        }
                    ),
                  )
                      :  Image.asset(
                    "assets/chota.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),

                height(height: 16),
                Text(
                  name.toString(),
                  style: fontStyle(
                    fontSize: 16,
                    color: AppColors.headerTextColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                height(height: 4),
                Text(
                  email.toString(),
                  style: fontStyle(
                    fontSize: 14,
                    color: AppColors.bodyTextColor,
                    fontWeight: FontWeight.normal,
                  ),
                ),

                height(height: 24),
                Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: AppColors.borderColor),
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(
                      'Edit Profile',
                      style: fontStyle(
                        fontSize: 14,
                        color: AppColors.headerTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      await context
                          .read<SettingProvider>()
                          .editUserDate(
                              userId, fName, lName, email, number, context)
                          .then((e) {
                        loadUserData().then((value) {
                          name = userName!.toString();
                          pic = profilePic!.toString();
                          number = phoneNumber!.toString();
                          email = userEmail!.toString();
                          setState(() {});
                        });
                      });
                    },
                  ),
                ),
                height(height: 16),
//                 Container(
//                   decoration: BoxDecoration(
// border: Border.all(width: 1,color: AppColors.borderColor),
//                       borderRadius: BorderRadius.all(Radius.circular(8))),
//                   // color: Colors.blue.shade50,
//                   child: ListTile(
//                     leading: const Icon(Icons.headset_mic),
//                     title: Text(
//                       'Support',
//                       style: fontStyle(
//                         fontSize: 14,
//                         color: AppColors.headerTextColor,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     trailing: const Icon(Icons.arrow_forward_ios),
//                     onTap: () {
//                       CustomToast.showInfoToast(msg: "Coming Soon...");
//                     },
//                   ),
//                 ),
                Container(
                  decoration: BoxDecoration(
                      border:
                          Border.all(width: 1, color: AppColors.borderColor),
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  child: ListTile(
                    leading: const Icon(Icons.logout),
                    title: Text(
                      'Logout',
                      style: fontStyle(
                        fontSize: 14,
                        color: AppColors.headerTextColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      SharedPreferences sp =
                          await SharedPreferences.getInstance();
                      sp.remove("accessToken");
                      sp.clear();
                      context.read<HomeProvider>().pageChange(0);
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  )
                ),
                const Spacer(),
                height(height: 10),
                Text(
                  "App Version : 1.0.0+5.2",
                  style: fontStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                height(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const FeatureButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        )
      ],
    );
  }
}
