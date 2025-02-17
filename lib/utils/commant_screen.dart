import 'package:chotanews/screens/home_screen/home_bloc.dart';
import 'package:chotanews/screens/testing_screen/provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_loading_screen.dart';
import 'package:chotanews/utils/app_no_data.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../globel_keys/app_router.dart';
import '../screens/Auth_module/auth_provider.dart';
import '../screens/home_screen/home_event.dart';
import 'app_enums.dart';
import 'date_format.dart';


void showComments(BuildContext context, String postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows BottomSheet to resize with keyboard
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // Push above keyboard
        ),
        child: CommentSection(postId: postId),
      );
    },
  );
}

// void showComments(BuildContext context, String postId) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     builder: (context) {
//       return SizedBox(
//         height: 500,
//         child: CommentSection(
//             postId: postId, ),
//       );
//
//       // CommentSection(postId:postId);
//     },
//   );
// }

class CommentSection extends StatelessWidget {
  final String postId;
  const CommentSection({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();
    context.read<FlipProvider>().getAllPostById(postId);

    return Consumer<FlipProvider>(
      builder: (_, flipProvider, __) {
        return FractionallySizedBox(
          heightFactor: 0.9, // Ensures it doesn't take full screen
          child: Container(
            padding: const EdgeInsets.only(top: 12.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                // Drag Handle
                Container(
                  width: 100,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                height(height: 10),
                // Comments Header
                Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: Row(
                    children: [
                      Text(
                        "Comments",
                        style: fontStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 16.0),
                          child: Icon(
                            Icons.cancel_outlined,
                            size: 24,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                height(height: 16),

                // Comment List with Keyboard Scroll Fix
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: flipProvider.isSendComment?const AppLoadingScreen():flipProvider.allPostCommentModelList.isEmpty
                        ? Center(
                      child: Text(
                        "No Comments Yet...",
                        style: fontStyle(
                          fontSize: 14,
                          color: const Color(0xff111928),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // Prevents nested scroll
                      itemCount: flipProvider.allPostCommentModelList.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0,vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Avatar
                              CircleAvatar(
                                child: Text(
                                  flipProvider.allPostCommentModelList[index].user.name
                                      .toString()
                                      .split("")
                                      .first,
                                  style: fontStyle(fontSize: 16,fontWeight: FontWeight.normal),
                                ),
                              ),
                              width(width: 10),
                              // Comment Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          flipProvider.allPostCommentModelList[index].user.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: fontStyle(
                                            fontWeight: FontWeight.normal,
                                            fontSize: 14,
                                          ),
                                        ),
                                        width(width: 4),
                                        Center(
                                          child: Text("•",
                                            textAlign: TextAlign.center,

                                            style: fontStyle(
                                              color: Colors.black,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),

                                        width(width: 4),
                                        Center(
                                          child: Text(
                                            formatTimeDifference(
                                              flipProvider.allPostCommentModelList[index].createdAt.toString(),
                                              isComment: true,
                                            ),
                                            textAlign: TextAlign.center,
                                            style: fontStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    height(height: 8),
                                    ExpandableTextWidget(
                                      text: flipProvider.allPostCommentModelList[index].text,
                                    ),
                                    height(height: 8),
                                    const Row(
                                      children: [
                                        Icon(Icons.thumb_up_alt_outlined, size: 20, color: Colors.grey),
                                        SizedBox(width: 10),
                                        Icon(Icons.thumb_down_alt_outlined, size: 20, color: Colors.grey),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Comment Input Field
                Padding(
                  padding: const EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom:  10, // Moves above keyboard
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: () {
                          if (context.read<AuthProvider>().loginType == LoginStatus.login) {
                            flipProvider.addCommentPostById(postId, controller.text).then(
                                  (value) => controller.text = '',
                            );
                          } else {
                            Navigator.pushNamed(context, RoutesManager.signInScreen);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// class CommentSection extends StatelessWidget {
//   final String postId;
//
//   const CommentSection(
//       {super.key, required this.postId,});
//
//   @override
//   Widget build(BuildContext context) {
//     TextEditingController controller = TextEditingController();
//     context.read<FlipProvider>().getAllPostById(postId);
//     return Consumer<FlipProvider>(
//       builder: (_, flipProvider, __) {
//         return Container(
//           padding: const EdgeInsets.only(top: 12.0),
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//           ),
//           child: Column(
//             children: [
//               Container(
//                 width: 100,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.only(left: 30),
//                 width: MediaQuery.of(context).size.width,
//                 alignment: Alignment.centerLeft,
//                 child: Row(
//                   children: [
//                     Text("Comments",
//                         style:
//                             fontStyle(fontWeight: FontWeight.w800, fontSize: 18)),
//                     const Spacer(),
//                     InkWell(
//                       onTap: () {
//                         Navigator.pop(context);
//                       },
//                       child: const Padding(
//                         padding: EdgeInsets.only(right: 16.0),
//                         child: Icon(
//                           Icons.cancel_outlined,
//                           size: 24,
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Expanded(
//                 child: flipProvider.allPostCommentModelList.isEmpty
//                     ?  Center(
//                   child: Text(
//                     "No Comments Yet...",style: fontStyle(
//                       fontSize: 14,color: const Color(0xff111928), fontWeight: FontWeight.bold),),
//                 )
//                     : ListView.builder(
//
//                         itemBuilder: (context, index) {
//                           return ListView(
//                             shrinkWrap: true,
//                             children: [
//                               Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 12.0),
//                                   child: Row(
//                                     children: [
//                                       CircleAvatar(
//                                           child: Text(flipProvider
//                                               .allPostCommentModelList[index]
//                                               .user
//                                               .name
//                                               .toString()
//                                               .split("")
//                                               .first)),
//                                       width(width: 10),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               mainAxisAlignment: MainAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   flipProvider
//                                                           .allPostCommentModelList[
//                                                               index]
//                                                           .user
//                                                           .name ??
//                                                       "User8376",
//                                                   overflow:
//                                                       TextOverflow.ellipsis,
//                                                   style: fontStyle(
//                                                       fontWeight:
//                                                           FontWeight.normal,
//                                                       fontSize: 14),
//                                                 ),
//                                                 width(width: 8),
//
//                                                 Text(
//                                                   formatTimeDifference(
//                                                       flipProvider
//                                                           .allPostCommentModelList[
//                                                               index]
//                                                           .createdAt
//                                                           .toString(),
//                                                       isComment: true),
//                                                   style: fontStyle(
//                                                     color: Colors.black,
//                                                     fontSize: 10,
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                             height(height: 8),
//                                             ExpandableTextWidget(text: flipProvider
//                                                 .allPostCommentModelList[
//                                             index]
//                                                 .text),
//                                             height(height: 8),
//                                             const Row(
//                                               children: [
//                                                 Icon(
//                                                     Icons.thumb_up_alt_outlined,
//                                                     size: 20,
//                                                     color: Colors.grey),
//                                                 SizedBox(width: 10),
//                                                 Icon(
//                                                     Icons
//                                                         .thumb_down_alt_outlined,
//                                                     size: 20,
//                                                     color: Colors.grey),
//                                               ],
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   )),
//                             ],
//                           );
//                         },
//
//                         itemCount: flipProvider.allPostCommentModelList.length),
//               ),
//               Padding(
//                 padding: EdgeInsets.only(
//                   left: 12,
//                   right: 12,
//                   bottom: MediaQuery.of(context).viewInsets.bottom +
//                       10, // Moves above keyboard
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: controller,
//                         decoration: InputDecoration(
//                           hintText: 'Add a comment...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(30),
//                           ),
//                           contentPadding:
//                               const EdgeInsets.symmetric(horizontal: 20),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.send, color: Colors.blue),
//                       onPressed: () {
//                         if (context.read<AuthProvider>().loginType ==
//                             LoginStatus.login) {
//                           flipProvider
//                               .addCommentPostById(postId, controller.text)
//                               .then(
//                                 (value) => controller.text = '',
//                               );
//                         } else {
//                           Navigator.pushNamed(
//                               context, RoutesManager.signInScreen);
//                         }
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
class ExpandableTextWidget extends StatefulWidget {
  final String text;
  const ExpandableTextWidget({super.key, required this.text});

  @override
  _ExpandableTextWidgetState createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style:  fontStyle(
            color: Colors.black,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: isExpanded ? null : 4,  // Initially collapsed
          overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Text(
            isExpanded ? "Show Less" : "Read More",
            style: fontStyle(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}

