
import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';


// class BottomNavigationItems extends StatelessWidget {
//   const BottomNavigationItems({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Colors.white,
//       height: 70,
//       width: MediaQuery
//           .of(context)
//           .size
//           .width,
//       child: Column(
//         mainAxisAlignment:
//         MainAxisAlignment.spaceAround,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             color: AppColors.borderColor,
//             height: 1,
//           ),
//           height(height: 4),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               RowItem(
//                 text: "హోమ్",
//                 icon: Icons.home,
//                 onTap: () {
//                   context.read<FlipProvider>().menuChange("హోమ్",context);
//                 },
//               ),
//               RowItem(
//                 text: "లొకేషన్స్",
//                 icon: Icons.location_on_sharp,
//                 onTap: () {
//                   context.read<FlipProvider>().menuChange("లొకేషన్స్",context);
//                 },
//               ),
//               RowItem(
//                 text: "మెను",
//                 icon: Icons.menu,
//                 onTap: () {
//                   context.read<FlipProvider>().menuChange("మెను",context);
//                 },
//               ),
//             ],
//           ),
//           height(height: 6),
//         ],
//       ),
//     );
//   }
// }

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
          Icon(icon, size: 24,color: text == "హోమ్"?Colors.blue:Colors.grey,),
          height(height: 2),
          Text(
            text,
            style: fontStyle(color: text == "హోమ్"?Colors.blue:Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 14),
          ),
        ],
      ),
    );
  }
}

