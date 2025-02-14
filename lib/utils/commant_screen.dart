import 'package:chotanews/screens/home_screen/home_bloc.dart';
import 'package:chotanews/screens/testing_screen/provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../screens/home_screen/home_event.dart';
import 'date_format.dart';

void showComments(BuildContext context, String postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scrollController) {
          return CommentSection(
              postId: postId, scrollController: scrollController);
        },
      );

      // CommentSection(postId:postId);
    },
  );
}

class CommentSection extends StatelessWidget {
  final String postId;
  final ScrollController scrollController; // Accept ScrollController

  const CommentSection(
      {super.key, required this.postId, required this.scrollController});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Consumer<FlipProvider>(
      builder: (_, flipProvider, __) {
        return Container(
          padding: const EdgeInsets.only(top: 12.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.only(left: 30),
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.centerLeft,
                child: Text("Comments",
                    style:
                        fontStyle(fontWeight: FontWeight.w800, fontSize: 18)),
              ),
              const SizedBox(height: 16),
              Expanded(
                  child: ListView.separated(
                      itemBuilder: (context, index) {
                        return ListView(
                          controller:
                              scrollController, // Use the scroll controller
                          shrinkWrap: true,
                          children: [
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Row(
                                  children: [
                                     CircleAvatar(child: Text(flipProvider
                                        .allPostCommentModelList[
                                    index]
                                        .user.name.toString().split("").first)),
                                    width(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            flipProvider
                                                    .allPostCommentModelList[
                                                        index]
                                                    .user
                                                    .name ??
                                                "User8376",
                                            overflow: TextOverflow.ellipsis,
                                            style: fontStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12),
                                          ),
                                          height(height: 8),
                                          Text(
                                            flipProvider
                                                    .allPostCommentModelList[
                                                        index]
                                                    .text ??
                                                "Hai",
                                            overflow: TextOverflow.ellipsis,
                                            style: fontStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                            ),

                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "${formatTimeDifference(flipProvider.allPostCommentModelList[index].createdAt.toString(),isComment: true)}",
                                          style: fontStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        height(height: 8),
                                        const Row(
                                          children: [
                                            Icon(Icons.thumb_up_alt_outlined,
                                                size: 20, color: Colors.grey),
                                            SizedBox(width: 10),
                                            Icon(Icons.thumb_down_alt_outlined,
                                                size: 20, color: Colors.grey),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                )),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: AppColors.borderColor,
                        );
                      },
                      itemCount: flipProvider.allPostCommentModelList.length)),
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      10, // Moves above keyboard
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
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: () {
                        flipProvider
                            .addCommentPostById(postId, controller.text)
                            .then(
                              (value) => controller.text = '',
                            );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// class CommentSection extends StatelessWidget {
//   final String postId;
//   const CommentSection({super.key,required this.postId});
//
//   @override
//   Widget build(BuildContext context) {
//     TextEditingController controller = TextEditingController();
//
//     return Consumer<FlipProvider>(
//       builder: (_,flipProvider,__) {
//         return Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom, // Adjusts for keyboard
//           ),
//           child: Container(
//             height: MediaQuery
//                 .of(context)
//                 .size
//                 .height * 0.5,
//             padding: const EdgeInsets.only(top: 12.0),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 50,
//                   height: 5,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 height(height: 10),
//                 Container(
//                   padding: const EdgeInsets.only(left: 30),
//                     width: MediaQuery.of(context).size.width,
//                     alignment: Alignment.centerLeft,
//                     child: Text("Comments",style: fontStyle(fontWeight: FontWeight.w800,fontSize: 18),)),
//                 height(height: 10),
//                 Expanded(
//                   child: ListView(
//                     shrinkWrap: true,
//                     children:  [
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Row(
//                           children: [
//                             const CircleAvatar(child: Text('V')),
//                             const SizedBox(width: 10),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Vivek Varma',
//                                     style: fontStyle(fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(
//                                     'Hee',
//                                     style: fontStyle(color: Colors.black87),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const Icon(Icons.thumb_up_alt_outlined, size: 20,
//                                 color: Colors.grey),
//                             const SizedBox(width: 10),
//                             const Icon(Icons.thumb_down_alt_outlined, size: 20,
//                                 color: Colors.grey),
//                           ],
//                         ),
//                       ),
//                       const Divider(),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: controller,
//                           decoration: InputDecoration(
//                             hintText: 'Add a comment...',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 20),
//                           ),
//                         ),
//                       ),
//                       width(width: 8),
//                       IconButton(
//                         icon: const Icon(Icons.send, color: Colors.blue),
//                         onPressed: () {
//                           flipProvider.addCommentPostById(postId.toString(),controller.text);
//                           // context.read<HomeBloc>().add(CommentByPost(postData: controller.text,postId: postId));
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }
//     );
//   }}
