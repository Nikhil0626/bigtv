import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/mixin_class/auth_mixin.dart';
import 'package:tweetai/screens/settings_view/setting_provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_spaces.dart';
import '../../utils/app_textformfield.dart';

class AddUserScreen extends StatefulWidget {
  final String screenType;

  const AddUserScreen({super.key, required this.screenType});

  @override
  State<AddUserScreen> createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> with AuthMixin{
  final _formKey = GlobalKey<FormState>();

var img;
  @override
  void initState() {
    if (widget.screenType == "add") {
      context.read<SettingProvider>().firstNameController.text = "";
      context.read<SettingProvider>().lastNameController.text = "";
      context.read<SettingProvider>().emailController.text = "";
      context.read<SettingProvider>().phoneNumberController.text = "";
      context.read<SettingProvider>().passwordController.text = "";
    }
  loadUserData().then((value){
    img = profilePic;
    context.read<SettingProvider>().selectedFile = null;
    log("hello ${context.read<SettingProvider>().selectedFile.toString()}",);
    setState(() {

    });
  },);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.screenType == "edit"
              ? "Edit Profile Screen"
              : "Add Profile Screen",
          style: fontStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.headerTextColor,
          ),
        ),
      ),
      body: Consumer<SettingProvider>(builder: (_, homeProvider, __) {

        return SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.screenType == "edit") height(height: 10),
                    if (widget.screenType == "edit")
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            homeProvider.pickAndUploadFile();
                          },
                          child: homeProvider.selectedFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.file(
                                    homeProvider.selectedFile!,
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width:100,
                                  ),
                                )
                              :  ClipRRect(
                            borderRadius: const BorderRadius.all(Radius.circular(50)),
                                  child: Image.network(
                                    img,
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
                                ),
                        ),
                      ),
                    height(height: 10),
                    AppTextFormField(
                        prefixIcon: Icons.perm_identity_rounded,
                        textEditingController: homeProvider.firstNameController,
                        isFormValid: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        label: "First Name"),
                    height(height: 10),
                    AppTextFormField(
                        prefixIcon: Icons.account_circle_outlined,
                        textEditingController: homeProvider.lastNameController,
                        isFormValid: false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your last name';
                          }
                          return null;
                        },
                        label: "Last Name"),
                    height(height: 10),
                    AppTextFormField(
                        prefixIcon: Icons.email_outlined,
                        textEditingController: homeProvider.emailController,
                        isFormValid: true,
                        readOnly: !homeProvider.isEdit ? false : true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        label: "Email"),
                    if (!homeProvider.isEdit) height(height: 10),
                    if (!homeProvider.isEdit)
                      AppTextFormField(
                          prefixIcon: Icons.password,
                          textEditingController:
                              homeProvider.passwordController,
                          isFormValid: false,
                          onTap: (){},
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                          maxLength: true,
                          obscureText: true,
                          label: "Password"),
                    height(height: 10),
                    AppTextFormField(
                        prefixIcon: Icons.phone_iphone,
                        keyboardType: TextInputType.number,
                        maxLength: true,
                        onTap: (){},
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          } else if (value.length > 10) {
                            return 'phone number must be 10 digits';
                          }else if (value.length < 10) {
                            return 'phone number must be 10 digits';
                          }
                          return null;
                        },
                        textEditingController:
                            homeProvider.phoneNumberController,
                        isFormValid: false,
                        label: "Phone Number "),
                    height(height: 10),
                    homeProvider.addUserLoading
                        ? const AppLoadingScreen()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pop(
                                        context); // Close Bottom Sheet
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.appButtonColor),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Center(
                                      child: Text(
                                        'Cancel',
                                        style: fontStyle(
                                            color: AppColors.appButtonColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              width(width: 30),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    if (_formKey.currentState!.validate()) {
                                      if (homeProvider.isEdit) {
                                        homeProvider.editUser(
                                            context,); // Close Bottom Sheet
                                      } else {
                                        homeProvider.addUser(
                                            context); // Close Bottom Sheet
                                      }
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    decoration: BoxDecoration(
                                        color: AppColors.appButtonColor,
                                        border: Border.all(
                                            color: AppColors.appButtonColor),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5))),
                                    child: Center(
                                      child: Text(
                                        widget.screenType == "edit"
                                            ? "Update"
                                            : 'Save',
                                        style: fontStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
