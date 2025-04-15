import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_fonts.dart';
import 'date_format.dart';

class DateAndSource extends StatelessWidget {
 final data;
  const DateAndSource({super.key,required this.data});

  @override
  Widget build(BuildContext context) {
    return  RichText(
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (data['isReporter'] == 1) Icon(Icons.person, size: 14, color: Colors.grey),
                if (data['isReporter']  == 1)
                  Text(
                    ' ${data['reportedBy'] } | ',
                    style: fontStyle(fontSize:  12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                  ),
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                Text(
                  " ${formatTimeDifference(data['created'])}",
                  style: fontStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
