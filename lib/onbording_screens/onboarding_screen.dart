import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../utils/app_fonts.dart';
import '../utils/app_spaces.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreen();
}

class _OnboardingScreen extends State<OnboardingScreen> {
  int _currentIndex = 0;

  final List<Widget> _slides = [
     Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.location_on,
          size: 190,
          color: Colors.red,
        ),
        height(height: 90),
        Text(
          "మీ జిల్లా వార్తలు",
          style: fontStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        height(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            "మీరిక్కడున్నా మీ జిల్లాలను సెట్ చేసుకోవాలి. మీ ఊరి సంగతులు మీతోనే.",
            maxLines: 3,
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.red,
          ),
          child: Center(
            child: Image.asset(
              'assets/andhra_map.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        height(height: 90),
         Text(
          "బ్రేకింగ్ న్యూస్",
          style: fontStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        height(height: 10),
         const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            "రాజకీయాలు సినిమా గాడ్జెట్లు, ఉద్యోగ నోటిఫికేషన్లు... అన్నీ ఒకే చోట వార్తలలో.",
            maxLines: 3,
            style: TextStyle(
              fontSize: 22,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                height: MediaQuery.of(context).size.height * 0.8,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              items: _slides.map((slide) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.white,
                      child: slide,
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    return Container(
                      width: 10.0,
                      height: 10.0,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? Colors.lightBlue
                            : Colors.blue.shade200,
                      ),
                    );
                  }),
                ),
               height(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _slides.length - 1) {
                      setState(() {
                        _currentIndex++;
                      });
                    } else {
                      print("Reached the last slide");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    _currentIndex == _slides.length - 1 ? "Finish" : "Next",
                    style: fontStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
