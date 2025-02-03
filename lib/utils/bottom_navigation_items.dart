import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';

import '../screens/districts_selection/districts_selection_screen.dart';
import '../screens/videos_main/tab_screen.dart';

class BottomNavigationItems extends StatelessWidget {
  const BottomNavigationItems({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 75,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          const Divider(
            color: AppColors.borderColor,
          ),
          height(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RowItem(
                text: "Home",
                icon: Icons.home,
                onTap: () {
                },
              ),
              RowItem(
                text: "Location",
                icon: Icons.location_on_sharp,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DistrictsSelectionScreen()),
                  );
                },
              ),
              RowItem(
                text: "Menu",
                icon: Icons.menu,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TabScreen ()),
                  );
                },
              ),
            ],
          ),
          height(height: 6),
        ],
      ),
    );
  }
}

class RowItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const RowItem({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 24),
          Text(
            text,
            style: fontStyle(color: Colors.black,fontWeight: FontWeight.normal,fontSize: 14),
          ),
        ],
      ),
    );
  }
}

