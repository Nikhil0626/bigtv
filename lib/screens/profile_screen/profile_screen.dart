// import 'package:chotanews/screens/chota_info_screens/chota_info.dart';
// import 'package:flutter/material.dart';
//
//
//
// class ProfileScreen extends StatefulWidget {
//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   final TextEditingController _fullNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _mobileController = TextEditingController();
//   String _gender = "Select Gender";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 20),
//           onPressed: () {
//             Navigator.pop(context, );
//           },
//         ),
//         title: const Text('Profile'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Full Name
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.grey),
//                 color: Colors.white,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _fullNameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Full Name',
//                         labelStyle: fontStyle(color: Colors.black54),
//                         suffixIcon: Icon(Icons.edit),
//                         border: InputBorder.none,
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.grey),
//                 color: Colors.white,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(
//                         labelText: 'Email Address',
//                         labelStyle: fontStyle(color: Colors.black54),
//                         suffixIcon: Icon(Icons.edit),
//                         border: InputBorder.none,
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Mobile Number
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.grey),
//                 color: Colors.white,
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: _mobileController,
//                       decoration: const InputDecoration(
//                         labelText: 'Mobile Number',
//                         labelStyle: fontStyle(color: Colors.black54),
//                         suffixIcon: Icon(Icons.edit),
//                         border: InputBorder.none,
//                         contentPadding:
//                             EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),
//
//             // Gender
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(color: Colors.grey),
//                 color: Colors.white,
//               ),
//               child: GestureDetector(
//                 onTap: () async {
//                   String? selectedGender = await showDialog<String>(
//                     context: context,
//                     builder: (context) => AlertDialog(
//                       title: const Text('Select Gender'),
//                       content: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           ListTile(
//                             title: const Text('Male'),
//                             onTap: () => Navigator.pop(context, 'Male'),
//                           ),
//                           ListTile(
//                             title: const Text('Female'),
//                             onTap: () => Navigator.pop(context, 'Female'),
//                           ),
//                           ListTile(
//                             title: const Text('Other'),
//                             onTap: () => Navigator.pop(context, 'Other'),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                   if (selectedGender != null) {
//                     setState(() {
//                       _gender = selectedGender;
//                     });
//                   }
//                 },
//                 child: InputDecorator(
//                   decoration: const InputDecoration(
//                     labelText: 'Gender',
//                     labelStyle: fontStyle(color: Colors.black54),
//                     suffixIcon: Icon(Icons.edit),
//                     border: InputBorder.none,
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   ),
//                   child: Text(_gender),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
