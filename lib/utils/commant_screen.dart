import 'package:chotanews/screens/home_screen/home_bloc.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/home_screen/home_event.dart';

void showComments(BuildContext context, String postId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return CommentSection(postId:postId);
    },
  );
}



class CommentSection extends StatelessWidget {
  final String postId;
  const CommentSection({super.key,required this.postId});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * 0.5,
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
          height(height: 10),
          Container(
            padding: const EdgeInsets.only(left: 30),
              width: MediaQuery.of(context).size.width,
              alignment: Alignment.centerLeft,
              child: Text("Comments",style: fontStyle(fontWeight: FontWeight.w800,fontSize: 18),)),
          height(height: 10),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children:  [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(child: Text('V')),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vivek Varma',
                              style: fontStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Hee',
                              style: fontStyle(color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.thumb_up_alt_outlined, size: 20,
                          color: Colors.grey),
                      SizedBox(width: 10),
                      Icon(Icons.thumb_down_alt_outlined, size: 20,
                          color: Colors.grey),
                    ],
                  ),
                ),
                Divider(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20),
                    ),
                  ),
                ),
                width(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    context.read<HomeBloc>().add(CommentByPost(postData: controller.text,postId: postId));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }}