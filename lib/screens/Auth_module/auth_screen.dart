// import 'package:chotanews/globel_keys/app_router.dart';
// import 'package:chotanews/screens/Auth_module/auth_bloc.dart';
// import 'package:chotanews/screens/Auth_module/auth_event.dart';
// import 'package:chotanews/screens/Auth_module/auth_state.dart';
// import 'package:chotanews/utils/app_colors.dart';
// import 'package:chotanews/utils/app_loading_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../utils/app_buttons.dart';
// import '../../utils/app_fonts.dart';
// import '../../utils/app_spaces.dart';
// import '../../welcome_screens/welcome_screen.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: AppColors.appButtonColor,
//         centerTitle: true,
//         title: Image.asset(
//           "assets/images/brandLogoWhiteBlackBlue.png",
//           width: 200,
//         ),
//       ),
//       body:  BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if(state is SuccessScreen){
//             Navigator.pushNamed(context, RoutesManager.districtSelectionScreen);
//           }
//         },
//         builder: (context,state) {
//           return
//             state is LoadingScreen?AppLoadingScreen():
//             Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               height(height: 20),
//               Container(
//                   decoration:  BoxDecoration(
//                     border: Border.all(color: AppColors.headerTextColor,width: 1),
//                       borderRadius: const BorderRadius.all(
//                         Radius.circular(50),
//                       ),boxShadow: [
//                     BoxShadow(
//                       color: Colors.blueGrey.withOpacity(0.2),
//                       spreadRadius: 5,
//                       blurRadius: 7,
//                       offset: const Offset(-7.5, 7.5),
//                     ),
//                   ],
//                       color: AppColors.appButtonColor),
//                   child: const CircleAvatar(backgroundImage: AssetImage("assets/images/icon.png"),radius: 50,)),
//               height(height: 20),
//                Container(
//                  padding: const EdgeInsets.symmetric(horizontal: 16),
//                 height: 300,
//                 width: MediaQuery.of(context).size.width,
//                 child: Card(
//                   elevation: 10,
//
//                   color: Colors.white,
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 12),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       spacing: 15,
//                       children: [
//
//                         Text("Login",style: fontStyle(color: AppColors.appButtonColor,fontWeight: FontWeight.bold,fontSize: 20),),
//                         CommonButton(
//                           text: 'Login With Mobile',
//                           textColor: Colors.white,
//                           shape: const BoxDecoration(
//                             borderRadius: const BorderRadius.all(Radius.circular(8)),
//                             color: AppColors.appButtonColor,
//                           ),
//                           onPressed: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(builder: (context) =>  WelcomeScreen()),
//                             );
//                           },
//                         ),
//                          CommonButton(
//                           text: 'Login With Google',
//                           onPressed:  () => context.read<AuthBloc>().add(GoogleLogin()),
//                           textColor: Colors.white,
//                           shape: const BoxDecoration(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(8),
//                               ),
//                               color: AppColors.appButtonColor),
//                         ),
//                          CommonButton(
//                           onPressed:  () => context.read<AuthBloc>().add(AppleLogin()),
//                           text: 'Login With Apple',
//                           textColor: Colors.white,
//                           shape: const BoxDecoration(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(8),
//                               ),
//                               color: AppColors.appButtonColor),
//                         ),
//                          CommonButton(
//                           text: 'Skip',
//                           onPressed:  () => context.read<AuthBloc>().add(SkipLogin()),
//                           textColor: Colors.white,
//                           shape: const BoxDecoration(
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(8),
//                               ),
//                               color: AppColors.appButtonColor),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         }
//       ),
//     );
//   }
// }
