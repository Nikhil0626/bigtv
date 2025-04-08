import 'package:chotanews/utils/app_fonts.dart';
import 'package:chotanews/utils/app_spaces.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';
import '../settings_screen/settings_view.dart';

class ProfileView extends StatefulWidget {
  ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  bool isButtonEnabled = false;

  void _validateForm() {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String day = _dayController.text.trim();
    String month = _monthController.text.trim();
    String year = _yearController.text.trim();

    bool isValid = name.isNotEmpty && phone.length == 10 && day.length == 2 && month.length == 2 && year.length == 4;

    setState(() {
      isButtonEnabled = isValid;
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _dayController.addListener(_validateForm);
    _monthController.addListener(_validateForm);
    _yearController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, MaterialPageRoute(builder: (context) => SettingsView()));

          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Icon(Icons.settings, color: Colors.black54, size: 25),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[300],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 15.r,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 18, color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                height(height: 10.h),
                Center(
                  child: Text(
                    '',
                    style: newAppFont(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                height(height: 20.h),

                Text(" Name", style: newAppFont(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Colors.black87)),
                height(height: 5.h),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey[300],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                height(height: 20.h),

                // Date of Birth Fields
                Text("Date of Birth", style: newAppFont(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
                height(height: 5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _dayController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    width(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: _monthController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    width(width: 10.w),
                    Expanded(
                      child: TextField(
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                height(height: 15.h),

                // Mobile Number Field
                Text("Mobile Number", style: newAppFont(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
                height(height: 5.h),
                Container(
                  height: 55.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.grey.shade300),
                    color: AppColors.appButtonColor,
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Container(
                          height: 52.h,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 18.h,
                                width: 24.w,
                                child: SvgPicture.asset('assets/svg/indianFlag.svg', fit: BoxFit.contain),
                              ),
                              width(width: 4.w),
                              Text("+91", style: newAppFont(fontSize: 16, fontWeight: FontWeight.bold)),
                              Icon(Icons.keyboard_arrow_down_outlined, size: 20),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: "",
                            hintText: "",
                            contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                height(height: 40.h),

                // Update Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isButtonEnabled ? Colors.blue : Colors.grey,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: isButtonEnabled ? () => print("Form Submitted!") : null,
                    child: Text('Update', style: newAppFont(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
