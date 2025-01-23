import 'package:chotanews/screens/language_selection_screen/language_selection_view.dart';
import 'package:flutter/material.dart';

import '../state_selection_screen/state_selection_view.dart';

class CategorySelectionView extends StatefulWidget {
  const CategorySelectionView({super.key});

  @override
  State<CategorySelectionView> createState() => _CategorySelectionView();
}

class _CategorySelectionView extends State<CategorySelectionView> {
  Widget categoryOption(String text) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        margin: EdgeInsets.symmetric(vertical: 5),
        height: 80,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.lightBlue, width: 2.0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.lightBlue,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Chota",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "News",
                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Colors.lightBlue,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            const Text(
              "Let's personalize",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Your experience",
              style: TextStyle(
                color: Colors.black,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: "Step 2 of 3: ",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: "Choose your Category",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Stack(
              children: [
                Container(
                  height: 8,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.lightBlue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    categoryOption("World's"),
                    SizedBox(width: 10),
                    categoryOption("Sports"),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    categoryOption("Political"),
                    SizedBox(width: 10),
                    categoryOption("Entertainment"),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    categoryOption("Technology"),
                    SizedBox(width: 10),
                    categoryOption("Health"),
                  ],
                ),
                SizedBox(height: 25),
                Row(
                  children: [
                    categoryOption("Astrology"),
                    SizedBox(width: 10),
                    categoryOption("Business"),
                  ],
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Container(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigation to LanguageSelectionView
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LanguageSelectionView(),
                        ),
                            (route) => false, // Removes all previous routes
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(
                          color: Colors.lightBlue,
                          width: 2.0,
                        ),
                      ),
                    ),
                    child: const Text(
                      "Back", // Button text to navigate back to languages selection
                      style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigation to StateSelectionView
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StateSelectionView(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Next",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
