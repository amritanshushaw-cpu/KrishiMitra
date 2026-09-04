import 'package:flutter_tts/flutter_tts.dart';

enum TtsLanguage { bengali, hindi, english }

class VoiceTtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  TtsLanguage _currentLanguage = TtsLanguage.bengali;

  bool get isPlaying => _isPlaying;
  TtsLanguage get currentLanguage => _currentLanguage;

  Future<void> initialize() async {
    await _flutterTts.setSpeechRate(0.48); // Slightly slower for clear agrarian comprehension
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setStartHandler(() {
      _isPlaying = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
    });

    _flutterTts.setErrorHandler((msg) {
      _isPlaying = false;
    });

    await setLanguage(TtsLanguage.bengali);
  }

  Future<void> setLanguage(TtsLanguage lang) async {
    _currentLanguage = lang;
    switch (lang) {
      case TtsLanguage.bengali:
        await _flutterTts.setLanguage('bn-IN');
        break;
      case TtsLanguage.hindi:
        await _flutterTts.setLanguage('hi-IN');
        break;
      case TtsLanguage.english:
        await _flutterTts.setLanguage('en-US');
        break;
    }
  }

  Future<void> speak(String text, {TtsLanguage? overrideLang}) async {
    if (text.trim().isEmpty) return;

    if (overrideLang != null && overrideLang != _currentLanguage) {
      await setLanguage(overrideLang);
    }

    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
  }
}
