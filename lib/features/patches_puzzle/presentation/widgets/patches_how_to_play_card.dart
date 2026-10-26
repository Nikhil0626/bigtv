import 'package:flutter/material.dart';

class PatchesHowToPlayCard extends StatefulWidget {
  const PatchesHowToPlayCard({super.key});

  @override
  State<PatchesHowToPlayCard> createState() => _PatchesHowToPlayCardState();
}

class _PatchesHowToPlayCardState extends State<PatchesHowToPlayCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2024) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF33363D) : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Row: "How to play" + Chevron toggle
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
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
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22,
                    color: isDark
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left Graphic: 2x2 shape diagram with top-left '4' badge matching screenshot
                  Expanded(
                    flex: 5,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFF59E0B),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: _Mini2x2GridPainter(),
                                ),
                              ),
                              // Top-left number 4 badge
                              Positioned(
                                top: 4,
                                left: 4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '4',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Complete each\nshape to fill the grid',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF374151),
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Vertical Divider
                  Container(
                    height: 85,
                    width: 1,
                    color: isDark
                        ? const Color(0xFF2E3238)
                        : const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(width: 14),

                  // Right Legend: Exact 4 shape icons from screenshot
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLegendRow('Square', 'square', isDark),
                        const SizedBox(height: 7),
                        _buildLegendRow('Tall rectangle', 'tall', isDark),
                        const SizedBox(height: 7),
                        _buildLegendRow('Wide rectangle', 'wide', isDark),
                        const SizedBox(height: 7),
                        _buildLegendRow('Any of the above', 'any', isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Subtle divider line
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Divider(
                height: 1,
                color: isDark
                    ? const Color(0xFF2E3238)
                    : const Color(0xFFE5E7EB),
              ),
            ),

            // Bottom note matching screenshot
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'If a shape has a number, it must be that size.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegendRow(String title, String type, bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: Center(
            child: _buildLegendIcon(type, isDark),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendIcon(String type, bool isDark) {
    final color = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    if (type == 'square') {
      return Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      );
    } else if (type == 'tall') {
      return Container(
        width: 9,
        height: 15,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.5),
        ),
      );
    } else if (type == 'wide') {
      return Container(
        width: 15,
        height: 9,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4.5),
        ),
      );
    } else {
      // 'any': 4-way cross shape matching LinkedIn screenshot
      return SizedBox(
        width: 16,
        height: 16,
        child: CustomPaint(
          painter: _TabbedStampIconPainter(color: color),
        ),
      );
    }
  }
}

class _TabbedStampIconPainter extends CustomPainter {
  final Color color;

  _TabbedStampIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final horiz = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 14, height: 6),
      const Radius.circular(2),
    );
    final vert = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 6, height: 14),
      const Radius.circular(2),
    );
    canvas.drawRRect(horiz, paint);
    canvas.drawRRect(vert, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Mini2x2GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const dashWidth = 3.0;
    const dashSpace = 2.5;

    // Vertical dashed center line
    final midX = size.width / 2;
    double y = 0;
    while (y < size.height) {
      final nextY = (y + dashWidth).clamp(0.0, size.height);
      canvas.drawLine(Offset(midX, y), Offset(midX, nextY), paint);
      y += dashWidth + dashSpace;
    }

    // Horizontal dashed center line
    final midY = size.height / 2;
    double x = 0;
    while (x < size.width) {
      final nextX = (x + dashWidth).clamp(0.0, size.width);
      canvas.drawLine(Offset(x, midY), Offset(nextX, midY), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
