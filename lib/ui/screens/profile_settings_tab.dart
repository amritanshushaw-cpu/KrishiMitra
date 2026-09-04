import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/voice_tts_service.dart';
import '../../state/farm_provider.dart';

class ProfileSettingsTab extends StatelessWidget {
  final VoidCallback onOpenSafetyNet;

  const ProfileSettingsTab({super.key, required this.onOpenSafetyNet});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Farmer Profile & Settings',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Personalization, Vernacular Audio & Edge Offline Configuration',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 14),

              // Farmer Profile Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.agriculture_outlined,
                        size: 28,
                        color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saptak (Farmer / Operator)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Bardhaman, West Bengal • 3.5 Acres Plot',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              _buildBadge(context, 'CROP: TOMATO & RICE'),
                              const SizedBox(width: 6),
                              _buildBadge(context, 'ICAR REGISTERED'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Vernacular Audio Language Selector
              Text(
                provider.strings.languageSettings,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 8),
              Material(
                color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                  children: [
                    _buildLanguageTile(
                      context,
                      title: 'বাংলা (Bengali - Regional Default)',
                      subtitle: 'Native voice advisory for West Bengal / Bangladesh',
                      isSelected: provider.ttsLanguage == TtsLanguage.bengali,
                      onTap: () => provider.setTtsLanguage(TtsLanguage.bengali),
                    ),
                    const Divider(height: 1),
                    _buildLanguageTile(
                      context,
                      title: 'हिन्दी (Hindi)',
                      subtitle: 'Hindi agricultural voice synthesis',
                      isSelected: provider.ttsLanguage == TtsLanguage.hindi,
                      onTap: () => provider.setTtsLanguage(TtsLanguage.hindi),
                    ),
                    const Divider(height: 1),
                    _buildLanguageTile(
                      context,
                      title: 'English (US / Global)',
                      subtitle: 'Standard technical agronomic English',
                      isSelected: provider.ttsLanguage == TtsLanguage.english,
                      onTap: () => provider.setTtsLanguage(TtsLanguage.english),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

              // Theme Mode Toggle (Light vs Dark)
              Text(
                provider.strings.appearanceTheme,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                            color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDark ? provider.strings.darkMode : provider.strings.lightMode,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isDark
                                      ? 'High contrast dark palette for night operation'
                                      : 'Warm ivory & forest green SaaS palette',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11.5,
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
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
                    Switch(
                      value: provider.isDarkMode,
                      activeColor: AppTheme.emeraldLight,
                      onChanged: (_) => provider.toggleTheme(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Demonstration & Hardware Bypass Utility
              Text(
                'DEMONSTRATION & PITCH UTILITY',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.pureWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                    width: 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'HARDWARE BYPASS // PITCH SAFETY NET',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Instantly inject high-resolution sample leaf images (Tomato Late Blight, Potato Healthy, Rice Blast) to test offline edge inference and vernacular voice playback.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onOpenSafetyNet,
                        icon: const Icon(Icons.play_arrow_outlined, size: 16),
                        label: const Text('OPEN PITCH SAFETY NET MODAL'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.emeraldLight : AppTheme.forestGreen;

    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected
              ? primaryColor
              : (isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11.5,
          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: primaryColor, size: 20)
          : null,
    );
  }

  Widget _buildBadge(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
        ),
      ),
    );
  }
}
