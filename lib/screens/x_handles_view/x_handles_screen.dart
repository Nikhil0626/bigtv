import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:tweetai/screens/x_handles_view/x_handle_provider.dart';
import 'package:tweetai/screens/x_handles_view/x_handles_model.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_fonts.dart';
import '../../utils/app_no_data.dart';
import '../../utils/app_popups/delete_popup.dart';
import '../../utils/app_spaces.dart';
import '../home_screen/home_provider.dart';

class XHandlesScreen extends StatefulWidget {
  const XHandlesScreen({super.key});

  @override
  State<XHandlesScreen> createState() => _XHandlesScreenState();
}

class _XHandlesScreenState extends State<XHandlesScreen> {
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

      body: Consumer<XHandleProvider>(builder: (_, xHandleProvider, __) {
        return RefreshIndicator(
          color: AppColors.appButtonColor,
          backgroundColor: Colors.white,
          onRefresh: () => xHandleProvider.getTwitterHandles(),
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
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
                                color:AppColors.bodyTextColor, // Soft icon color
                              ),
                            ),
                            width(width: 10),
                            Expanded(
                              child: TextField(
                                textAlign: TextAlign.start,
                                controller: xHandleProvider.xHandleSearchController,
                                decoration: InputDecoration(
                                  hintText: "Search...",
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0),

                                  hintStyle: fontStyle(
                                      fontSize: 14,
                                      color: AppColors.bodyTextColor // Subtle hint text color
                                  ),
                                  border: InputBorder.none, // Removes the border
                                ),
                                style:  fontStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.normal,
                                    color:  AppColors.headerTextColor
                                ),

                                onChanged: (value) {
                                  xHandleProvider.searchXHandle(value.trim(), context);
                                },
                              ),
                            ),
                            width(width: 10),
                            if( xHandleProvider.xHandleSearchController.text.length>0)
                            IconButton(
                              onPressed: () {
                                xHandleProvider.xHandleSearchController.clear();
                                FocusScope.of(context).unfocus();
                                xHandleProvider.searchXHandle("", context);
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
                    InkWell(
                        onTap: () {
                          showEditHandleDialog(context, "", "Add");
                        },
                        child: Container(
                          alignment: Alignment.center,
                          height: 48,
                          width: 60,
                          decoration: const BoxDecoration(borderRadius:  BorderRadius.all(Radius.circular(5)),
                          color: AppColors.appButtonColor),

                          child: Text(
                            "Add",
                            style: fontStyle(
                                fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ),
                    // width(width: 10),

                  ],
                ),
              ),
              const Divider(
                color: AppColors.borderColor,
              ),
              Expanded(
                child: xHandleProvider.filterTwitterHandlesList.isEmpty
                    ? const AppNoData()
                    : ListView.separated(
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          color: AppColors.borderColor,
                        ),
                        itemCount:
                            xHandleProvider.filterTwitterHandlesList.length,
                        itemBuilder: (context, index) {
                          var item =
                              xHandleProvider.filterTwitterHandlesList[index];
                          return SwipeableTile(
                            index: index,
                            key: Key(item.id.toString()),
                            item: item,
                            onDelete: () {
                              resetSwipedIndex();
                              showDeleteConfirmation(
                                  context, index, item, "xHandles");
                            },
                            onEdit: () {
                              resetSwipedIndex();
                              showEditHandleDialog(context, item, "Edit");
                            },
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
  final XHandlesTweetsModel item;
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
    Key? key,
  }) : super(key: key);

  @override
  _SwipeableTileState createState() => _SwipeableTileState();
}

class _SwipeableTileState extends State<SwipeableTile> {
  double offset = 0.0;

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
    return GestureDetector(
        onHorizontalDragUpdate: (details) {
          offset += details.delta.dx;
          if (offset > 0) offset = 0;
          if (offset < -105) offset = -105;

          setState(() {});
        },
        onHorizontalDragEnd: (details) {
          if (offset < -50) {
            // offset = 0;
            widget.onSwiped(widget.index);
          } else {
            offset = 0;
            widget.resetSwipedIndex(); // Reset swipe if threshold not met
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
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: TextButton(
                        onPressed: widget.onEdit,
                        child: Text(
                          "Edit",
                          maxLines: 2,
                          style: fontStyle(
                              fontSize: 16,
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
                      // padding: const EdgeInsets.symmetric(horizontal: 7),
                      child: TextButton(
                        onPressed: widget.onDelete,
                        child: Text(
                          "Delete",
                          maxLines: 2,
                          style: fontStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.wColor),
                        ),
                      ),
                    ),
                    width(width: 10),
                  ],
                ),
              ),
            Transform.translate(
              offset: Offset(offset, 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.translationValues(offset, 0, 0),
                color: Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 70,
                        alignment: Alignment.topLeft,
                        child: widget.item.profilePic == null
                            ? Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.item.username
                                        .toString()
                                        .split('')
                                        .first
                                        .toString()
                                        .toUpperCase(),
                                    style: fontStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              )
                            : Container(
                                height: 40,
                                width: 40,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(40)),
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                      widget.item.profilePic.toString()),
                                ),
                              ),
                      ),
                      width(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.username.toString(),
                              style: fontStyle(
                                  fontSize: 14,
                                  color: AppColors.headerTextColor,
                                  fontWeight: FontWeight.bold),
                            ),
                            if (widget.item.profileName != null)
                              height(height: 2.0),
                            if (widget.item.profileName != null)
                              Text(
                                "@${widget.item.profileName.toString()}",
                                style: fontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: const Color(0xff6b7280),
                                ),
                              ),
                            height(height: 2.0),
                            InkWell(
                              onTap: (){
                                context.read<HomeProvider>().launchURL(widget.item.url
                                    .toString());
                              },
                              child: Text(
                                widget.item.url.toString(),
                                style: fontStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.appButtonColor,
                                ),
                              ),
                            ),
                            height(height: 2.0),
                            RichText(
                              text: TextSpan(
                                  text: "Created On: ",
                                  style: fontStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xff6b7280),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: widget.item.createdAt.toString(),
                                      style: fontStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: const Color(0xff6b7280),
                                      ),
                                    )
                                  ]),
                            ),
                          ],
                        ),
                      ),
                      width(width: 10),

                      Align(
                        alignment: Alignment.center,
                        child:
                        FlutterSwitch(
                          value: widget.item.status == "valid"?true:false,
                          inactiveColor: AppColors.borderColor,
                          activeColor: AppColors.appButtonColor,
                          width: 40.0,
                          height: 20.0,
                          valueFontSize: 10.0,
                          toggleSize: 12.0,
                          onToggle: (value) {
                            showUserActiveConfirmation(
                                context,
                                widget.item,
                                widget.item.status != "valid"
                                    ? "Active"
                                    : "Inactive",
                                "handle");
                          },
                        ),

                      ),
                      // SizedBox(
                      //   height: 20,
                      //   child: Switch(
                      //     value: widget.item.status == "valid"?true:false, // assuming `isActive` is a boolean field in item
                      //     onChanged: (value) {
                      //       // if(value)
                      //         showUserActiveConfirmation(
                      //           context,
                      //           widget.item,
                      //           widget.item.status != "valid" ? "Active" : "Inactive",
                      //         );
                      //     },
                      //     activeColor: AppColors.appButtonColor,
                      //
                      //     // inactiveThumbColor: Colors.grey.shade200,
                      //     inactiveTrackColor: Colors.grey,
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
