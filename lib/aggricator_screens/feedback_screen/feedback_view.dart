import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, 
            icon: Icon(Icons.arrow_back_rounded,color: Colors.black,size: 24,)),
        centerTitle: false,
        title: Text("Feedback Form",style: newAppFont(color: Colors.black,fontSize: 10,fontWeight: FontWeight.w700),),
      ),
    );
  }
}
