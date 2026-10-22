import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/grid_point.dart';
import '../providers/zip_game_provider.dart';

class ZipBoardWidget extends StatelessWidget {
  const ZipBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ZipGameProvider>(
      builder: (context, game, child) {
        final level = game.level;
        return LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth;
            final maxH = constraints.maxHeight;

            final cellW = maxW / level.cols;
            final cellH = maxH / level.rows;
            final cellSize = cellW < cellH ? cellW : cellH;

            final boardWidth = cellSize * level.cols;
            final boardHeight = cellSize * level.rows;

            GridPoint? pointFromOffset(Offset local) {
              if (local.dx < 0 ||
                  local.dx >= boardWidth ||
                  local.dy < 0 ||
                  local.dy >= boardHeight) {
                return null;
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
                  final pt = pointFromOffset(details.localPosition);
                  if (pt != null) game.moveTo(pt);
                },
                onPanUpdate: (details) {
                  final pt = pointFromOffset(details.localPosition);
                  if (pt != null) game.moveTo(pt);
                },
                onTapDown: (details) {
                  final pt = pointFromOffset(details.localPosition);
                  if (pt != null) game.moveTo(pt);
                },
                child: Container(
                  width: boardWidth,
                  height: boardHeight,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1C20) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF383B42)
                          : const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.35 : 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CustomPaint(
                      size: Size(boardWidth, boardHeight),
                      painter: _ZipBoardPainter(
                        game: game,
                        cellSize: cellSize,
                        isDark: isDark,
                      ),
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

class _ZipBoardPainter extends CustomPainter {
  final ZipGameProvider game;
  final double cellSize;
  final bool isDark;

  _ZipBoardPainter({
    required this.game,
    required this.cellSize,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final level = game.level;
    final path = game.currentPath;
    final visitedSet = path.toSet();

    final Color pathColor = game.pathColor;
    final Color tintColor =
        isDark ? pathColor.withValues(alpha: 0.28) : game.cellTintColor;
    final Color gridLineColor =
        isDark ? const Color(0xFF2E3138) : const Color(0xFFE2E4E8);
    final Color wallColor = isDark ? Colors.white : Colors.black;

    // Start cell (Point 1) is highlighted even before tracing
    final startPt = level.getCheckpointPoint(1);

    // 1. Draw visited / active cell pastel background tints
    final tintPaint = Paint()
      ..color = tintColor
      ..style = PaintingStyle.fill;

    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        final pt = GridPoint(r, c);
        final bool shouldTint =
            visitedSet.contains(pt) || (path.isEmpty && pt == startPt);

        if (shouldTint) {
          canvas.drawRect(
            Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize),
            tintPaint,
          );
        }
      }
    }

    // 2. Draw subtle inner grid lines
    final gridLinePaint = Paint()
      ..color = gridLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int r = 1; r < level.rows; r++) {
      final y = r * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridLinePaint);
    }
    for (int c = 1; c < level.cols; c++) {
      final x = c * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridLinePaint);
    }

    // 3. Draw Solid Smooth Path Ribbon (Pipe)
    if (path.length >= 2) {
      final pathPaint = Paint()
        ..color = pathColor
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = cellSize * 0.44;

      final Path drawPath = Path();
      final firstCenter = Offset(
          (path[0].col + 0.5) * cellSize, (path[0].row + 0.5) * cellSize);
      drawPath.moveTo(firstCenter.dx, firstCenter.dy);

      for (int i = 1; i < path.length; i++) {
        final center = Offset(
            (path[i].col + 0.5) * cellSize, (path[i].row + 0.5) * cellSize);
        drawPath.lineTo(center.dx, center.dy);
      }

      canvas.drawPath(drawPath, pathPaint);
    } else if (path.length == 1) {
      // Draw single circle cap at point 1 when started
      final firstCenter = Offset(
          (path[0].col + 0.5) * cellSize, (path[0].row + 0.5) * cellSize);
      final capPaint = Paint()
        ..color = pathColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(firstCenter, cellSize * 0.22, capPaint);
    }

    // 4. Draw Thick Black Barrier Walls
    final wallPaint = Paint()
      ..color = wallColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 5.0;

    for (final wall in level.walls) {
      final p1 = wall.a;
      final p2 = wall.b;

      if (p1.row == p2.row) {
        // Vertical wall between col and col+1
        final col = p1.col < p2.col ? p2.col : p1.col;
        final x = col * cellSize;
        final y1 = p1.row * cellSize;
        final y2 = (p1.row + 1) * cellSize;
        canvas.drawLine(Offset(x, y1), Offset(x, y2), wallPaint);
      } else if (p1.col == p2.col) {
        // Horizontal wall between row and row+1
        final row = p1.row < p2.row ? p2.row : p1.row;
        final y = row * cellSize;
        final x1 = p1.col * cellSize;
        final x2 = (p1.col + 1) * cellSize;
        canvas.drawLine(Offset(x1, y), Offset(x2, y), wallPaint);
      }
    }

    // 5. Draw Solid Black Numbered Checkpoint Discs (Clean, no highlight rings)
    for (int r = 0; r < level.rows; r++) {
      for (int c = 0; c < level.cols; c++) {
        final pt = GridPoint(r, c);
        final cpNumber = level.getCheckpointNumber(pt);

        if (cpNumber != null) {
          final center = Offset((c + 0.5) * cellSize, (r + 0.5) * cellSize);
          final radius = cellSize * 0.28;

          // Check if this checkpoint has been reached and whether it's out of order
          final visitedCheckpoints = game.visitedCheckpointNumbers;
          final int cpIdx = visitedCheckpoints.indexOf(cpNumber);
          final bool isOutOfOrder =
              cpIdx != -1 && (cpIdx + 1 != cpNumber);

          // Solid Disc: warning red if out of order, black otherwise
          final discPaint = Paint()
            ..color = isOutOfOrder ? const Color(0xFFDC2626) : Colors.black
            ..style = PaintingStyle.fill;
          canvas.drawCircle(center, radius, discPaint);

          if (isOutOfOrder) {
            final ringPaint = Paint()
              ..color = const Color(0xFFFCA5A5)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5;
            canvas.drawCircle(center, radius + 2, ringPaint);
          }

          // Crisp White Bold Number
          final textSpan = TextSpan(
            text: '$cpNumber',
            style: TextStyle(
              color: Colors.white,
              fontSize: cellSize * 0.28,
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
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZipBoardPainter oldDelegate) => true;
}
