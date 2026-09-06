import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class ResearchHubChatPanel extends StatefulWidget {
  const ResearchHubChatPanel({super.key});

  @override
  State<ResearchHubChatPanel> createState() => _ResearchHubChatPanelState();
}

class _ResearchHubChatPanelState extends State<ResearchHubChatPanel> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: "Field Status: Sensor node B-42 indicates low moisture near root zones. Recommend 12-minute drip burst.",
      isUser: false,
    ),
    _ChatMessage(
      text: "Schedule irrigation now and log SOC delta.",
      isUser: true,
    ),
    _ChatMessage(
      text: "Executing autonomous irrigation via ESP32 BLE mesh. Hydro-telemetry will log at 12:00:00 UTC.",
      isUser: false,
    ),
  ];

  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: trimmed, isUser: true));
      _textController.clear();
    });
    _scrollToBottom();

    // Simulated edge response
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          _ChatMessage(
            text: "Soil carbon levels in Zone 3B indicate +0.18% SOC gain under zero-tillage and targeted bio-fertilizer schedule.",
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary;
    final textMuted = isDark ? AppTheme.darkTextSecondary : AppTheme.lightTextSecondary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: AppTheme.glassCardDecoration(isDark: isDark, radius: 24),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with AI Icon
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppTheme.forestMoss,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppTheme.mintDew,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Research AI Stream',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.slatePine.withValues(alpha: 0.6) : AppTheme.mintDew.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (isDark ? AppTheme.softSage : AppTheme.forestMoss).withValues(alpha: 0.25),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Edge-LLM Active',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.softSage : AppTheme.forestMoss,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Message Stream
              Expanded(
                child: ListView.separated(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Align(
                      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: msg.isUser
                              ? (isDark ? AppTheme.slatePine.withValues(alpha: 0.75) : AppTheme.mintDew.withValues(alpha: 0.85))
                              : (isDark ? AppTheme.deepPine.withValues(alpha: 0.90) : Colors.white.withValues(alpha: 0.90)),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: msg.isUser
                                ? AppTheme.softSage.withValues(alpha: 0.3)
                                : AppTheme.softSage.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          msg.text,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            height: 1.4,
                            color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Input Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.slatePine.withValues(alpha: 0.5) : AppTheme.mintDew.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isDark ? AppTheme.softSage : Colors.white).withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18, color: textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: _sendMessage,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: "How can I improve my field's yield?",
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            color: textMuted.withValues(alpha: 0.8),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _sendMessage(_textController.text),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.forestMoss,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward, size: 14, color: AppTheme.mintDew),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
