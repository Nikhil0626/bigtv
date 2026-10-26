import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chotanews/features/zip_puzzle/data/models/grid_point.dart';
import '../../data/models/drawn_patch.dart';
import '../../data/models/patch_clue.dart';
import '../providers/patches_game_provider.dart';

class PatchesBoardWidget extends StatelessWidget {
  const PatchesBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PatchesGameProvider>(
      builder: (context, game, child) {
        final level = game.level;

        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final boardPadding = 12.0;
            final maxGridWidth = availableWidth - (boardPadding * 2);
            final maxGridHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight - 16.0
                : maxGridWidth;

            final cellWidth = maxGridWidth / level.cols;
            final cellHeight = maxGridHeight / level.rows;
            final cellSize =
                (cellWidth < cellHeight ? cellWidth : cellHeight).clamp(34.0, 64.0);

            final boardWidth = cellSize * level.cols;
            final boardHeight = cellSize * level.rows;

            GridPoint? pointFromOffset(Offset local, {bool clamp = false}) {
              if (!clamp) {
                if (local.dx < 0 ||
                    local.dx >= boardWidth ||
                    local.dy < 0 ||
                    local.dy >= boardHeight) {
                  return null;
                }
              }
              final col =
                  (local.dx / cellSize).floor().clamp(0, level.cols - 1);
              final row =
                  (local.dy / cellSize).floor().clamp(0, level.rows - 1);
              return GridPoint(row, col);
            }

            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: (details) {
                  final pt = pointFromOffset(details.localPosition, clamp: false);
                  if (pt != null) game.startDrag(pt);
                },
                onPanUpdate: (details) {
                  final pt = pointFromOffset(details.localPosition, clamp: true);
                  if (pt != null) game.updateDrag(pt);
                },
                onPanEnd: (_) => game.endDrag(),
                child: Container(
                  width: boardWidth,
                  height: boardHeight,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2024) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF33363D)
                          : const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: isDark ? 0.25 : 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CustomPaint(
                    size: Size(boardWidth, boardHeight),
                    painter: _PatchesBoardPainter(
                      game: game,
                      cellSize: cellSize,
                      isDark: isDark,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PatchesBoardPainter extends CustomPainter {
  final PatchesGameProvider game;
  final double cellSize;
  final bool isDark;

  _PatchesBoardPainter({
    required this.game,
    required this.cellSize,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final level = game.level;

    // 1. Draw clue cell pastel tints (each clue cell has its soft pastel background)
    _drawClueCellTints(canvas, level.clues, level.rows, level.cols);

    // 2. Draw placed patches (pastel fill and colored border)
    for (final patch in game.placedPatches) {
      _drawPlacedPatch(canvas, patch);
    }

    // 3. Draw dashed grid lines
    _drawDashedGrid(canvas, size, level.rows, level.cols);

    // 4. Draw active preview patch while dragging
    final preview = game.previewPatch;
    if (preview != null) {
      _drawPreviewPatch(canvas, preview, game.isPreviewValid);
    }

    // 5. Draw clue badges (shapes matching screenshot: wide, tall, square, any)
    for (final clue in level.clues) {
      _drawClueBadge(canvas, clue);
    }
  }

  void _drawClueCellTints(
      Canvas canvas, List<PatchClue> clues, int rows, int cols) {
    for (final clue in clues) {
      final r = clue.point.row;
      final c = clue.point.col;

      final rect = Rect.fromLTWH(
        c * cellSize,
        r * cellSize,
        cellSize,
        cellSize,
      );

      // Match corner rounding if clue sits in an outer corner of the board
      BorderRadius borderRadius = BorderRadius.zero;
      const cornerRadius = Radius.circular(16);
      if (r == 0 && c == 0) {
        borderRadius = const BorderRadius.only(topLeft: cornerRadius);
      } else if (r == 0 && c == cols - 1) {
        borderRadius = const BorderRadius.only(topRight: cornerRadius);
      } else if (r == rows - 1 && c == 0) {
        borderRadius = const BorderRadius.only(bottomLeft: cornerRadius);
      } else if (r == rows - 1 && c == cols - 1) {
        borderRadius = const BorderRadius.only(bottomRight: cornerRadius);
      }

      final paint = Paint()
        ..color = isDark
            ? clue.color.withValues(alpha: 0.18)
            : clue.tintColor
        ..style = PaintingStyle.fill;

      if (borderRadius != BorderRadius.zero) {
        canvas.drawRRect(borderRadius.toRRect(rect), paint);
      } else {
        canvas.drawRect(rect, paint);
      }
    }
  }

  void _drawDashedGrid(Canvas canvas, Size size, int rows, int cols) {
    final linePaint = Paint()
      ..color = isDark ? const Color(0xFF2C2F36) : const Color(0xFFE2E4E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double dashWidth = 3.5;
    const double dashSpace = 3.5;

    // Horizontal dashed lines
    for (int r = 1; r < rows; r++) {
      final y = r * cellSize;
      double startX = 0;
      while (startX < size.width) {
        final endX = (startX + dashWidth).clamp(0.0, size.width);
        canvas.drawLine(Offset(startX, y), Offset(endX, y), linePaint);
        startX += dashWidth + dashSpace;
      }
    }

    // Vertical dashed lines
    for (int c = 1; c < cols; c++) {
      final x = c * cellSize;
      double startY = 0;
      while (startY < size.height) {
        final endY = (startY + dashWidth).clamp(0.0, size.height);
        canvas.drawLine(Offset(x, startY), Offset(x, endY), linePaint);
        startY += dashWidth + dashSpace;
      }
    }
  }

  void _drawPlacedPatch(Canvas canvas, DrawnPatch patch) {
    final rect = Rect.fromLTRB(
      patch.minCol * cellSize + 1.5,
      patch.minRow * cellSize + 1.5,
      (patch.maxCol + 1) * cellSize - 1.5,
      (patch.maxRow + 1) * cellSize - 1.5,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    // Fill with soft pastel tint
    final fillPaint = Paint()
      ..color = isDark
          ? patch.color.withValues(alpha: 0.22)
          : patch.tintColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(rrect, fillPaint);

    // Thick perimeter border
    final borderPaint = Paint()
      ..color = isDark ? patch.color : patch.color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawPreviewPatch(
      Canvas canvas, DrawnPatch preview, bool isValid) {
    final rect = Rect.fromLTRB(
      preview.minCol * cellSize + 1.5,
      preview.minRow * cellSize + 1.5,
      (preview.maxCol + 1) * cellSize - 1.5,
      (preview.maxRow + 1) * cellSize - 1.5,
    );

    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));

    if (isValid) {
      final fillColor = isDark
          ? preview.color.withValues(alpha: 0.25)
          : preview.tintColor.withValues(alpha: 0.85);

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      final borderPaint = Paint()
        ..color = preview.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(rrect, borderPaint);
    } else {
      // Clean subtle neutral preview while dragging
      final fillColor = isDark
          ? Colors.white.withValues(alpha: 0.05)
          : const Color(0xFF6B7280).withValues(alpha: 0.06);

      final fillPaint = Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(rrect, fillPaint);

      final borderColor = isDark
          ? const Color(0xFF4B5563)
          : const Color(0xFF9CA3AF);
      _drawDashedRRect(canvas, rrect, borderColor, 1.8);
    }
  }

  void _drawDashedRRect(
      Canvas canvas, RRect rrect, Color color, double strokeWidth) {
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      const dashLength = 4.0;
      const dashSpace = 4.0;
      while (distance < metric.length) {
        final next = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  void _drawClueBadge(Canvas canvas, PatchClue clue) {
    final center = Offset(
      (clue.point.col + 0.5) * cellSize,
      (clue.point.row + 0.5) * cellSize,
    );

    final paint = Paint()
      ..color = clue.color
      ..style = PaintingStyle.fill;

    if (clue.shapeType == PatchShapeType.wide) {
      // Horizontal pill capsule matching LinkedIn screenshot
      final w = cellSize * 0.72;
      final h = cellSize * 0.46;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w, height: h),
        Radius.circular(h / 2),
      );
      canvas.drawRRect(rrect, paint);
      _drawClueNumber(canvas, center, clue.targetArea, cellSize * 0.32);
    } else if (clue.shapeType == PatchShapeType.tall) {
      // Vertical pill capsule matching LinkedIn screenshot
      final w = cellSize * 0.46;
      final h = cellSize * 0.72;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: w, height: h),
        Radius.circular(w / 2),
      );
      canvas.drawRRect(rrect, paint);
      _drawClueNumber(canvas, center, clue.targetArea, cellSize * 0.32);
    } else if (clue.shapeType == PatchShapeType.square) {
      // Rounded square matching LinkedIn screenshot
      final size = cellSize * 0.54;
      final rrect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size, height: size),
        const Radius.circular(7),
      );
      canvas.drawRRect(rrect, paint);
      _drawClueNumber(canvas, center, clue.targetArea, cellSize * 0.32);
    } else {
      // PatchShapeType.any: Swiss 4-way cross shape with rounded arms
      final armLength = cellSize * 0.62;
      final armThick = cellSize * 0.32;
      final crossRadius = Radius.circular(armThick * 0.35);

      final horizRRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: armLength, height: armThick),
        crossRadius,
      );
      final vertRRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: armThick, height: armLength),
        crossRadius,
      );
      canvas.drawRRect(horizRRect, paint);
      canvas.drawRRect(vertRRect, paint);
      _drawClueNumber(canvas, center, clue.targetArea, cellSize * 0.32);
    }
  }

  void _drawClueNumber(
      Canvas canvas, Offset center, int? number, double fontSize) {
    if (number == null) return; // Clues without numbers are empty solid shapes

    final textSpan = TextSpan(
      text: '$number',
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PatchesBoardPainter oldDelegate) => true;
}
