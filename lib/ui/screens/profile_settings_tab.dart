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
                            '${provider.farmerName} (Farmer / Operator)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  '${provider.farmerLocation} • 3.5 Acres Plot',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (provider.isFetchingLocation) ...[
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.5,
                                    color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              _buildBadge(context, 'CROP: TOMATO & RICE'),
                              _buildBadge(context, 'ICAR REGISTERED'),
                              if (provider.coordinatesDisplay.isNotEmpty)
                                _buildBadge(context, 'GPS: ${provider.coordinatesDisplay}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: 'Log Out',
                      child: InkWell(
                        onTap: () => _confirmLogout(context, provider),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.alertRose.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.alertRose.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: AppTheme.alertRose,
                          ),
                        ),
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
              AppGlassContainer(
                radius: 16,
                child: Column(
                  children: [
                    _buildLanguageTile(
                      context,
                      title: 'বাংলা (Bengali - Regional Default)',
                      subtitle: 'Native voice advisory for West Bengal / Bangladesh',
                      isSelected: provider.ttsLanguage == TtsLanguage.bengali,
                      onTap: () => provider.setTtsLanguage(TtsLanguage.bengali),
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppTheme.softSage.withValues(alpha: 0.15)
                          : AppTheme.softSage.withValues(alpha: 0.25),
                    ),
                    _buildLanguageTile(
                      context,
                      title: 'हिन्दी (Hindi)',
                      subtitle: 'Hindi agricultural voice synthesis',
                      isSelected: provider.ttsLanguage == TtsLanguage.hindi,
                      onTap: () => provider.setTtsLanguage(TtsLanguage.hindi),
                    ),
                    Divider(
                      height: 1,
                      color: isDark
                          ? AppTheme.softSage.withValues(alpha: 0.15)
                          : AppTheme.softSage.withValues(alpha: 0.25),
                    ),
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
                      activeThumbColor: AppTheme.emeraldLight,
                      onChanged: (_) => provider.toggleTheme(),
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
                          _buildBadge(context, 'AUTO-DETECTED'),
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
                                          content: Text('Farm location updated: ${provider.farmerLocation}'),
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
              AppGlassContainer(
                radius: 16,
                padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 16),

              // Security & Log Out Section
              AppGlassContainer(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.security_outlined,
                          color: AppTheme.alertRose,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'SECURITY & OPERATOR SESSION',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.alertRose,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'End active edge session for ${provider.farmerName} and securely lock local SQLCipher farm logs.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmLogout(context, provider),
                        icon: const Icon(Icons.logout_rounded, size: 16, color: AppTheme.alertRose),
                        label: Text(
                          'LOG OUT // END SESSION (${provider.farmerName.toUpperCase()})',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.alertRose,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.alertRose,
                          side: const BorderSide(color: AppTheme.alertRose, width: 1.2),
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
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of KrishiMitra? You will need to sign in again to access the farm cockpit and offline edge diagnostics.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.alertRose,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Log Out',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await provider.logout();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully. Secure vault locked.'),
          ),
        );
      }
    }
  }

  Future<void> _editLocationDialog(BuildContext context, FarmProvider provider) async {
    final controller = TextEditingController(text: provider.farmerLocation);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.emeraldLight : AppTheme.forestGreen;

    final updated = await showDialog<String>(
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
            Icon(Icons.edit_location_alt_outlined, color: primaryColor, size: 20),
            const SizedBox(width: 8),
            Text(
              'Custom Farm Location',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Village / District / State',
            hintText: 'e.g. Bardhaman, West Bengal',
            filled: true,
            fillColor: isDark ? AppTheme.slatePine.withValues(alpha: 0.5) : AppTheme.pureWhite.withValues(alpha: 0.7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? Colors.black : Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated != null && updated.isNotEmpty) {
      provider.setFarmerLocation(updated);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Farm plot location set to: $updated'),
            backgroundColor: AppTheme.forestGreen,
          ),
        );
      }
    }
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
