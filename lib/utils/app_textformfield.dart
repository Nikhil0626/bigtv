// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
//
// import 'app_fonts.dart';
//
// class AppTextFormField extends StatefulWidget {
//   final TextEditingController textEditingController;
//   final bool isFormValid;
//   final bool readOnly;
//   final FormFieldValidator<String>? validator;
//   final String label;
//   final IconData prefixIcon;
//   final TextInputType keyboardType;
//   final VoidCallback? onTap;
//
//   const AppTextFormField({
//     super.key,
//     required this.textEditingController,
//     required this.isFormValid,
//     this.readOnly = false,
//     this.validator,
//     this.onTap ,
//     required this.label,
//     this.prefixIcon = Icons.email,
//     this.keyboardType = TextInputType.text,
//   });
//
//   @override
//   State<AppTextFormField> createState() => _AppTextFormFieldState();
// }
//
// class _AppTextFormFieldState extends State<AppTextFormField> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: BoxConstraints(
//         maxHeight: widget.isFormValid ? 40.sp : 80.sp,
//       ),
//       child: TextFormField(
//         controller: widget.textEditingController,
//         readOnly: widget.readOnly,
//         onTap: widget.onTap,
//         decoration: InputDecoration(
//           contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
//           labelText: widget.label,
//           labelStyle: fontStyle(fontWeight: FontWeight.w400, fontSize: 14),
//           prefixIcon: Icon(
//             widget.prefixIcon,
//             size: 20.sp,
//           ),
//           border: const OutlineInputBorder(),
//         ),
//         style: fontStyle(fontWeight: FontWeight.w400, fontSize: 14),
//         keyboardType: widget.keyboardType,
//         validator: widget.validator,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextFormField extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isFormValid;
  final bool readOnly;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final String label;
  final bool maxLength;
  final int maxLines;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChange;

  const AppTextFormField({
    super.key,
    required this.textEditingController,
    required this.isFormValid,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLength = false,
    this.maxLines = 1,
    this.validator,
    this.onTap,
    this.onChange,
    required this.label,
    this.prefixIcon = Icons.email,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  bool _isPasswordVisible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            minHeight: 60,
            maxHeight: widget.isFormValid ? 60 : 100,
          ),
          child: TextFormField(
            cursorColor: AppColors.appButtonColor,
            controller: widget.textEditingController,
            readOnly: widget.readOnly,
            maxLength: widget.maxLength ? 10 : 100,
            maxLines: widget.maxLines,
            onTap: widget.onTap,
            obscureText: widget.obscureText && _isPasswordVisible,
            onChanged: widget.onChange,

            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.borderColor, width: 1.5),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: AppColors.appButtonColor, width: 2.0),
                borderRadius: BorderRadius.circular(8),
              ),
              counterText: "",
              contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              labelText: widget.label,
              labelStyle: fontStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
              prefixIcon: widget.label == ''
                  ? const SizedBox.shrink()
                  : Padding(
                padding: const EdgeInsets.only(left: 10, right: 8),
                // Icon spacing
                child: Icon(
                  widget.prefixIcon,
                  size: 20,
                ),
              ),
              suffixIcon: widget.obscureText
                  ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_off
                      : Icons.visibility,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
                  : null,
              errorStyle: const TextStyle(
                fontSize: 12,
                color: Colors.red,
              ),
            ),

            style: fontStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
            ),
            keyboardType: widget.keyboardType,
            validator: widget.validator,
          ),
        ),

      ],
    );
  }
}


class AppTextFormField1 extends StatefulWidget {
  final TextEditingController textEditingController;
  final bool isFormValid;
  final bool readOnly;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final String label;
  final bool maxLength;
  final int maxLines;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChange;

  const AppTextFormField1({
    super.key,
    required this.textEditingController,
    required this.isFormValid,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLength = false,
    this.maxLines = 10,
    this.validator,
    this.onTap,
    this.onChange,
    required this.label,
    this.prefixIcon = Icons.email,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<AppTextFormField1> createState() => _AppTextFormField1State();
}

class _AppTextFormField1State extends State<AppTextFormField1> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return
      TextFormField(
        scribbleEnabled: true,

        textAlign: TextAlign.start,
        controller: widget.textEditingController,
        readOnly: widget.readOnly,
        maxLines: widget.maxLines == 10?null:widget.maxLines,
        onTap: widget.onTap,
        obscureText: widget.obscureText && _isPasswordVisible,
        onChanged: widget.onChange,
        decoration: InputDecoration(
          counterText: "",
          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          labelText: widget.label,
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(8), // Rounded corners
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: AppColors.borderColor, width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
          // errorBorder: OutlineInputBorder(
          //   borderSide: const BorderSide(color: Colors.red, width: 1.5),
          //   borderRadius: BorderRadius.circular(8),
          // ),
          // focusedErrorBorder: OutlineInputBorder(
          //   borderSide: BorderSide(color: Colors.green, width: 2.0),
          //   borderRadius: BorderRadius.circular(8),
          // ),
        ),
        style: fontStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
        ),
        keyboardType: widget.keyboardType,
        validator: widget.validator,
      );

    //   TextFormField(
    //   controller: widget.textEditingController,
    //   readOnly: widget.readOnly,
    //   maxLength: widget.maxLength ? 10 : 100,
    //   maxLines: widget.maxLines,
    //   onTap: widget.onTap,
    //   obscureText: widget.obscureText && _isPasswordVisible,
    //   onChanged: widget.onChange,
    //   decoration: InputDecoration(
    //     counterText: "",
    //     contentPadding:
    //     const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    //     labelText: widget.label,
    //     border: OutlineInputBorder(
    //       borderSide: BorderSide(color: AppColors.appButtonColor)
    //     )
    //
    //
    //   ),
    //   style: fontStyle(
    //     fontWeight: FontWeight.w400,
    //     fontSize: 14,
    //   ),
    //   keyboardType: widget.keyboardType,
    //   validator: widget.validator,
    // );
  }
}