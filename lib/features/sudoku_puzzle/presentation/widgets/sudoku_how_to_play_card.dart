import 'package:flutter/material.dart';

class SudokuHowToPlayCard extends StatefulWidget {
  const SudokuHowToPlayCard({super.key});

  @override
  State<SudokuHowToPlayCard> createState() => _SudokuHowToPlayCardState();
}

class _SudokuHowToPlayCardState extends State<SudokuHowToPlayCard> {
  bool _isExpanded = false;

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
                  // Left Graphic: 2x3 Mini Sudoku Block Diagram (6 numbers)
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 52,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E3A8A).withValues(alpha: 0.2)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF3B82F6),
                              width: 1.5,
                            ),
                          ),
                          child: GridView.count(
                            crossAxisCount: 3,
                            physics: const NeverScrollableScrollPhysics(),
                            children: List.generate(6, (index) {
                              return Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFF93C5FD)
                                        : const Color(0xFF1D4ED8),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '6 numbers only\neach box (1 to 6)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF374151),
                            height: 1.2,
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
                  const SizedBox(width: 12),

                  // Right Rules
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRuleRow('Rows', 'Each row has digits 1-6 once', isDark),
                        const SizedBox(height: 6),
                        _buildRuleRow('Columns', 'Each column has digits 1-6 once', isDark),
                        const SizedBox(height: 6),
                        _buildRuleRow('Boxes', '6 numbers only in each 2×3 box', isDark),
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

            // Bottom footnote matching LinkedIn style
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Toggle Notes to pencil candidate numbers (1-6) in tricky cells.',
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

  Widget _buildRuleRow(String label, String desc, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF374151)
                : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            desc,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color(0xFFD1D5DB)
                  : const Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }
}
