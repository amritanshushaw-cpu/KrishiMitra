import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../services/secure_db_service.dart';
import '../../state/farm_provider.dart';
import 'liquid_glass_container.dart';

class HistoricalAdvisoryCard extends StatefulWidget {
  const HistoricalAdvisoryCard({super.key});

  @override
  State<HistoricalAdvisoryCard> createState() => _HistoricalAdvisoryCardState();
}

class _HistoricalAdvisoryCardState extends State<HistoricalAdvisoryCard> {
  List<Map<String, dynamic>> _logs = [];
  bool _isLoading = true;
  Map<String, dynamic>? _selectedLog;

  @override
  void initState() {
    super.initState();
    _fetchLogs();
  }

    Future<void> _fetchLogs() async {
    final logs = await SecureDatabaseService.instance.getLogsForLastDays(7);
    if (mounted) {
      setState(() {
        _logs = logs;
        if (logs.isNotEmpty) {
          _selectedLog = logs.first;
        }
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.emeraldLight : AppTheme.forestGreen;

    // If no DB logs, fallback to provider's current scan if any
    final provider = context.watch<FarmProvider>();
    if (_logs.isEmpty && provider.fusedAdvisory == null) {
      return const SizedBox.shrink();
    }

    final hasDbLogs = _logs.isNotEmpty && _selectedLog != null;

    return LiquidGlassContainer(
      radius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Dropdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-Day Scan History',
                style: GoogleFonts.bricolageGrotesque(
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (hasDbLogs)
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Map<String, dynamic>>(
                      value: _selectedLog,
                      dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.white : Colors.black),
                      style: GoogleFonts.jetBrainsMono(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      items: _logs.map((log) {
                        final dt = DateTime.parse(log['timestamp']);
                        final formatted = DateFormat('MMM d, h:mm a').format(dt);
                        return DropdownMenuItem(
                          value: log,
                          child: Text('Scan #${log['id']} - $formatted'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLog = val);
                      },
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (!hasDbLogs && provider.fusedAdvisory != null)
            _buildCurrentFallback(context, provider, isDark, primaryColor)
          else if (hasDbLogs)
            _buildDbLogInterface(context, isDark, primaryColor),
        ],
      ),
    );
  }

  Widget _buildDbLogInterface(BuildContext context, bool isDark, Color primaryColor) {
    return Column(
      children: [
        // Telemetry Row
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric(Icons.thermostat, '${_selectedLog!['temperature']}°C', isDark),
              _buildMetric(Icons.water_drop, '${_selectedLog!['humidity']}%', isDark),
              _buildMetric(Icons.grass, '${_selectedLog!['soil_moisture']}%', isDark),
              _buildMetric(Icons.cloud, _selectedLog!['rain_detected'] == 1 ? 'Rain' : 'Dry', isDark),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Advisory Output
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.document_scanner, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedLog!['ai_diagnosis'] ?? 'Diagnosis',
                    style: GoogleFonts.bricolageGrotesque(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _selectedLog!['advisory_output'] ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurrentFallback(BuildContext context, FarmProvider provider, bool isDark, Color primaryColor) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.document_scanner, color: primaryColor),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.fusedAdvisory?.advisory.nameEn ?? 'Diagnosis Complete',
                style: GoogleFonts.bricolageGrotesque(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetric(IconData icon, String val, bool isDark) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.skyBlue, size: 22),
        const SizedBox(height: 4),
        Text(val, style: GoogleFonts.jetBrainsMono(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
