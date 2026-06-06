import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_spaces.dart';
import '../settings_screen/settings_view/feedback_view.dart';

class RateYourApp extends StatelessWidget {
  const RateYourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Card(
        color: AppColors.adsBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Rate your experience\nwith chota news?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              height(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) =>  Icon(
                    Icons.star,
                    color: AppColors.ratingColor,
                    size: 40,
                  ),
                ),
              ),
              height(height: 4),
              const Text(
                'Awesome, liked it',
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
              height(height: 6),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  FeedbackForm()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
