import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/settings_view/setting_provider.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_loading_screen.dart';
import '../../utils/app_no_data.dart';
import '../../utils/app_popups/delete_popup.dart';
import '../../utils/app_spaces.dart';
import '../dashboard_view/models/engage_tweet_model.dart';
import '../home_screen/home_provider.dart';
import 'add_user_screen.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  int? currentSwipedIndex;

  void onSwiped(int index) {
    setState(() {
      currentSwipedIndex = index;
    });
  }

  void resetSwipedIndex() {
    setState(() {
      currentSwipedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Consumer2<HomeProvider, SettingProvider>(
          builder: (_, homeProvider, settingProvider, __) {
            return RefreshIndicator(

              color: AppColors.appButtonColor,
              backgroundColor: Colors.white,
              onRefresh: () async {
                settingProvider.getSettingsUser(isCall: true);
              },
              child: homeProvider.isEngageTweetsLoading
                  ? const AppLoadingScreen()
                  : Column(
                children: [
                  height(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white, // Background color for the search bar
                              border: Border.all(
                                color: Colors.grey.shade300, // Soft border color
                                width: 1, // Thin border
                              ),
                              borderRadius: BorderRadius.circular(5), // Smooth rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2), // Subtle shadow for depth
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 3), // Shadow position
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: Icon(
                                    Icons.search,
                                    color: AppColors
                                        .bodyTextColor, // Soft icon color
                                  ),
                                ),
                                width(width: 10),
                                Expanded(
                                  child: TextField(
                                    textAlign: TextAlign.start,
                                    controller: settingProvider.searchController,
                                    decoration: InputDecoration(


                                      hintText: "Search...",
                                      contentPadding: const EdgeInsets.symmetric(
                                          vertical: 0),

                                      hintStyle: fontStyle(
                                          fontSize: 14,
                                          color: AppColors
                                              .bodyTextColor // Subtle hint text color
                                      ),
                                      border: InputBorder
                                          .none, // Removes the border
                                    ),
                                    style: fontStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: AppColors.headerTextColor
                                    ),

                                    onChanged: (value) {
                                      settingProvider.searchUser(value.trim(), context);
                                    },
                                  ),
                                ),
                                width(width: 10),
                                if(settingProvider.searchController.text.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    settingProvider.searchController.clear();
                                    FocusScope.of(context).unfocus();
                                    settingProvider.searchUser("", context);
                                  },
                                  icon: const Icon(
                                    Icons.cancel_outlined,
                                    size: 20,
                                    color: AppColors.bodyTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        width(width: 10),
                        // widget.item.role == "super_admin" ?SizedBox.shrink():

                        InkWell(
                          onTap: () {
                            context.read<SettingProvider>().isEdit = false;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddUserScreen(
                                    screenType: "add",
                                  ),
                                ));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            height: 48,
                            width: 60,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5)),
                                color: AppColors.appButtonColor),

                            child: Text(
                              "Add",
                              style: fontStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const Divider(
                    color: AppColors.borderColor,
                  ),
                  Expanded(
                    child: settingProvider.filteredList.isEmpty
                        ? const AppNoData()
                        : ListView.separated(
                      separatorBuilder: (context, index) =>
                      const Divider(
                        height: 1,
                        color: AppColors.borderColor,
                      ),
                      itemCount: settingProvider.filteredList.length,
                      itemBuilder: (context, index) {
                        var item = settingProvider.filteredList[index];
                        return SwipeableTile(
                          key: Key(item.id.toString()),
                          item: item,
                          onDelete: () {
                            resetSwipedIndex();
                            showDeleteConfirmation(
                                context, index, item, "user");
                          },
                          onEdit: () {
                            resetSwipedIndex();
                            context.read<SettingProvider>().editUserDate(
                                item.id,
                                item.firstName,
                                item.lastName,
                                item.email,
                                item.phoneNumber,
                                context);
                          },
                          index: index,
                          currentSwipedIndex: currentSwipedIndex,
                          onSwiped: onSwiped,
                          resetSwipedIndex: resetSwipedIndex,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
}

class SwipeableTile extends StatefulWidget {
  final UsersModel item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final int index;
  final int? currentSwipedIndex;
  final ValueChanged<int> onSwiped;
  final VoidCallback resetSwipedIndex;

  const SwipeableTile({
    required this.item,
    required this.onDelete,
    required this.onEdit,
    required this.index,
    required this.currentSwipedIndex,
    required this.onSwiped,
    required this.resetSwipedIndex,
    super.key,
  });

  @override
  _SwipeableTileState createState() => _SwipeableTileState();
}

class _SwipeableTileState extends State<SwipeableTile> {
  double offset = 0.0;
   ValueNotifier<bool>? controller ;

  @override
  void didUpdateWidget(SwipeableTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentSwipedIndex != widget.index && offset != 0) {
      offset = 0;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    controller = ValueNotifier<bool>(widget.item.status != "1" ? false : true);
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (widget.item.role == "super_admin") return;
        offset += details.delta.dx;
        if (offset > 0) offset = 0;
        if (offset < -160) offset = -160;

        setState(() {});
      },
      onHorizontalDragEnd: (details) {
        if (offset < -50) {
          widget.onSwiped(widget.index);
        } else {
          offset = 0;
          widget.resetSwipedIndex();
        }
        setState(() {});
      },
      child: Stack(
        children: [
          if (offset < 0)
            Positioned.fill(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        color: AppColors.appButtonColor,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: TextButton(
                      onPressed: widget.onEdit,
                      child: Text(
                        "Edit",
                        maxLines: 2,
                        style: fontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.wColor),
                      ),
                    ),
                  ),
                  width(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(8))),
                    alignment: Alignment.centerRight,
                    // padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextButton(
                      onPressed: widget.onDelete,
                      child: Text(
                        "Delete",
                        maxLines: 2,
                        style: fontStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.wColor),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Transform.translate(
            offset: Offset(offset, 0),
            child: Container(
              color: Colors.white,
              child: ListTile(
                title: Text(
                  "${widget.item.firstName} ${widget.item.lastName}",
                  style: fontStyle(
                      fontSize: 14,
                      color: const Color(0xff111928),
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  widget.item.email ?? "",
                  style: fontStyle(
                      fontSize: 14,
                      color: const Color(0xff6b7280),
                      fontWeight: FontWeight.normal),
                ),
                leading: InkWell(
                  onTap: () {

                  },
                  child: widget.item.profilePic == null
                      ? Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(40)),
                    ),
                    child: Center(
                      child: Text(
                        widget.item.name
                            .toString()
                            .split('')
                            .first
                            .toString()
                            .toUpperCase(),
                        style: fontStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )
                      : Container(
                    height: 40,
                    width: 40,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.circular(40)),

                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                          widget.item.profilePic.toString()),
                    ),
                  ),
                ),
               trailing:
               widget.item.role == "super_admin" ?SizedBox.shrink():

               SizedBox(
                 height:25,
                 width: 40,
                 child:
                 FlutterSwitch(
                   value: widget.item.status == "1"?true:false,
                   inactiveColor: AppColors.borderColor,
                   activeColor: AppColors.appButtonColor,
                   // activeIcon: Icon(Icons.circle),
                   width: 40.0,
                   height: 20.0,
                   valueFontSize: 10.0,
                   toggleSize: 12.0,
                   onToggle: (value) {
                     if (widget.item.role == "super_admin") return;
                     showUserActiveConfirmation(
                         context,
                         widget.item,
                         widget.item.status != "1" ? "Active" : "Inactive",
                         "user");
                   },
                 ),

               ),

              ),
            ),
          ),
        ],
      ),
    );
  }
  bool status = false;

}
