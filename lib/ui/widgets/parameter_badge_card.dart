import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../models/parsed_diagnosis.dart';

class ParameterBadgeCard extends StatelessWidget {
  final ParameterItem parameter;

  const ParameterBadgeCard({super.key, required this.parameter});

  Color _getStatusColor(bool isDark) {
    switch (parameter.status) {
      case ParameterStatus.optimal:
        return isDark ? AppTheme.emeraldLight : AppTheme.sproutGreen;
      case ParameterStatus.warning:
        return AppTheme.amberWarning;
      case ParameterStatus.critical:
        return AppTheme.alertRose;
      case ParameterStatus.info:
        return isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;
    }
  }

  Color _getStatusBg(bool isDark) {
    switch (parameter.status) {
      case ParameterStatus.optimal:
        return (isDark ? AppTheme.emeraldLight : AppTheme.sproutGreen).withValues(alpha: 0.12);
      case ParameterStatus.warning:
        return AppTheme.amberWarningSoft;
      case ParameterStatus.critical:
        return AppTheme.alertRoseSoft;
      case ParameterStatus.info:
        return isDark ? const Color(0x1F6B8273) : const Color(0x1F7D9284);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(isDark);
    final statusBg = _getStatusBg(isDark);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0xFF1B4D3E).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: statusColor.withValues(alpha: 0.25), width: 1.0),
            ),
            child: Center(
              child: Icon(
                parameter.icon,
                color: statusColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        parameter.title.toUpperCase(),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 0.8),
                      ),
                      child: Text(
                        parameter.status.name.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  parameter.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  parameter.bengaliValue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
