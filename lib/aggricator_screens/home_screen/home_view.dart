import 'package:chotanews/aggricator_screens/home_screen/home_provider.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'main_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  final List<Widget> pages = [
    MainScreen(), // Using the HomeView widget
    Center(child: Text('Search Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Reels Page', style: TextStyle(fontSize: 24))),
  ];


  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (_,homeProvider,__) {
        return Scaffold(
          body: pages[homeProvider.selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: homeProvider.selectedIndex,
            onTap: homeProvider.onItemTapped,
            selectedItemColor: Colors.blue, // Highlight color
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold), // Emphasized label
            items: [
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    if (homeProvider.selectedIndex == 0)
                      Container(
                        width: 50,
                        height: 3,
                        color: Colors.blue, // Small bar under icon
                      ),
                    height(height: 2),
                    Icon(Icons.home),

                  ],
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    if (homeProvider.selectedIndex == 1)
                      Container(
                        width: 50,
                        height: 3,
                        color: Colors.blue,
                      ),
                    height(height: 2),
                    Icon(Icons.search),

                  ],
                ),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    if (homeProvider.selectedIndex == 2)
                      Container(
                        width: 50,
                        height: 3,
                        color: Colors.blue,
                      ),
                    height(height: 2),
                    Icon(Icons.book),

                  ],
                ),
                label: 'Reels',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    if (homeProvider.selectedIndex == 3)
                      Container(
                        width: 50,
                        height: 3,
                        color: Colors.blue,
                      ),
                    height(height: 2),
                    Icon(Icons.person),

                  ],
                ),
                label: 'Profile',
              ),

            ],
          ),


        );
      }
    );
  }
}

