import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/voice_tts_service.dart';
import '../../state/farm_provider.dart';
import '../widgets/app_glass_container.dart';
import 'auth_screen.dart';

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
              const SizedBox(height: 14),

              // Farmer Profile Card
              AppGlassContainer(
                radius: 18,
                hasGoldGlow: true,
                padding: const EdgeInsets.all(16),
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
                            provider.farmerName,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                          if (provider.farmerMobile.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              '+91 ${provider.farmerMobile}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Farm Location & Geolocation Settings
              Text(
                'FARM LOCATION & GPS SYNCHRONIZATION',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                ),
              ),
              const SizedBox(height: 8),
              AppGlassContainer(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'EDGE GEOLOCATION // FARM PLOT',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (provider.isFetchingLocation)
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                            ),
                          )
                        else
                          _buildBadge(context, 'AUTO-DETECTED', isDark),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      provider.farmerLocation,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                    if (provider.coordinatesDisplay.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        'GPS Coordinates: ${provider.coordinatesDisplay}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: provider.isFetchingLocation
                                ? null
                                : () async {
                                    await provider.autoFetchLocation();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Farm location precisely synced: ${provider.farmerLocation}'),
                                          backgroundColor: AppTheme.forestGreen,
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.my_location_rounded, size: 16),
                            label: Text(
                              provider.isFetchingLocation ? 'FETCHING LOCATION...' : 'AUTO-FETCH LOCATION',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                              foregroundColor: isDark ? Colors.black : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () => _editLocationDialog(context, provider),
                          icon: const Icon(Icons.edit_location_alt_outlined, size: 16),
                          label: Text(
                            'CUSTOM',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                            side: BorderSide(
                              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
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
              AppGlassContainer(
                radius: 12,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<TtsLanguage>(
                    value: provider.ttsLanguage,
                    isExpanded: true,
                    dropdownColor: isDark ? AppTheme.darkCard : AppTheme.ivoryCanvas,
                    icon: Icon(Icons.language_outlined, color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen),
                    items: [
                      DropdownMenuItem(
                        value: TtsLanguage.bengali,
                        child: Text(
                          'Bengali',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: TtsLanguage.hindi,
                        child: Text(
                          'Hindi',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: TtsLanguage.english,
                        child: Text(
                          'English',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.setTtsLanguage(val);
                    },
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
              AppGlassContainer(
                radius: 16,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            child: Text(
                              isDark ? provider.strings.darkMode : provider.strings.lightMode,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: provider.isDarkMode,
                      activeThumbColor: AppTheme.emeraldLight,
                      onChanged: (_) => provider.toggleTheme(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(context, provider),
                  icon: const Icon(Icons.logout_rounded, size: 16, color: AppTheme.alertRose),
                  label: Text(
                    'LOG OUT SESSION',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.alertRose,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.alertRose,
                    side: const BorderSide(color: AppTheme.alertRose, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(BuildContext context, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
        ),
      ),
    );
  }

  Future<void> _editLocationDialog(BuildContext context, FarmProvider provider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = TextEditingController(text: provider.farmerLocation);

    final newLoc = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.deepPine : AppTheme.mintDew,
        title: Text(
          'Custom Plot Location',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
            fontSize: 18,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. Bardhaman, West Bengal',
            hintStyle: TextStyle(color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newLoc != null && newLoc.trim().isNotEmpty) {
      provider.setFarmerLocation(newLoc);
    }
  }

  Future<void> _confirmLogout(BuildContext context, FarmProvider provider) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppTheme.deepPine : AppTheme.mintDew,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark
                ? AppTheme.softSage.withValues(alpha: 0.25)
                : AppTheme.softSage.withValues(alpha: 0.40),
          ),
        ),
        title: Row(
          children: [
            const Icon(Icons.logout_rounded, color: AppTheme.alertRose, size: 20),
            const SizedBox(width: 8),
            Text(
              'Confirm Log Out',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to end the session for ${provider.farmerName}?',
          style: GoogleFonts.plusJakartaSans(
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.jetBrainsMono(
                color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.alertRose,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      provider.logout();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }
}
