import 'package:click_to_copy/click_to_copy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ClipboardToTextDemo extends StatefulWidget {
  const ClipboardToTextDemo({super.key});

  @override
  _ClipboardToTextDemoState createState() => _ClipboardToTextDemoState();
}

class _ClipboardToTextDemoState extends State<ClipboardToTextDemo> {
  String _pastedText = 'No content pasted yet';

  Future<void> _pasteText() async {
    await ClickToCopy.paste().then((value) {
      if (value.isNotEmpty) {
        _pastedText = value.toString();
        setState(() {

        });
      }
    });
    // ClipboardData? data = await Clipboard.getData('text/plain');
    // if (data != null && data.text != null) {
    //   setState(() {
    //     _pastedText = data.text!;
    //   });
    // }
  }

  @override
  void initState() {
    super.initState();
    // Auto-paste when widget initializes
    _pasteText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clipboard to Text')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Text widget displaying clipboard content
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _pastedText,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pasteText,
              child: Text('Refresh Clipboard Content'),
            ),
          ],
        ),
      ),
    );
  }
}