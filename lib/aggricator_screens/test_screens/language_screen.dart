import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('hello'.tr())), // Translated "Hello"
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('welcome'.tr(), style: TextStyle(fontSize: 20)), // Translated "Welcome"
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Locale currentLocale = context.locale;

                if (currentLocale.languageCode == 'en') {
                  context.setLocale(Locale('te')); // Switch to Telugu
                } else if (currentLocale.languageCode == 'te') {
                  context.setLocale(Locale('hi')); // Switch to Hindi
                } else {
                  context.setLocale(Locale('en')); // Switch to English
                }
              },
              child: Text(
                context.locale.languageCode == 'en'
                    ? 'Switch to Telugu'
                    : context.locale.languageCode == 'te'
                    ? 'Switch to Hindi'
                    : 'Switch to English',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
