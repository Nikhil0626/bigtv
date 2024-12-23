
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../screens/home_screen/home_provider.dart';
import '../../screens/settings_view/setting_provider.dart';
import '../../screens/x_handles_view/x_handle_provider.dart';
import '../app_colors.dart';
import '../app_fonts.dart';
import '../app_loading_screen.dart';
import '../app_spaces.dart';

void showDeleteConfirmation(
    BuildContext context, int index, item, String classType) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Confirm Delete',
          style: fontStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        content: Text(
            'Are you sure you want to delete "${classType == "home" || classType == "draft" || classType == "schedule" ? "Tweet" : classType == "user" ? item.firstName : item.username}"?'),
        actions: context.watch<XHandleProvider>().addXHandleLoading ||
                context.watch<HomeProvider>().isEngageTweetsLoading
            ? [const AppLoadingScreen()]
            : [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text(
                    'Cancel',
                    style: fontStyle(color: Colors.black),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (classType == "home" ||
                        classType == "draft" ||
                        classType == "schedule") {
                      context
                          .read<HomeProvider>()
                          .deleteTweet(item.id, index, context, classType);
                    } else if (classType == "user") {
                      context
                          .read<SettingProvider>()
                          .deleteUser(index, item, context);
                    } else {
                      context.read<XHandleProvider>().deleteHandle(
                          index, item, context); // Remove the item
                    }
                  },
                  child: Text('Delete', style: fontStyle(color: Colors.black)),
                ),
              ],
      );
    },
  );
}

void showUserActiveConfirmation(
    BuildContext contexts, item, String type, screenType) {
  showDialog(
    context: contexts,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          '$type',
          style: fontStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        content: Text('Are you sure you want to $type this user?'),
        actions: context.watch<XHandleProvider>().addXHandleLoading ||
                context.watch<SettingProvider>().addXHandleLoading
            ? [const AppLoadingScreen()]
            : [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Container(
                    width: 100,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.wColor,
                        border: Border.all(
                            color: AppColors.appButtonColor,
                            width: 1),
                        borderRadius: const BorderRadius.all(
                            Radius.circular(20))),
                    child: Text(
                      'Cancel',
                      style: fontStyle(color: AppColors.appButtonColor),
                    ),
                  ),
                ),
                InkWell(

                  onTap: () {
                    if (type == "Active") {
                      context
                          .read<SettingProvider>()
                          .unbBlockUser(item.id, contexts,screenType);
                    }
                    else if (screenType == "user") {
                      context
                          .read<SettingProvider>()
                          .statusChangeUser(item.id, contexts,type);
                    } else {
                      context
                          .read<XHandleProvider>()
                          .statusChangeUser(item.id, contexts,);
                    }
                  },
                  child: Container(
                    width: 100,
                      height: 35,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColors.appButtonColor,
                          border: Border.all(
                              color: AppColors.appButtonColor,
                              width: 1),
                          borderRadius: const BorderRadius.all(
                              Radius.circular(20))),
                      child: Text("Yes", style: fontStyle(color: Colors.white))),
                ),
              ],
      );
    },
  );
}

void showEditHandleDialog(BuildContext context, data, title) {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController urlController = TextEditingController();
  if (data == '') {
    urlController.text = data;
  } else {
    urlController.text = data.url;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$title Twitter Handle",
                style: fontStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.headerTextColor),
              ),
              height(height: 16),
              SizedBox(
                width: MediaQuery.of(context).size.height,
                child: TextFormField(
                  controller: urlController,
                  decoration: InputDecoration(
                    labelText: "Profile URL",
                    labelStyle: fontStyle(color: AppColors.headerTextColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: AppColors.borderColor)),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Profile URL cannot be empty.";
                    } else if (!isValidUrl(value)) {
                      return 'Invalid URL format';
                    }

                    return null;
                  },
                ),
              ),
              height(height: 24),
              context.watch<XHandleProvider>().addXHandleLoading
                  ? const AppLoadingScreen()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: AppColors.wColor,
                                  border: Border.all(
                                      color: AppColors.appButtonColor,
                                      width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Text(
                                "Cancel",
                                style: fontStyle(
                                    fontSize: 14,
                                    color: AppColors.appButtonColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        width(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                FocusScope.of(context).unfocus();
                                if (data == '') {
                                  context
                                      .read<XHandleProvider>()
                                      .addHandle(urlController.text, context);
                                } else {
                                  context.read<XHandleProvider>().editHandle(
                                      urlController.text, data.id, context);
                                }
                              }
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  color: AppColors.appButtonColor,
                                  border: Border.all(
                                      color: AppColors.appButtonColor,
                                      width: 1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(20))),
                              child: Center(
                                child: Text(
                                  title == "Add" ? "Add" : "Update",
                                  style: fontStyle(
                                      fontSize: 14,
                                      color: AppColors.wColor,
                                      fontWeight: FontWeight.bold),
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
      );
    },
  );
}

bool isValidUrl(String url) {
  final urlPattern = r'^https:\/\/x\.com\/[a-zA-Z0-9\-\.]+$';
  final regex = RegExp(urlPattern);

  return regex.hasMatch(url);
}
