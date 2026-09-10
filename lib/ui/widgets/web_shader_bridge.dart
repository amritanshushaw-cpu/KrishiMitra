import 'web_shader_bridge_stub.dart'
    if (dart.library.js) 'web_shader_bridge_web.dart' as bridge;

/// Notifies the host environment (e.g. WebGL canvas on Flutter Web) of current theme.
void syncWebShaderMode(bool isDark) {
  bridge.syncWebShaderMode(isDark);
}
