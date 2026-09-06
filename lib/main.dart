import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'services/voice_tts_service.dart';
import 'state/farm_provider.dart';
import 'ui/screens/main_shell_screen.dart';
import 'package:fresnel/fresnel.dart';
import 'ui/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Fresnel.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SmartFarmEdgeApp());
}

class SmartFarmEdgeApp extends StatelessWidget {
  const SmartFarmEdgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FarmProvider()),
      ],
      child: Consumer<FarmProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'KrishiMitra AI // AgriSense Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: provider.ttsLanguage == TtsLanguage.bengali
                ? const Locale('bn', 'IN')
                : (provider.ttsLanguage == TtsLanguage.hindi
                    ? const Locale('hi', 'IN')
                    : const Locale('en', 'US')),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('bn', 'IN'),
              Locale('hi', 'IN'),
            ],
            home: const AuthGuard(),
          );
        },
      ),
    );
  }
}

class AuthGuard extends StatelessWidget {
  const AuthGuard({Key? key}) : super(key: key);

  Future<bool> _checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          return const MainShellScreen();
        }
        return const AuthScreen();
      },
    );
  }
}
