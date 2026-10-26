import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/color_tokens.dart';
import '../../data/models/daily_puzzle_models.dart';
import '../providers/daily_puzzle_provider.dart';

class ZipDailyStreakCard extends StatelessWidget {
  const ZipDailyStreakCard({super.key});

  void _showRecoveryDialog(BuildContext context, DailyPuzzleProvider provider) {
    final reasonController = TextEditingController(
      text: 'Was traveling without cellular network',
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isRecovering = provider.isRequestingRecovery;

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(
                children: [
                  Icon(Icons.restore_rounded, color: Colors.deepOrange, size: 24),
                  SizedBox(width: 8),
                  Text('Retrieve Streak', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You missed ${provider.gapDays} days. Would you like to restore your streak?',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.autoApproveRemaining > 0
                                ? 'Auto-approvals available: ${provider.autoApproveRemaining}. Your streak will be restored instantly!'
                                : 'Auto-approvals exhausted. Request will be submitted for admin review.',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      labelText: 'Reason for gap',
                      hintText: 'Enter reason...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isRecovering ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isRecovering
                      ? null
                      : () async {
                          final response = await provider.requestStreakRecovery(
                            reason: reasonController.text.trim(),
                          );
                          if (!dialogCtx.mounted) return;
                          Navigator.pop(dialogCtx);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response.message),
                                backgroundColor: response.isAutoApproved
                                    ? Colors.green
                                    : AppColorTokens.primaryRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: isRecovering
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Restore Streak'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<DailyPuzzleProvider>();
    final streak = provider.currentStreak;
    final longest = provider.longestStreak;
    final last7 = provider.last7Days;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2B1810), const Color(0xFF1E1E1E)]
              : [const Color(0xFFFFF7ED), const Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF4A2A1A) : const Color(0xFFFFD8A8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Flame + Streak count + Free Revive pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.deepOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$streak Day Streak',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Best: $longest days',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? const Color(0xFF9E9E9E) : const Color(0xFF6B7280),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Monthly Free Revive Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: provider.monthlyFreeReviveAvailable
                      ? Colors.teal.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: provider.monthlyFreeReviveAvailable
                        ? Colors.teal.withValues(alpha: 0.4)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      provider.monthlyFreeReviveAvailable
                          ? Icons.shield_rounded
                          : Icons.shield_outlined,
                      size: 13,
                      color: provider.monthlyFreeReviveAvailable
                          ? Colors.teal
                          : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      provider.monthlyFreeReviveAvailable
                          ? '1 Free Revive'
                          : 'Revive Used',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: provider.monthlyFreeReviveAvailable
                            ? Colors.teal
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 7-Day Rolling Calendar Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: last7.isNotEmpty
                ? last7.map((day) => _buildDayPill(context, day, isDark)).toList()
                : _buildFallbackDays(context, isDark),
          ),

          // Broken Streak Alert & Retrieve Button
          if (provider.canRequestRecovery || provider.gapDays >= 2) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Missed ${provider.gapDays} days. Retrieve your streak!',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showRecoveryDialog(context, provider),
                    icon: const Icon(Icons.restore_rounded, size: 16),
                    label: const Text('Retrieve'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
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

  Widget _buildDayPill(BuildContext context, StreakDayItem day, bool isDark) {
    final isCompleted = day.completed;
    final isToday = day.isToday;

    return Column(
      children: [
        Text(
          day.dayName,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday
                ? Colors.deepOrange
                : (isDark ? Colors.white60 : const Color(0xFF6B7280)),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? Colors.deepOrange
                : (isToday
                    ? Colors.deepOrange.withValues(alpha: 0.15)
                    : (isDark
                        ? const Color(0xFF333333)
                        : const Color(0xFFE5E7EB))),
            border: Border.all(
              color: isToday ? Colors.deepOrange : Colors.transparent,
              width: 1.8,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : (isToday
                    ? const Icon(Icons.play_arrow_rounded,
                        color: Colors.deepOrange, size: 18)
                    : Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                      )),
          ),
        ),
        const SizedBox(height: 4),
        if (isToday)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'TODAY',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
          )
        else
          const SizedBox(height: 12),
      ],
    );
  }

  List<Widget> _buildFallbackDays(BuildContext context, bool isDark) {
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return dayNames.map((name) {
      return Column(
        children: [
          Text(name, style: const TextStyle(fontSize: 11)),
          const SizedBox(height: 6),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB),
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }).toList();
  }
}
