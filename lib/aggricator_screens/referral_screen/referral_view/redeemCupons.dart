import 'package:flutter/material.dart';

class RedeemAmazonCoupons extends StatelessWidget {
  const RedeemAmazonCoupons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF26c6da), Color(0xFF00acc1)],
                  ),
                ),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        _buildSubtitle(),
                        Expanded(
                          child: SingleChildScrollView(
                            child: _buildFlowContent(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Amazon coupons are the easiest and fastest way to save money',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }


  Widget _buildFlowContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildStepRow(
            stepNumber: '01',
            leftTitle: 'Find Coupons',
            leftDescription: 'Browse available coupons on Amazon\'s coupon page or look for coupon badges on product pages.',
            rightTitle: 'Browse Available Offers',
            rightDescription: 'Visit Amazon coupons section to discover all available discounts and special offers.',
            icon: '🏷️',
            iconColor: const Color(0xFFff6b35),
            showLine: true,
          ),
          _buildStepRow(
            stepNumber: '02',
            leftTitle: 'Clip Coupon',
            leftDescription: 'Click "Clip Coupon" button next to eligible products. Coupon saves automatically to your account.',
            rightTitle: 'Activate Your Savings',
            rightDescription: 'Clipped coupons are instantly saved and ready to use on qualifying purchases.',
            icon: '✂️',
            iconColor: const Color(0xFF4caf50),
            showLine: true,
          ),
          _buildStepRow(
            stepNumber: '03',
            leftTitle: 'Add to Cart',
            leftDescription: 'Add qualifying products to your shopping cart. Coupon discount will be visible.',
            rightTitle: 'Select Products',
            rightDescription: 'Choose items eligible for your clipped coupons and add them to your cart.',
            icon: '🛒',
            iconColor: const Color(0xFF2196f3),
            showLine: true,
          ),
          _buildStepRow(
            stepNumber: '04',
            leftTitle: 'Apply at Checkout',
            leftDescription: 'Coupon discount applies automatically during checkout process with eligible items.',
            rightTitle: 'Automatic Discount',
            rightDescription: 'Your savings automatically apply when you proceed to checkout with eligible items.',
            icon: '💳',
            iconColor: const Color(0xFF9c27b0),
            showLine: true,
          ),
          _buildStepRow(
            stepNumber: '05',
            leftTitle: 'Enjoy Savings',
            leftDescription: 'Complete your purchase with discounted price. Savings shown on receipt and confirmation.',
            rightTitle: 'Complete Purchase',
            rightDescription: 'Finish your order and enjoy the reduced price with coupon savings applied.',
            icon: '✅',
            iconColor: const Color(0xFFff9800),
            showLine: false,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String stepNumber,
    required String leftTitle,
    required String leftDescription,
    required String rightTitle,
    required String rightDescription,
    required String icon,
    required Color iconColor,
    required bool showLine,
  }) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 30),
          child: Row(
            children: [
              Container(
                width: 160,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leftTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      leftDescription,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              // Right Side
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rightTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            rightDescription,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: iconColor,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 24, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Positioned(
          left: 170,
          top: 22.5,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  color: Color(0xFF00acc1),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),

        // Dotted Line
        if (showLine)
          Positioned(
            left: 185,
            top: 60,
            child: Container(
              width: 2,
              height: 55,
              child: CustomPaint(
                painter: DottedLinePainter(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLookingSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 1,
                  left: 9,
                  child: Container(
                    width: 1,
                    height: 6,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: 9,
                  right: 1,
                  child: Container(
                    width: 4,
                    height: 1,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Looking for deals?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFff6b35)
      ..strokeWidth = 2;

    double dashHeight = 6;
    double dashSpace = 6;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


