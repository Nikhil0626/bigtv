import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chotanews/core/theme/color_tokens.dart';
import 'package:chotanews/features/events/presentation/screens/ticket_detail_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final Map<String, dynamic> booking;

  const PaymentSuccessScreen({super.key, required this.booking});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _popController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late List<_ConfettiParticle> _particles;
  Timer? _redirectTimer;

  @override
  void initState() {
    super.initState();

    // Scale animation for central success badge
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _popController,
      curve: Curves.elasticOut,
    );

    // Confetti particles explosion animation
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    final random = Random();
    _particles = List.generate(40, (index) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 120.0 + random.nextDouble() * 180.0;
      final color = [
        Colors.redAccent,
        Colors.greenAccent,
        Colors.amberAccent,
        Colors.blueAccent,
        Colors.purpleAccent,
        Colors.pinkAccent,
        AppColorTokens.primaryRed,
      ][index % 7];
      final size = 6.0 + random.nextDouble() * 8.0;
      return _ConfettiParticle(
        angle: angle,
        speed: speed,
        color: color,
        size: size,
        isStar: index % 3 == 0,
      );
    });

    _popController.forward();
    _confettiController.forward();

    // Automatically redirect to Tickets QR page in 1 second
    _redirectTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailScreen(booking: widget.booking),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _redirectTimer?.cancel();
    _popController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti Blast Particles Painter
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _ConfettiPainter(
                    progress: _confettiController.value,
                    particles: _particles,
                  ),
                );
              },
            ),

            // Main Content Container
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Popping Checkmark Badge
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                            blurRadius: 24,
                            spreadRadius: 6,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 72,
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Success Title
                  Text(
                    "Payment Successful! 🎉",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                      letterSpacing: 0.2,
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Subtitle
                  Text(
                    "Booking Confirmed",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF16A34A),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Redirecting indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColorTokens.primaryRed,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          "Opening your ticket QR...",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiParticle {
  final double angle;
  final double speed;
  final Color color;
  final double size;
  final bool isStar;

  _ConfettiParticle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
    required this.isStar,
  });
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_ConfettiParticle> particles;

  _ConfettiPainter({required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 40);

    for (final particle in particles) {
      final distance = particle.speed * progress;
      final x = center.dx + cos(particle.angle) * distance;
      final y = center.dy + sin(particle.angle) * distance + (progress * progress * 60);

      final alpha = (1.0 - progress).clamp(0.0, 1.0);
      final paint = Paint()
        ..color = particle.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      if (particle.isStar) {
        final path = Path();
        final radius = particle.size;
        for (int i = 0; i < 5; i++) {
          final a1 = (i * 4 * pi / 5) - (pi / 2);
          final pX = x + cos(a1) * radius;
          final pY = y + sin(a1) * radius;
          if (i == 0) {
            path.moveTo(pX, pY);
          } else {
            path.lineTo(pX, pY);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset(x, y), particle.size / 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
