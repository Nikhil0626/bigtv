import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.access_time_filled,color: Colors.lightBlue,size: 18,),
        title: Text("Flutter",style: TextStyle(color: Colors.grey,fontWeight: FontWeight.w500,fontSize: 18),),
        centerTitle: true,
        actions: [
          Icon(Icons.ac_unit,color: Colors.lightGreen,)
        ],
      ),

    );
  }
}
