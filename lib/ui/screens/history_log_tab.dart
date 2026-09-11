import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../state/farm_provider.dart';
import '../../services/secure_db_service.dart';

class HistoryLogTab extends StatelessWidget {
  const HistoryLogTab({super.key});

  Future<void> _downloadHistory(BuildContext context, int days) async {
    try {
      final logs = await SecureDatabaseService.instance.getLogsForLastDays(days);
      if (logs.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No data found for the selected period.')));
        }
        return;
      }

      final directory = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final fileName = 'KrishiMitra_Logs_${days}_Days.txt';
      final file = File('${directory.path}/$fileName');

      final buffer = StringBuffer();
      buffer.writeln('KrishiMitra AI - Farm Logs (Last $days days)');
      buffer.writeln('Generated: ${DateTime.now().toString()}');
      buffer.writeln('-' * 40);
      
      for (var log in logs) {
        buffer.writeln('Date/Time: ${log['timestamp']}');
        buffer.writeln('Temp: ${log['temperature']} °C, Humidity: ${log['humidity']}%, Soil Moisture: ${log['soil_moisture']}');
        buffer.writeln('Advice: ${log['advisory_output']}');
        buffer.writeln('-' * 40);
      }

      await file.writeAsString(buffer.toString());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Downloaded successfully to:\n${file.path}'),
          duration: const Duration(seconds: 4),
          backgroundColor: AppTheme.forestMoss,
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to download: $e')));
      }
    }
  }

  void _showDownloadOptions(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.darkCard : AppTheme.ivoryCanvas,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  context.read<FarmProvider>().strings.selectDuration,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                  ),
                ),
              ),
              const Divider(),
              ...List.generate(7, (index) {
                final days = index + 1;
                return ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: Text('Last $days ${days == 1 ? 'Day' : 'Days'}'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _downloadHistory(context, days);
                  },
                );
              }),
            ],
          ),
        );
      }
    );
  }

  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return '--';
    }
  }

  String _formatTime(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('HH:mm:ss').format(date);
    } catch (e) {
      return '--';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<FarmProvider>();
    final primaryColor = isDark ? AppTheme.softSage : AppTheme.forestMoss;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.read<FarmProvider>().strings.historyTitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.read<FarmProvider>().strings.historyDesc,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkCard : AppTheme.ivoryCanvas,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? AppTheme.softSage : AppTheme.forestMoss).withValues(alpha: 0.15),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FutureBuilder<List<Map<String, dynamic>>>(
                    future: SecureDatabaseService.instance.getHistoryLogs(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error loading history: ${snapshot.error}'));
                      }
                      
                      final logs = snapshot.data ?? [];

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DataTable(
                                headingRowColor: WidgetStateProperty.all(
                                  (isDark ? AppTheme.deepPine : AppTheme.mintDew).withValues(alpha: 0.5),
                                ),
                                columns: [
                                  DataColumn(label: Text(provider.strings.colDate, style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text(provider.strings.colTime, style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text(provider.strings.colTemp, style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text(provider.strings.colHumidity, style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text(provider.strings.colSoil, style: TextStyle(fontWeight: FontWeight.bold))),
                                  DataColumn(label: Text(provider.strings.colAdvice, style: TextStyle(fontWeight: FontWeight.bold))),
                                ],
                                rows: logs.map((log) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(_formatDate(log['timestamp'] ?? ''))),
                                      DataCell(Text(_formatTime(log['timestamp'] ?? ''))),
                                      DataCell(Text(log['temperature']?.toString() ?? '--')),
                                      DataCell(Text(log['humidity']?.toString() ?? '--')),
                                      DataCell(Text(log['soil_moisture']?.toString() ?? '--')),
                                      DataCell(
                                        SizedBox(
                                          width: 200,
                                          child: Text(
                                            log['advisory_output'] ?? '--',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                              if (logs.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Text(
                                      provider.strings.noLogsYet,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _showDownloadOptions(context, isDark),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                      ? [AppTheme.emeraldLight.withValues(alpha: 0.2), AppTheme.deepPine.withValues(alpha: 0.4)]
                      : [AppTheme.mintDew, AppTheme.forestMoss.withValues(alpha: 0.1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? AppTheme.emeraldLight : AppTheme.forestMoss).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.file_download_outlined,
                      color: isDark ? AppTheme.emeraldLight : AppTheme.forestMoss,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      provider.strings.downloadHistoryBtn,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppTheme.emeraldLight : AppTheme.forestMoss,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
