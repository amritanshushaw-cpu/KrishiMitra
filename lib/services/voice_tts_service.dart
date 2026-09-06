import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsLanguage { bengali, hindi, english }

class VoiceTtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  TtsLanguage _currentLanguage = TtsLanguage.bengali;
  bool _isBengaliAvailable = false;
  ValueChanged<bool>? onPlayingStateChanged;
  ValueChanged<String>? onError;

  bool get isPlaying => _isPlaying;
  TtsLanguage get currentLanguage => _currentLanguage;
  bool get isBengaliAvailable => _isBengaliAvailable;

  Future<void> initialize() async {
    try {
      await _flutterTts.awaitSpeakCompletion(true);
      final double naturalRate = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ? 0.85 : 0.48;
      await _flutterTts.setSpeechRate(naturalRate);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // On Android: Prefer Google Speech Engine for reliable Indian vernacular support
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        try {
          final dynamic engines = await _flutterTts.getEngines;
          if (engines is List && engines.contains('com.google.android.tts')) {
            await _flutterTts.setEngine('com.google.android.tts');
          }
        } catch (_) {}
      }

      // On iOS: Configure AVAudioSession category for crisp speaker playback
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        try {
          await _flutterTts.setSharedInstance(true);
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
            ],
            IosTextToSpeechAudioMode.defaultMode,
          );
        } catch (_) {}
      }

      _flutterTts.setStartHandler(() {
        _isPlaying = true;
        onPlayingStateChanged?.call(true);
      });

      _flutterTts.setCompletionHandler(() {
        _isPlaying = false;
        onPlayingStateChanged?.call(false);
      });

      _flutterTts.setCancelHandler(() {
        _isPlaying = false;
        onPlayingStateChanged?.call(false);
      });

      _flutterTts.setErrorHandler((msg) {
        _isPlaying = false;
        onPlayingStateChanged?.call(false);
        onError?.call(msg.toString());
        debugPrint('VoiceTtsService engine error: $msg');
      });

      await setLanguage(TtsLanguage.bengali);
    } catch (e) {
      debugPrint('VoiceTtsService initialize exception: $e');
    }
  }

  Future<void> setLanguage(TtsLanguage lang) async {
    _currentLanguage = lang;
    switch (lang) {
      case TtsLanguage.bengali:
        await _setupBengaliVoice();
        break;
      case TtsLanguage.hindi:
        await _setupHindiVoice();
        break;
      case TtsLanguage.english:
        await _setupEnglishVoice();
        break;
    }
  }

  /// Deep search for Bengali voice & locale support across OS engines
  Future<void> _setupBengaliVoice() async {
    try {
      final double naturalRate = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ? 0.85 : 0.48;
      await _flutterTts.setSpeechRate(naturalRate);
      await _flutterTts.setPitch(1.0);

      // 1. Check available voices and bind explicitly
      final dynamic voices = await _flutterTts.getVoices;
      if (voices is List && voices.isNotEmpty) {
        dynamic selectedVoice;

        // Preference A: Bengali (India)
        for (final v in voices) {
          if (v is Map) {
            final locale = (v['locale'] ?? v['lang'] ?? '').toString().toLowerCase().replaceAll('_', '-');
            final name = (v['name'] ?? '').toString().toLowerCase();
            if (locale == 'bn-in' || locale.startsWith('bn-in') || name.contains('bn-in') || (locale.startsWith('bn') && name.contains('india'))) {
              selectedVoice = v;
              break;
            }
          }
        }

        // Preference B: Any Bengali voice (Bangladesh, generic bn)
        if (selectedVoice == null) {
          for (final v in voices) {
            if (v is Map) {
              final locale = (v['locale'] ?? v['lang'] ?? '').toString().toLowerCase().replaceAll('_', '-');
              final name = (v['name'] ?? '').toString().toLowerCase();
              if (locale.startsWith('bn') || locale.startsWith('ben') || name.contains('bengali') || name.contains('bangla')) {
                selectedVoice = v;
                break;
              }
            }
          }
        }

        if (selectedVoice != null && selectedVoice is Map) {
          final voiceMap = Map<String, String>.from(
            selectedVoice.map((k, val) => MapEntry(k.toString(), val.toString())),
          );
          await _flutterTts.setVoice(voiceMap);
          final loc = voiceMap['locale'] ?? voiceMap['lang'] ?? 'bn-IN';
          await _flutterTts.setLanguage(loc);
          _isBengaliAvailable = true;
          return;
        }
      }

      // 2. Query available languages
      final dynamic languages = await _flutterTts.getLanguages;
      if (languages is List && languages.isNotEmpty) {
        final lowerLangs = languages.map((e) => e.toString().toLowerCase().replaceAll('_', '-')).toList();
        for (final code in ['bn-in', 'bn_in', 'bn-bd', 'bn_bd', 'bn', 'ben-ind', 'ben']) {
          if (lowerLangs.contains(code.toLowerCase().replaceAll('_', '-'))) {
            await _flutterTts.setLanguage(code);
            _isBengaliAvailable = true;
            return;
          }
        }
      }

      // 3. Probe language availability directly
      for (final code in ['bn-IN', 'bn_IN', 'bn-BD', 'bn_BD', 'bn']) {
        final dynamic available = await _flutterTts.isLanguageAvailable(code);
        if (available == true || available == 1) {
          await _flutterTts.setLanguage(code);
          _isBengaliAvailable = true;
          return;
        }
      }

      // 4. Default fallback code
      await _flutterTts.setLanguage('bn-IN');
      _isBengaliAvailable = true;
    } catch (e) {
      debugPrint('Bengali voice configuration warning: $e');
      try {
        await _flutterTts.setLanguage('bn-IN');
      } catch (_) {}
    }
  }

  Future<void> _setupHindiVoice() async {
    try {
      final double naturalRate = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ? 0.85 : 0.48;
      await _flutterTts.setSpeechRate(naturalRate);
      await _flutterTts.setPitch(1.0);

      final dynamic voices = await _flutterTts.getVoices;
      if (voices is List && voices.isNotEmpty) {
        dynamic selectedVoice;

        // Try to find a high-quality Google or natural Indian Hindi voice
        for (final v in voices) {
          if (v is Map) {
            final locale = (v['locale'] ?? v['lang'] ?? '').toString().toLowerCase().replaceAll('_', '-');
            final name = (v['name'] ?? '').toString().toLowerCase();
            if (locale == 'hi-in' || (locale.startsWith('hi') && (name.contains('natural') || name.contains('google') || name.contains('network') || name.contains('local') || name.contains('india')))) {
              selectedVoice = v;
              break;
            }
          }
        }

        // Fallback to any Hindi voice
        if (selectedVoice == null) {
          for (final v in voices) {
            if (v is Map) {
              final locale = (v['locale'] ?? v['lang'] ?? '').toString().toLowerCase().replaceAll('_', '-');
              if (locale.startsWith('hi')) {
                selectedVoice = v;
                break;
              }
            }
          }
        }

        if (selectedVoice != null && selectedVoice is Map) {
          final voiceMap = Map<String, String>.from(
            selectedVoice.map((k, val) => MapEntry(k.toString(), val.toString())),
          );
          await _flutterTts.setVoice(voiceMap);
          final loc = voiceMap['locale'] ?? voiceMap['lang'] ?? 'hi-IN';
          await _flutterTts.setLanguage(loc);
          return;
        }
      }

      await _flutterTts.setLanguage('hi-IN');
    } catch (e) {
      debugPrint('Hindi voice configuration error: $e');
      try {
        await _flutterTts.setLanguage('hi-IN');
      } catch (_) {}
    }
  }

  Future<void> _setupEnglishVoice() async {
    final double naturalRate = (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ? 0.85 : 0.48;
    await _flutterTts.setSpeechRate(naturalRate);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setLanguage('en-US');
  }

  /// Sanitizes text for TTS engines by stripping emojis and non-speech symbols
  /// that cause native TTS engines (especially Google/Samsung TTS on non-Latin) to fail.
  String _sanitizeForTts(String text) {
    return text
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]|[\u{2600}-\u{26FF}]|[\u{2700}-\u{27BF}]', unicode: true), '')
        .replaceAll(RegExp(r'[\[\]\(\)\{\}\*#•\\]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> speak(String text, {TtsLanguage? overrideLang}) async {
    final cleanText = _sanitizeForTts(text);
    if (cleanText.isEmpty) return;

    final targetLang = overrideLang ?? _currentLanguage;
    await setLanguage(targetLang);

    // If already speaking, stop and wait 150ms to prevent native race condition
    if (_isPlaying) {
      await _flutterTts.stop();
      await Future.delayed(const Duration(milliseconds: 150));
    }

    try {
      final dynamic result = await _flutterTts.speak(cleanText);
      if (result == 1 || result == true) {
        _isPlaying = true;
        onPlayingStateChanged?.call(true);
      }
    } catch (e) {
      _isPlaying = false;
      onPlayingStateChanged?.call(false);
      debugPrint('VoiceTtsService speak exception: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
    _isPlaying = false;
    onPlayingStateChanged?.call(false);
  }
}
