import 'package:flutter/material.dart';

class ZipHowToPlayCard extends StatefulWidget {
  final Color pathColor;

  const ZipHowToPlayCard({
    super.key,
    required this.pathColor,
  });

  @override
  State<ZipHowToPlayCard> createState() => _ZipHowToPlayCardState();
}

class _ZipHowToPlayCardState extends State<ZipHowToPlayCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2024) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2E3238) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'How to play',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Instruction Body
          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Diagram: Connect the dots in order
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 48,
                          child: Center(
                            child: _buildConnectDotsGraphic(widget.pathColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect the\ndots in order',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 60,
                    width: 1,
                    color: isDark ? const Color(0xFF2E3238) : const Color(0xFFF0F0F2),
                  ),

                  // Right Diagram: Fill every cell
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 48,
                          child: Center(
                            child: _buildFillEveryCellGraphic(widget.pathColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fill every cell',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF374151),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectDotsGraphic(Color color) {
    return SizedBox(
      width: 100,
      height: 32,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Connecting colored ribbon
          Positioned(
            left: 10,
            right: 10,
            top: 10,
            bottom: 10,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // Three dots 1, 2, 3
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniDot('1'),
              _buildMiniDot('2'),
              _buildMiniDot('3'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniDot(String number) {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFillEveryCellGraphic(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB), width: 1.5),
      ),
      padding: const EdgeInsets.all(4),
      child: CustomPaint(
        painter: _MiniSGridPainter(color: color),
      ),
    );
  }
}

class _MiniSGridPainter extends CustomPainter {
  final Color color;

  _MiniSGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE5E7EB)
      ..strokeWidth = 1.0;

    final stepX = size.width / 3;
    final stepY = size.height / 3;

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(Offset(i * stepX, 0), Offset(i * stepX, size.height), gridPaint);
      canvas.drawLine(Offset(0, i * stepY), Offset(size.width, i * stepY), gridPaint);
    }

    // Draw S-path covering all 9 cells
    final pathPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5.0;

    final path = Path();
    path.moveTo(stepX * 0.5, stepY * 2.5);
    path.lineTo(stepX * 0.5, stepY * 0.5);
    path.lineTo(stepX * 1.5, stepY * 0.5);
    path.lineTo(stepX * 1.5, stepY * 2.5);
    path.lineTo(stepX * 2.5, stepY * 2.5);
    path.lineTo(stepX * 2.5, stepY * 0.5);

    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniSGridPainter oldDelegate) => oldDelegate.color != color;
}
