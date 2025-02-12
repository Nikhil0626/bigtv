import 'package:chotanews/screens/home_screen/home_bloc.dart';
import 'package:chotanews/screens/home_screen/home_state.dart';
import 'package:chotanews/screens/testing_screen/provider.dart';
import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screens/home_screen/home_event.dart';

class BottomNavigationItems extends StatelessWidget {
  const BottomNavigationItems({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeScreenState>(
        listener: (context, state) {
        },
        builder: (context, state) {
          return Container(
            color: Colors.white,
            height: 75,
            width: MediaQuery
                .of(context)
                .size
                .width,
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
                      text: "హోమ్",
                      icon: Icons.home,
                      onTap: () {
                        context.read<HomeBloc>().add(MenuItemClickEvent(
                            context: context, currentMenuItem: "హోమ్"));
                      },
                    ),
                    RowItem(
                      text: "లొకేషన్స్",
                      icon: Icons.location_on_sharp,
                      onTap: () {
                        context.read<HomeBloc>().add(MenuItemClickEvent(
                            context: context, currentMenuItem: "లొకేషన్స్"));
                      },
                    ),
                    RowItem(
                      text: "మెను",
                      icon: Icons.menu,
                      onTap: () {
                        context.read<HomeBloc>().add(MenuItemClickEvent(
                            context: context, currentMenuItem: "మెను"));
                      },
                    ),
                  ],
                ),
                height(height: 6),
              ],
            ),
          );
        }
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
          Icon(icon, size: 24,color: text == "హోమ్"?Colors.blue:Colors.black,),
          height(height: 4),
          Text(
            text,
            style: fontStyle(color: text == "హోమ్"?Colors.blue:Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: 14),
          ),
        ],
      ),
    );
  }
}

