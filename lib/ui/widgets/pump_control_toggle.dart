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

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isLocked
              ? AppTheme.alertRose.withValues(alpha: 0.4)
              : (isDark ? AppTheme.darkBorder : AppTheme.sageBorder),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0x0C1A3E31),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isLocked ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5EE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isLocked ? Icons.lock_rounded : Icons.water_drop_rounded,
              color: isLocked ? AppTheme.alertRose : const Color(0xFF193E32),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Smart Irrigation Pump',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isLocked ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5EE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isLocked ? 'HALTED' : 'READY',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isLocked ? AppTheme.alertRose : const Color(0xFF193E32),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  isLocked
                      ? (autoReason ?? 'Locked: Blight mitigation')
                      : 'Relay operational • Smart schedule',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    color: isDark ? AppTheme.darkTextMuted : const Color(0xFF52796F),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isLocked
                      ? AppTheme.alertRose
                      : const Color(0xFF193E32),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isLocked ? 'Unlock' : 'Lock',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
