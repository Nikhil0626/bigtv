import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:flutter/material.dart';

class BottomNavigationItems extends StatelessWidget {
  const BottomNavigationItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(
          color: AppColors.borderColor,
        ),
        Container(
          color: Colors.white,
          height: 50,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 18,),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RowItem(text: "Home", icon: Icons.home),
              RowItem(text: "Location", icon: Icons.location_on_sharp),
              RowItem(text: "Menu", icon: Icons.menu),
            ],
          ),
        ),
      ],
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
