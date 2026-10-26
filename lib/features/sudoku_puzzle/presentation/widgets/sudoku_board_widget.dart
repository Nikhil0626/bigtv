import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/game_watermark_widget.dart';
import '../../data/models/sudoku_cell.dart';
import '../providers/sudoku_game_provider.dart';

class SudokuBoardWidget extends StatelessWidget {
  const SudokuBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SudokuGameProvider>(
      builder: (context, game, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            const boardPadding = 8.0;
            final maxGridWidth = availableWidth - (boardPadding * 2);
            final maxGridHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight - (boardPadding * 2)
                : maxGridWidth;

            final s = game.size;
            final cellWidth = maxGridWidth / s;
            final cellHeight = maxGridHeight / s;
            final cellSize =
                (cellWidth < cellHeight ? cellWidth : cellHeight).clamp(42.0, 62.0);

            final boardSize = cellSize * s;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Center(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) {
                  final local = details.localPosition;
                  if (local.dx >= 0 &&
                      local.dx < boardSize &&
                      local.dy >= 0 &&
                      local.dy < boardSize) {
                    final col = (local.dx / cellSize).floor().clamp(0, s - 1);
                    final row = (local.dy / cellSize).floor().clamp(0, s - 1);
                    game.selectCell(row, col);
                  }
                },
                child: Container(
                  width: boardSize,
                  height: boardSize,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2024) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF33363D)
                          : const Color(0xFFD1D5DB),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                            alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      CustomPaint(
                        size: Size(boardSize, boardSize),
                        painter: _SudokuBoardPainter(
                          game: game,
                          cellSize: cellSize,
                          isDark: isDark,
                        ),
                      ),
                      if (game.isCompleted)
                        Positioned.fill(
                          child: GameWatermarkWidget(
                            size: boardSize * 0.55,
                          ),
                        ),
                    ],
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

class _SudokuBoardPainter extends CustomPainter {
  final SudokuGameProvider game;
  final double cellSize;
  final bool isDark;

  _SudokuBoardPainter({
    required this.game,
    required this.cellSize,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = game.size;
    final selR = game.selectedRow;
    final selC = game.selectedCol;
    final selVal = game.selectedCell?.value ?? 0;

    // 1. Draw Cell Background Highlights
    for (int r = 0; r < s; r++) {
      for (int c = 0; c < s; c++) {
        final cell = game.grid[r][c];
        final isSelected = (r == selR && c == selC);
        // 2x3 box membership: r ~/ 2 and c ~/ 3
        final isPeer = selR != null &&
            selC != null &&
            (r == selR ||
                c == selC ||
                (r ~/ 2 == selR ~/ 2 && c ~/ 3 == selC ~/ 3));
        final isSameNumber =
            selVal != 0 && cell.value == selVal && !isSelected;

        Color? bgColor;
        if (isSelected) {
          bgColor = isDark
              ? const Color(0xFF1E3A8A).withValues(alpha: 0.6)
              : const Color(0xFFBFDBFE);
        } else if (isSameNumber) {
          bgColor = isDark
              ? const Color(0xFF1E3A8A).withValues(alpha: 0.35)
              : const Color(0xFFDBEAFE);
        } else if (isPeer) {
          bgColor = isDark
              ? const Color(0xFF282C34).withValues(alpha: 0.5)
              : const Color(0xFFF1F5F9);
        }

        if (bgColor != null) {
          final rect = Rect.fromLTWH(
            c * cellSize,
            r * cellSize,
            cellSize,
            cellSize,
          );
          canvas.drawRect(rect, Paint()..color = bgColor);
        }
      }
    }

    // 2. Draw Grid Lines with 2x3 box separation
    _drawGridLines(canvas, size, s);

    // 3. Draw Selected Cell Outline
    if (selR != null && selC != null) {
      final selRect = Rect.fromLTWH(
        selC * cellSize,
        selR * cellSize,
        cellSize,
        cellSize,
      );
      final borderPaint = Paint()
        ..color = const Color(0xFF2563EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(selRect, borderPaint);
    }

    // 4. Draw Digits and Pencil Notes
    for (int r = 0; r < s; r++) {
      for (int c = 0; c < s; c++) {
        final cell = game.grid[r][c];
        final center = Offset(
          (c + 0.5) * cellSize,
          (r + 0.5) * cellSize,
        );

        if (cell.value != 0) {
          _drawDigit(canvas, center, cell);
        } else if (cell.notes.isNotEmpty) {
          _drawPencilNotes(canvas, r, c, cell.notes);
        }
      }
    }
  }

  void _drawGridLines(Canvas canvas, Size size, int s) {
    final thinPaint = Paint()
      ..color = isDark ? const Color(0xFF2D3139) : const Color(0xFFE5E7EB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final thickPaint = Paint()
      ..color = isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Horizontal lines: thick line every 2 rows (i = 2, 4)
    for (int r = 1; r < s; r++) {
      final isMajor = (r % 2 == 0);
      final paint = isMajor ? thickPaint : thinPaint;
      final y = r * cellSize;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines: thick line every 3 cols (i = 3)
    for (int c = 1; c < s; c++) {
      final isMajor = (c % 3 == 0);
      final paint = isMajor ? thickPaint : thinPaint;
      final x = c * cellSize;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawDigit(Canvas canvas, Offset center, SudokuCell cell) {
    Color textColor;
    FontWeight fontWeight;

    if (cell.isError) {
      textColor = const Color(0xFFEF4444);
      fontWeight = FontWeight.bold;
    } else if (cell.isGiven) {
      textColor = isDark ? Colors.white : const Color(0xFF111827);
      fontWeight = FontWeight.bold;
    } else {
      textColor = isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
      fontWeight = FontWeight.w600;
    }

    final fontSize = cellSize * 0.52;
    final textSpan = TextSpan(
      text: '${cell.value}',
      style: TextStyle(
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
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
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawPencilNotes(
      Canvas canvas, int r, int c, Set<int> notes) {
    // 2 rows x 3 columns layout for notes 1..6
    final subCellWidth = cellSize / 3;
    final subCellHeight = cellSize / 2;
    final noteFontSize = cellSize * 0.24;
    final noteColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    for (final note in notes) {
      if (note < 1 || note > 6) continue;
      final noteIndex = note - 1;
      final subR = noteIndex ~/ 3;
      final subC = noteIndex % 3;

      final center = Offset(
        c * cellSize + (subC + 0.5) * subCellWidth,
        r * cellSize + (subR + 0.5) * subCellHeight,
      );

      final textSpan = TextSpan(
        text: '$note',
        style: TextStyle(
          color: noteColor,
          fontSize: noteFontSize,
          fontWeight: FontWeight.w500,
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
        Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SudokuBoardPainter oldDelegate) => true;
}
