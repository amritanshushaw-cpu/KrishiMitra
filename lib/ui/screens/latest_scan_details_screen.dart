import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../../services/voice_tts_service.dart';
import '../../models/advisory_model.dart';

import '../widgets/liquid_glass_container.dart';

class LatestScanDetailsScreen extends StatelessWidget {
  const LatestScanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.emeraldLight : AppTheme.forestGreen;
    final provider = context.watch<FarmProvider>();
    final advisory = provider.fusedAdvisory;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppTheme.backgroundDecoration(isDark),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'LATEST SCAN OUTPUT',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: isDark ? AppTheme.emeraldLight : AppTheme.forestGreen,
            ),
          ),
          centerTitle: true,
        ),
        body: (advisory == null || provider.currentLeafBytes == null)
            ? Center(
                child: Text(
                  'No recent scan available.',
                  style: GoogleFonts.plusJakartaSans(
                    color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                  ),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Container
                    LiquidGlassContainer(
                      radius: 20,
                      padding: const EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(
                          provider.currentLeafBytes!,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // IoT Parameters List
                    Text(
                      'IOT SENSOR SNAPSHOT',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LiquidGlassContainer(
                      radius: 16,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSensorNode(
                            context,
                            icon: Icons.thermostat_outlined,
                            label: 'Temp',
                            value: '${provider.sensorData.temperature.toStringAsFixed(1)}°C',
                          ),
                          _buildSensorNode(
                            context,
                            icon: Icons.water_drop_outlined,
                            label: 'Humidity',
                            value: '${provider.sensorData.humidity}%',
                          ),
                          _buildSensorNode(
                            context,
                            icon: Icons.grass_outlined,
                            label: 'Soil',
                            value: '${provider.sensorData.soilMoisture}%',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Advisory Engine Output
                    Text(
                      'AI ADVISORY ENGINE OUTPUT',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LiquidGlassContainer(
                      radius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.health_and_safety_rounded, color: primaryColor, size: 24),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _getLocalizedTitle(provider, advisory.advisory),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (provider.isTtsPlaying) {
                                  provider.stopVoiceAdvisory();
                                } else {
                                  provider.playVoiceAdvisory();
                                }
                              },
                              icon: Icon(
                                provider.isTtsPlaying ? Icons.stop_circle_rounded : Icons.play_circle_fill_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                provider.isTtsPlaying 
                                    ? (provider.ttsLanguage == TtsLanguage.bengali ? 'অডিও থামান' : 'Stop Audio Advisory') 
                                    : (provider.ttsLanguage == TtsLanguage.bengali ? 'অডিও শুনুন' : 'Play Audio Advisory'),
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: provider.isTtsPlaying ? Colors.redAccent : primaryColor,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(context, provider.ttsLanguage == TtsLanguage.bengali ? 'লক্ষণ' : 'Symptoms', _getLocalizedSymptoms(provider, advisory.advisory)),
                          const SizedBox(height: 12),
                          _buildDetailRow(context, provider.ttsLanguage == TtsLanguage.bengali ? 'জৈব প্রতিকার' : 'Organic Treatment', _getLocalizedOrganic(provider, advisory.advisory)),
                          const SizedBox(height: 12),
                          _buildDetailRow(context, provider.ttsLanguage == TtsLanguage.bengali ? 'রাসায়নিক চিকিৎসা' : 'Chemical Strategy', _getLocalizedChemical(provider, advisory), highlight: advisory.isSprayOverrideActive,),
                          if (advisory.overrideReasonEn != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(context, provider.ttsLanguage == TtsLanguage.bengali ? 'সেন্সর সতর্কতা' : 'Sensor Override', _getLocalizedOverride(provider, advisory), highlight: true,),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      ),
    );
  }


  String _getLocalizedTitle(FarmProvider provider, AdvisoryModel advisory) {
    if (provider.ttsLanguage == TtsLanguage.bengali) return advisory.nameBn;
    // Fallback to English for Hindi text since we don't have Hindi text in DB yet, only TTS
    return advisory.nameEn;
  }

  String _getLocalizedSymptoms(FarmProvider provider, AdvisoryModel advisory) {
    if (provider.ttsLanguage == TtsLanguage.bengali) return advisory.symptomsBn;
    return advisory.symptomsEn;
  }

  String _getLocalizedOrganic(FarmProvider provider, AdvisoryModel advisory) {
    if (provider.ttsLanguage == TtsLanguage.bengali) return advisory.organicTreatmentBn;
    return advisory.organicTreatmentEn;
  }

  String _getLocalizedChemical(FarmProvider provider, var advisoryResult) {
    if (provider.ttsLanguage == TtsLanguage.bengali) return advisoryResult.effectiveChemicalTreatmentBn;
    if (provider.ttsLanguage == TtsLanguage.hindi && advisoryResult.effectiveChemicalTreatmentHi.isNotEmpty) return advisoryResult.effectiveChemicalTreatmentHi;
    return advisoryResult.effectiveChemicalTreatmentEn;
  }

  String _getLocalizedOverride(FarmProvider provider, var advisoryResult) {
    if (provider.ttsLanguage == TtsLanguage.bengali && advisoryResult.overrideReasonBn != null) return advisoryResult.overrideReasonBn!;
    if (provider.ttsLanguage == TtsLanguage.hindi && advisoryResult.overrideReasonHi != null) return advisoryResult.overrideReasonHi!;
    return advisoryResult.overrideReasonEn ?? '';
  }

  Widget _buildSensorNode(BuildContext context, {required IconData icon, required String label, required String value}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.emeraldLight : AppTheme.forestGreen;

    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String title, String body, {bool highlight = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: highlight ? AppTheme.amberWarning : (isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          body,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 1.5,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}
