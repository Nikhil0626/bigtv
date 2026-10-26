import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sudoku_game_provider.dart';

class SudokuNumberPad extends StatelessWidget {
  const SudokuNumberPad({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SudokuGameProvider>(
      builder: (context, game, child) {
        final remaining = game.remainingCounts;
        final numDigits = game.size;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(numDigits, (index) {
            final digit = index + 1;
            final count = remaining[digit] ?? 0;
            final isComplete = count == 0;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.5),
                child: InkWell(
                  onTap: () => game.enterDigit(digit),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: isComplete
                          ? (isDark
                              ? const Color(0xFF181A1D)
                              : const Color(0xFFF3F4F6))
                          : (isDark
                              ? const Color(0xFF1E2024)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isComplete
                            ? Colors.transparent
                            : (isDark
                                ? const Color(0xFF33363D)
                                : const Color(0xFFD1D5DB)),
                        width: 1.2,
                      ),
                      boxShadow: isComplete
                          ? null
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(
                                    alpha: isDark ? 0.2 : 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$digit',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isComplete
                                ? (isDark
                                    ? const Color(0xFF4B5563)
                                    : const Color(0xFF9CA3AF))
                                : (isDark
                                    ? Colors.white
                                    : const Color(0xFF111827)),
                          ),
                        ),
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isComplete
                                ? (isDark
                                    ? const Color(0xFF374151)
                                    : const Color(0xFFD1D5DB))
                                : (isDark
                                    ? const Color(0xFF9CA3AF)
                                    : const Color(0xFF6B7280)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
