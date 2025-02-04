import 'package:chotanews/utils/app_colors.dart';
import 'package:chotanews/welcome_screens/sign_in_screen.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen/flip_way2news.dart';


class EnterOtpScreen extends StatefulWidget {
  const EnterOtpScreen({super.key});

  @override
  _EnterOtpScreenState createState() => _EnterOtpScreenState();
}

class _EnterOtpScreenState extends State<EnterOtpScreen> {
  final _otpControllers = List.generate(4, (_) => TextEditingController());
  final _otpFocusNodes = List.generate(4, (_) => FocusNode());
  final _referralController = TextEditingController();
  bool _isOtpSubmitted = false;
  String _timerText = "01:00";
  int _remainingSeconds = 60;
  late bool _isResendEnabled;
  bool _isOtpEntered = false;

  @override
  void initState() {
    super.initState();
    _isResendEnabled = false; // Initially, the resend option is disabled.
  }

  // Function to start OTP resend timer
  void _startTimer() {
    if (_isOtpEntered) {
      Future.delayed(const Duration(seconds: 1), () {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
            _timerText = '00:${_remainingSeconds < 10 ? '0' : ''}$_remainingSeconds';
          });
          _startTimer();
        } else {
          setState(() {
            _isResendEnabled = true; // Allow resend once the timer reaches 0.
          });
        }
      });
    }
  }

  // Function to handle OTP box border color change based on input
  Border _getOtpBoxBorder(int index) {
    if (_isOtpSubmitted && _otpControllers[index].text.isEmpty) {
      return Border.all(color: Colors.red); // Red border when empty on submit
    }
    if (_otpControllers[index].text.isNotEmpty) {
      return Border.all(color: Colors.lightBlue); // Light blue when typing
    }
    return Border.all(color: Colors.grey); // Default grey border when empty
  }

  // OTP verification logic
  bool _validateOtp() {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  // Referral code validation logic
  bool _validateReferralCode() {
    return _referralController.text == 'XBYAAASN';
  }

  // Focus next OTP box when user enters a digit
  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index + 1]); // Move focus to the next box
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_otpFocusNodes[index - 1]); // Move focus to the previous box
    }

    if (!_isOtpEntered) {
      setState(() {
        _isOtpEntered = true;
        _startTimer(); // Start the timer once OTP entry begins
      });
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, const SignInScreen()); // Navigate back to SignInScreen
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Chota",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black),
                    ),
                    const WidgetSpan(child: SizedBox(width: 3)),
                    WidgetSpan(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: const BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "News",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Sign In',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              const Text(
                'Please enter the OTP sent to',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Text(
                    '+917396335862',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // Navigate back to SignInScreen when user taps "Change Number"
                      Navigator.pop(context, const SignInScreen());
                    },
                    child: const Text(
                      "Change Number",
                      style: TextStyle(
                          color: AppColors.appButtonColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                'Enter OTP',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _otpBox(0),
                    const SizedBox(width: 5),
                    _otpBox(1),
                    const SizedBox(width: 5),
                    _otpBox(2),
                    const SizedBox(width: 5),
                    _otpBox(3),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'OTP is valid for $_timerText',
                    style: TextStyle(color: Colors.grey[800], fontSize: 14),
                  ),
                  const SizedBox(width: 85),
                  GestureDetector(
                    onTap: _isResendEnabled ? () {
                      setState(() {
                        _remainingSeconds = 60;
                        _timerText = '01:00';
                        _isResendEnabled = false; // Disable resend until timer is finished.
                        _startTimer(); // Restart timer on resend
                      });
                    } : null,
                    child: Text(
                      " Resend OTP",
                      style: TextStyle(
                          color: _isResendEnabled ? AppColors.appButtonColor : Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Text(
                'Apply ReferralCode',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _referralController,
                decoration: const InputDecoration(
                  hintText: 'XBYAAASN',
                  labelStyle: TextStyle(color: Colors.black45, fontSize: 14),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isOtpSubmitted = true;
                      if (_validateOtp()) {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) =>  MyHomePage1()),
                        // );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return Container(
      width: 73,
      height: 46,
      decoration: BoxDecoration(
        border: _getOtpBoxBorder(index), // Border color changes here
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: TextField(
          controller: _otpControllers[index],
          focusNode: _otpFocusNodes[index], // Set the focus node
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          // Removed maxLength to avoid the 0/1 indicator
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          onChanged: (value) {
            _onOtpChanged(value, index); // Handle OTP box change
          },
        ),
      ),
    );
  }
}
