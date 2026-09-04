import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      text: "Yes, very clear. What about energy consumption for all this AI?",
      isUser: true,
    ),
    _ChatMessage(
      text: "Our edge models run at 45mW on the smartphone NPU with 0 cloud calls, saving 98% carbon overhead vs remote servers.",
      isUser: false,
    ),
    _ChatMessage(
      text: "How does this compare to organic farming methods?",
      isUser: true,
    ),
    _ChatMessage(
      text: "What are the main challenges in deploying such systems?",
      isUser: true,
    ),
    _ChatMessage(
      text: "Can AI help with carbon sequestration?",
      isUser: true,
    ),
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), isUser: true));
      _textController.clear();
    });

    // Auto reply after short edge delay
    Future.delayed(const Duration(milliseconds: 600), () {
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
    _scrollToBottom();
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
    final cardBg = isDark ? const Color(0xFF161C18) : Colors.white;
    final borderColor = isDark ? const Color(0xFF263229) : const Color(0xFFE8EBE3);
    final textMuted = isDark ? const Color(0xFF8FA395) : const Color(0xFF7A8B7E);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
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
                  color: Color(0xFF52B788),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Research AI Stream',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF19241B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF202A22) : const Color(0xFFEFF3EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Edge-LLM Active',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF52B788),
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
                          ? (isDark ? const Color(0xFF1F2B23) : const Color(0xFFF3F5EF))
                          : (isDark ? const Color(0xFF1B3828) : const Color(0xFFE8F5E9)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: msg.isUser
                            ? borderColor
                            : const Color(0xFF52B788).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      msg.text,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        height: 1.4,
                        color: isDark ? Colors.white70 : const Color(0xFF28362A),
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
              color: isDark ? const Color(0xFF1A221C) : const Color(0xFFF6F8F4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
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
                      color: isDark ? Colors.white : const Color(0xFF19241B),
                    ),
                    decoration: InputDecoration(
                      hintText: "How can I improve my field's yield?",
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: textMuted.withOpacity(0.8),
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
                      color: Color(0xFF52B788),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_upward, size: 14, color: Colors.white),
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

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
