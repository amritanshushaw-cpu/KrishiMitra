import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class PumpControlToggle extends StatelessWidget {
  final bool isLocked;
  final String? autoReason;
  final VoidCallback onToggle;

  const PumpControlToggle({
    super.key,
    required this.isLocked,
    this.autoReason,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color stateColor = isLocked
        ? AppTheme.alertRose
        : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked
              ? AppTheme.alertRose.withValues(alpha: 0.5)
              : (isDark ? AppTheme.darkBorder : AppTheme.sageBorder),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0xFF1B4D3E).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: stateColor.withValues(alpha: 0.3), width: 1.0),
            ),
            child: Icon(
              isLocked ? Icons.lock_outline : Icons.water_drop_outlined,
              color: stateColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'RELAY_CH_01 // IRRIGATION PUMP',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: stateColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: stateColor.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: Text(
                        isLocked ? 'HALTED' : 'READY',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          color: stateColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isLocked
                      ? (autoReason ?? 'Relay locked by sensor-fusion interlock')
                      : 'Relay operational — smart schedule active',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onToggle,
            style: OutlinedButton.styleFrom(
              foregroundColor: stateColor,
              side: BorderSide(
                color: stateColor.withValues(alpha: 0.5),
                width: 1.0,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(76, 34),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              isLocked ? 'UNLOCK' : 'LOCK',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
