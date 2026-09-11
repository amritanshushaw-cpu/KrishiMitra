import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import 'analytics_alerts_tab.dart';
import 'auth_screen.dart';
import 'home_dashboard_tab.dart';
import 'profile_settings_tab.dart';
import 'farm_tools_hub_screen.dart';
import 'history_log_tab.dart';
import 'scan_vision_tab.dart';
import 'sensors_iot_tab.dart';
import '../../models/parsed_diagnosis.dart';
import '../widgets/mesh_drift_background.dart';

class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  void _showNotificationsModal(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.deepPine : AppTheme.mintDew).withValues(alpha: isDark ? 0.90 : 0.94),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Text('Action Center', style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
                    const SizedBox(height: 16),
                    Expanded(
                      child: provider.notifications.isEmpty
                          ? Center(child: Text('No active notifications.', style: GoogleFonts.plusJakartaSans(color: Colors.grey)))
                          : ListView.builder(
                              itemCount: provider.notifications.length,
                              itemBuilder: (ctx, i) {
                                final n = provider.notifications[i];
                                return Card(
                                  color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.2),
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    title: Text(n.message, style: GoogleFonts.plusJakartaSans(color: isDark ? Colors.white : Colors.black, fontSize: 14)),
                                    subtitle: Text('Requires Action', style: GoogleFonts.jetBrainsMono(color: AppTheme.amberWarning, fontSize: 11)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check_circle_outline, color: AppTheme.emeraldLight),
                                          onPressed: () { provider.respondToNotification(n.id, true); Navigator.pop(ctx); },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                                          onPressed: () { provider.respondToNotification(n.id, false); Navigator.pop(ctx); },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }


  void _showSafetyNetModal(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark ? AppTheme.deepPine : AppTheme.mintDew).withValues(alpha: isDark ? 0.90 : 0.94),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppTheme.softSage.withValues(alpha: 0.3) : AppTheme.softSage.withValues(alpha: 0.45),
                    width: 1.2,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.strings.safetyNetTitle,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 18,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  provider.strings.safetyNetSub,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildDemoTile(
                  context: ctx,
                  code: 'SAMPLE_01',
                  title: 'Tomato // Late Blight (Fungus)',
                  subtitle: 'Triggers active rain spray suspension & pump interlock test',
                  accentColor: AppTheme.alertRose,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.triggerSafetyNetDemo(assetPath: AppConstants.demoLateBlightAsset);
                    provider.setTabIndex(1); // switch to scan tab
                  },
                ),
                const SizedBox(height: 8),
                _buildDemoTile(
                  context: ctx,
                  code: 'SAMPLE_02',
                  title: 'Potato // Healthy Foliage',
                  subtitle: 'Nominal baseline condition — zero chemical intervention required',
                  accentColor: AppTheme.emeraldLight,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.triggerSafetyNetDemo(assetPath: AppConstants.demoHealthyAsset);
                    provider.setTabIndex(1);
                  },
                ),
                const SizedBox(height: 8),
                _buildDemoTile(
                  context: ctx,
                  code: 'SAMPLE_03',
                  title: 'Paddy Rice // Leaf Blast',
                  subtitle: 'Magnaporthe oryzae pathogen analysis & bio-fungicide prescription',
                  accentColor: AppTheme.amberWarning,
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.triggerSafetyNetDemo(assetPath: AppConstants.demoRiceBlastAsset);
                    provider.setTabIndex(1);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
},
);
}

  List<Map<String, dynamic>> _getActiveAlerts(BuildContext context, FarmProvider provider) {
    final List<Map<String, dynamic>> alerts = [];

    // 1. Fused Advisory Alert
    final fused = provider.fusedAdvisory;
    if (fused != null) {
      alerts.add({
        'title': 'Agronomic Advisory Active',
        'time': 'Active Protocol',
        'severity': fused.recommendedPumpAction == 'LOCK' ? 'CRITICAL' : 'HIGH',
        'severityColor': fused.recommendedPumpAction == 'LOCK' ? AppTheme.alertRose : AppTheme.amberWarning,
        'action': fused.effectiveChemicalTreatmentEn.isNotEmpty
            ? fused.effectiveChemicalTreatmentEn
            : (fused.advisory.nameEn.isNotEmpty
                ? fused.advisory.nameEn
                : 'Foliar spray recommendation and irrigation lock active.'),
        'icon': Icons.medical_services_outlined,
        'onTap': () {
          Navigator.of(context, rootNavigator: true).pop();
          provider.setTabIndex(3);
        },
      });
    }

    // 2. Heavy Rainfall / Spray Paused
    if (provider.sensorData.isRaining) {
      alerts.add({
        'title': 'Precipitation Alert // Spray Paused',
        'time': 'Live Weather',
        'severity': 'WARNING',
        'severityColor': AppTheme.amberWarning,
        'action': 'Rain detected: Foliar chemical sprays suspended to prevent chemical runoff.',
        'icon': Icons.thunderstorm_outlined,
        'onTap': () {
          Navigator.of(context, rootNavigator: true).pop();
          provider.setTabIndex(2);
        },
      });
    }

    // 3. Soil Moisture Anomalies (Critically Dry or Saturated)
    if (provider.sensorData.isSoilCriticallyDry) {
      alerts.add({
        'title': 'Soil Drought Stress Warning',
        'time': 'Sensor Telemetry',
        'severity': 'CRITICAL',
        'severityColor': AppTheme.alertRose,
        'action': 'Soil moisture dropped to ${provider.sensorData.soilMoisture}%. Irrigation recommended.',
        'icon': Icons.water_drop_outlined,
        'onTap': () {
          Navigator.of(context, rootNavigator: true).pop();
          provider.setTabIndex(2);
        },
      });
    } else if (provider.sensorData.isSoilSaturated) {
      alerts.add({
        'title': 'Soil Saturation / Waterlogging',
        'time': 'Sensor Telemetry',
        'severity': 'WARNING',
        'severityColor': AppTheme.amberWarning,
        'action': 'Moisture high at ${provider.sensorData.soilMoisture}%. Inspect field drainage.',
        'icon': Icons.water_drop_outlined,
        'onTap': () {
          Navigator.of(context, rootNavigator: true).pop();
          provider.setTabIndex(2);
        },
      });
    }

    // 4. Crop Pathogen Detected via AI Camera
    if (provider.parsedDiagnosis != null &&
        (provider.parsedDiagnosis!.disease.status == ParameterStatus.critical ||
         provider.parsedDiagnosis!.disease.status == ParameterStatus.warning)) {
      final diseaseName = provider.parsedDiagnosis!.disease.value.isNotEmpty
          ? provider.parsedDiagnosis!.disease.value
          : "Pathogen Detected";
      final isCrit = provider.parsedDiagnosis!.disease.status == ParameterStatus.critical;
      alerts.add({
        'title': 'Pathogen Detected: $diseaseName',
        'time': 'Vision Scan',
        'severity': isCrit ? 'CRITICAL' : 'WARNING',
        'severityColor': isCrit ? AppTheme.alertRose : AppTheme.amberWarning,
        'action': 'Infection identified on crop foliage. Review recommended prescription.',
        'icon': Icons.coronavirus_outlined,
        'onTap': () {
          Navigator.of(context, rootNavigator: true).pop();
          provider.setTabIndex(1);
        },
      });
    }

    // 5. Irrigation Pump Locked
    if (provider.isPumpLocked) {
      alerts.add({
        'title': 'Irrigation Pump Locked',
        'time': 'Safety Interlock',
        'severity': 'INTERLOCKED',
        'severityColor': AppTheme.alertRose,
        'action': 'Pump safety relay engaged by ICAR agronomic rules.',
        'icon': Icons.lock_outline_rounded,
        'onTap': () {
          Navigator.of(context, rootNavigator: true).pop();
          provider.setTabIndex(2);
        },
      });
    }

    // 6. Atmospheric Heat Stress
    if (provider.sensorData.temperature > 40.0) {
      alerts.add({
        'title': 'High Heat Stress Alert',
        'time': 'Atmospheric',
        'severity': 'WARNING',
        'severityColor': AppTheme.amberWarning,
        'action': 'Ambient temperature ${provider.sensorData.temperature.toStringAsFixed(1)}°C exceeds threshold.',
        'icon': Icons.thermostat_outlined,
        'onTap': () {
          Navigator.of(context, rootNavigator: true).pop();
          provider.setTabIndex(2);
        },
      });
    }

    return alerts;
  }

  void _showNotificationAlertsModal(BuildContext context, FarmProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alerts = _getActiveAlerts(context, provider);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Notifications',
      barrierColor: Colors.black.withValues(alpha: 0.40),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (ctx, anim1, anim2) {
        final topPadding = MediaQuery.of(ctx).padding.top;

        return Material(
          type: MaterialType.transparency,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(
                top: topPadding + kToolbarHeight + 6,
                left: 16,
                right: 16,
              ),
              constraints: BoxConstraints(
                maxWidth: 440,
                maxHeight: MediaQuery.of(ctx).size.height * 0.70,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (isDark ? AppTheme.deepPine : AppTheme.mintDew)
                          .withValues(alpha: isDark ? 0.94 : 0.96),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (isDark ? AppTheme.softSage : AppTheme.forestGreen)
                            .withValues(alpha: isDark ? 0.35 : 0.25),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: (alerts.isNotEmpty
                                              ? (isDark ? AppTheme.amberWarning : AppTheme.forestGreen)
                                              : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen))
                                          .withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Icon(
                                      alerts.isNotEmpty
                                          ? Icons.notifications_active_rounded
                                          : Icons.notifications_none_rounded,
                                      color: alerts.isNotEmpty
                                          ? (isDark ? AppTheme.amberWarning : AppTheme.forestGreen)
                                          : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'FARM NOTIFICATIONS',
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.6,
                                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                        ),
                                      ),
                                      Text(
                                        alerts.isNotEmpty
                                            ? '${alerts.length} active event${alerts.length > 1 ? 's' : ''}'
                                            : 'System Status: Nominal',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                ),
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Content: Alerts list or clean Empty State
                          if (alerts.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen)
                                            .withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 24,
                                        color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No notifications right now',
                                      style: GoogleFonts.jetBrainsMono(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'All sensor streams, pest risks, and irrigation systems are operating normally.',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else ...[
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: alerts.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 8),
                                itemBuilder: (itemCtx, idx) {
                                  final a = alerts[idx];
                                  final Color sevColor = a['severityColor'] as Color;
                                  return InkWell(
                                    onTap: a['onTap'] as VoidCallback?,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.deepPine.withValues(alpha: 0.50)
                                            : AppTheme.pureWhite.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: sevColor.withValues(alpha: isDark ? 0.35 : 0.25),
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              color: sevColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(7),
                                            ),
                                            child: Icon(
                                              a['icon'] as IconData,
                                              size: 15,
                                              color: sevColor,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        a['title'] as String,
                                                        style: GoogleFonts.plusJakartaSans(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w700,
                                                          color: isDark
                                                              ? AppTheme.darkTextPrimary
                                                              : AppTheme.lightTextPrimary,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                      decoration: BoxDecoration(
                                                        color: sevColor.withValues(alpha: 0.15),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        a['severity'] as String,
                                                        style: GoogleFonts.jetBrainsMono(
                                                          fontSize: 8,
                                                          fontWeight: FontWeight.w700,
                                                          color: sevColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  a['action'] as String,
                                                  style: GoogleFonts.plusJakartaSans(
                                                    fontSize: 10.5,
                                                    color: isDark
                                                        ? AppTheme.darkTextMuted
                                                        : AppTheme.lightTextMuted,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Quick Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.analytics_outlined, size: 14),
                                    label: const Text('Advisory', style: TextStyle(fontSize: 11)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                                      side: BorderSide(
                                        color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.35),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      provider.setTabIndex(3);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.camera_enhance_outlined, size: 14),
                                    label: const Text('Scan Tab', style: TextStyle(fontSize: 11)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      provider.setTabIndex(1);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -0.04),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: curved,
            child: child,
          ),
        );
      },
    );
  }

  static Widget _buildDemoTile({
    required BuildContext context,
    required String code,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppTheme.deepPine.withValues(alpha: 0.50)
              : AppTheme.pureWhite.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppTheme.softSage.withValues(alpha: 0.20)
                : AppTheme.softSage.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                code,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> tabs = [
      HomeDashboardTab(onOpenSafetyNet: () => _showSafetyNetModal(context, provider)),
      ScanVisionTab(onOpenSafetyNet: () => _showSafetyNetModal(context, provider)),
      const SensorsIotTab(),
      const AnalyticsAlertsTab(),
      ProfileSettingsTab(onOpenSafetyNet: () => _showSafetyNetModal(context, provider)),
      const HistoryLogTab(),
      FarmToolsHubScreen(
        onBack: () {
          if (!provider.popTab()) {
            provider.setTabIndex(0);
          }
        },
      ),
    ];

    return PopScope(
      canPop: provider.activeTabIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (provider.activeTabIndex != 0) {
          if (!provider.popTab()) {
            provider.setTabIndex(0);
          }
        }
      },
      child: LayoutBuilder(
      builder: (context, constraints) {
        return MeshDriftBackground(
          isDark: isDark,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: (provider.activeTabIndex != 0 && provider.activeTabIndex != 6)
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: isDark ? AppTheme.darkTextPrimary : const Color(0xFF193E32),
                        size: 20,
                      ),
                      tooltip: 'Back to Farm Dashboard',
                      onPressed: () {
                        if (!provider.popTab()) {
                          provider.setTabIndex(0);
                        }
                      },
                    )
                  : null,
              titleSpacing: (provider.activeTabIndex != 0 && provider.activeTabIndex != 6) ? 0 : 16,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    provider.strings.authTitle,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          color: AppTheme.emeraldLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        provider.strings.offlineTag,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            actions: [
              // Notification / Action Center Trigger
              Builder(
                builder: (btnContext) {
                  final activeAlerts = _getActiveAlerts(context, provider);
                  final totalAlerts = provider.unreadNotificationCount + activeAlerts.length;

                  return IconButton(
                    icon: Badge(
                      isLabelVisible: totalAlerts > 0,
                      label: Text('$totalAlerts', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: provider.unreadNotificationCount > 0 ? AppTheme.alertRose : AppTheme.amberWarning,
                      child: Icon(
                        totalAlerts > 0
                            ? Icons.notifications_active_outlined
                            : Icons.notifications_none_rounded,
                        size: 22,
                        color: totalAlerts > 0
                            ? (isDark ? AppTheme.amberWarning : AppTheme.forestGreen)
                            : (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen),
                      ),
                    ),
                    tooltip: totalAlerts > 0
                        ? 'Notifications ($totalAlerts active)'
                        : 'Notifications (No new alerts)',
                    onPressed: () {
                      if (provider.unreadNotificationCount > 0) {
                        _showNotificationsModal(context, provider);
                      } else {
                        _showNotificationAlertsModal(context, provider);
                      }
                    },
                  );
                },
              ),
              // Theme switch
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  size: 20,
                  color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
                ),
                tooltip: 'Toggle Theme Mode',
                onPressed: () => provider.toggleTheme(),
              ),
              // Logout
              IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                ),
                tooltip: 'Logout',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                        backgroundColor: isDark ? AppTheme.deepPine : AppTheme.mintDew,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text(
                          'Confirm Logout',
                          style: GoogleFonts.jetBrainsMono(
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        content: Text(
                          'Are you sure you want to logout?',
                          style: GoogleFonts.plusJakartaSans(
                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                            fontSize: 14,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.plusJakartaSans(
                                color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
                            },
                            child: Text(
                              'Logout',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.amberWarning,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: IndexedStack(
            index: provider.activeTabIndex,
            children: tabs,
          ),
          bottomNavigationBar: Container(
            color: Colors.transparent,
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 4
                  : 12,
              top: 2,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: (isDark ? const Color(0xFF0C1914) : const Color(0xFFEDF8F1))
                        .withValues(alpha: isDark ? 0.82 : 0.92),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.emeraldLight.withValues(alpha: 0.20)
                          : AppTheme.forestGreen.withValues(alpha: 0.15),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.40) : AppTheme.deepPine.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                      if (isDark)
                        BoxShadow(
                          color: AppTheme.emeraldLight.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -1),
                        ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(
                        context: context,
                        index: 0,
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                        label: provider.strings.navHome,
                        isSelected: provider.activeTabIndex == 0,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          provider.setTabIndex(0);
                        },
                      ),
                      _buildNavItem(
                        context: context,
                        index: 6,
                        icon: Icons.calculate_outlined,
                        selectedIcon: Icons.calculate_rounded,
                        label: 'Calculators',
                        isSelected: provider.activeTabIndex == 6,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          provider.setTabIndex(6);
                        },
                      ),
                      _buildNavItem(
                        context: context,
                        index: 5,
                        icon: Icons.history_outlined,
                        selectedIcon: Icons.history_rounded,
                        label: provider.strings.navHistory,
                        isSelected: provider.activeTabIndex == 5,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          provider.setTabIndex(5);
                        },
                      ),
                      _buildNavItem(
                        context: context,
                        index: 4,
                        icon: Icons.person_outline_rounded,
                        selectedIcon: Icons.person_rounded,
                        label: provider.strings.navProfile,
                        isSelected: provider.activeTabIndex == 4,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          provider.setTabIndex(4);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.emeraldLight : AppTheme.forestGreen;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? AppTheme.emeraldLight.withValues(alpha: 0.12)
                    : AppTheme.forestGreen.withValues(alpha: 0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: isSelected
                ? Border.all(
                    color: (isDark ? AppTheme.emeraldLight : AppTheme.forestGreen).withValues(alpha: 0.22),
                    width: 1,
                  )
                : Border.all(color: Colors.transparent, width: 1),
          ),
          child: AnimatedScale(
            scale: isSelected ? 1.05 : 0.96,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey<bool>(isSelected),
                    color: isSelected
                        ? primaryColor
                        : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                    size: 20,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: isSelected ? 0.3 : 0.1,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
                  ),
                  child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: isSelected ? 12 : 0,
                  height: 2.5,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.6),
                              blurRadius: 4,
                              spreadRadius: 0.5,
                            )
                          ]
                        : [],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
