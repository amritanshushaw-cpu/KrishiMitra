import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import 'app_glass_container.dart';

class FieldZoneCard extends StatelessWidget {
  final String zoneName;
  final String cropType;
  final String plantingDate;
  final String harvestDate;
  final int healthScore;
  final VoidCallback? onTap;

  const FieldZoneCard({
    super.key,
    this.zoneName = 'Area 1: Rice & Tomato Block',
    this.cropType = 'Solanum lycopersicum & Oryza sativa',
    this.plantingDate = '24 Aug 2025',
    this.harvestDate = '12 Dec 2025',
    this.healthScore = 92,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppGlassContainer(
      radius: 18,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.map_outlined,
                      size: 16,
                      color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zoneName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                      Text(
                        cropType,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$healthScore% HEALTH',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.slatePine.withValues(alpha: 0.40) : AppTheme.mintDew.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppTheme.softSage.withValues(alpha: 0.15) : AppTheme.softSage.withValues(alpha: 0.30),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimelineItem(
                  title: 'Planting Date',
                  date: plantingDate,
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                ),
                _buildTimelineItem(
                  title: 'Expected Harvest',
                  date: harvestDate,
                  isDark: isDark,
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                ),
                _buildTimelineItem(
                  title: 'Irrigation State',
                  date: 'Scheduled 6 AM',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 9.5,
            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          date,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
