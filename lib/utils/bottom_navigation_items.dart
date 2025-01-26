import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';

class BottomNavigationItems extends StatelessWidget {
  const BottomNavigationItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.symmetric(horizontal: 18,),
      child: const Row(
        children: [
          RowItem(text: "Home", icon: Icons.home),
          RowItem(text: "Location", icon: Icons.location_on_sharp),
          RowItem(text: "Menu", icon: Icons.menu),
        ],
      ),
    );
  }
}

class RowItem extends StatelessWidget {
  final  icon;
  final String text;
  const RowItem({super.key,required this.text,required this.icon});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon,size: 24),
        Text(text,style: fontStyle(),)
      ],
    );
  }
}
