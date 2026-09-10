// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

/// Web implementation that synchronizes the theme state to the WebGL background canvas.
void syncWebShaderMode(bool isDark) {
  try {
    js.context.callMethod('setShaderTheme', [isDark]);
  } catch (_) {
    // Graceful fallback if method is unavailable
  }
}
