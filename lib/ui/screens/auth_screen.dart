import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../services/secure_db_service.dart';
import '../../state/farm_provider.dart';
import '../../services/voice_tts_service.dart';
import '../widgets/liquid_glass_container.dart';
import '../widgets/liquid_glass_button.dart';
import 'main_shell_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both mobile number and password')),
      );
      return;
    }

    // Basic Indian mobile number validation (10 digits)
    final phoneRegex = RegExp(r'^\d{10}$');
    if (!phoneRegex.hasMatch(user.replaceAll(RegExp(r'\D'), ''))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!isLogin && name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your farmer name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (isLogin) {
        final bool success = await SecureDatabaseService.instance.loginUser(user, pass);
        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('isLoggedIn', true);
          await prefs.setString('current_username', user);

          final storedName = await SecureDatabaseService.instance.getUserName(user);
          final finalName = (storedName != null && storedName.trim().isNotEmpty)
              ? storedName.trim()
              : (prefs.getString('farmer_name') ?? user);

          await prefs.setString('farmer_name', finalName);

          if (mounted) {
            context.read<FarmProvider>().setFarmerName(finalName);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainShellScreen()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid credentials. Please check your mobile number and password.'),
                backgroundColor: AppTheme.alertRose,
              ),
            );
          }
        }
      } else {
        final resolvedName = name.isNotEmpty ? name : user;
        final bool success = await SecureDatabaseService.instance.registerUser(
          user,
          pass,
          name: resolvedName,
        );

        if (success) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('farmer_name', resolvedName);

          if (mounted) {
            context.read<FarmProvider>().setFarmerName(resolvedName);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome, $resolvedName! Account registered. Please sign in.'),
                backgroundColor: AppTheme.forestGreen,
              ),
            );
            setState(() {
              isLogin = true;
              _passwordController.clear();
            });
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Username already registered. Please choose a different username.'),
                backgroundColor: AppTheme.alertRose,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppTheme.softSage : AppTheme.forestMoss;
    final provider = context.watch<FarmProvider>();
    final strings = provider.strings;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: AppTheme.backgroundDecoration(isDark),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: LiquidGlassContainer(
                radius: 26,
                padding: const EdgeInsets.all(28.0),
                liquidColors: isDark 
                    ? [
                        AppTheme.emeraldLight.withValues(alpha: 0.15),
                        AppTheme.neonMint.withValues(alpha: 0.08),
                        Colors.transparent,
                      ]
                    : null,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Language Selector Dropdown
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryColor.withAlpha(50)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TtsLanguage>(
                              value: provider.ttsLanguage,
                              dropdownColor: isDark ? AppTheme.darkCanvas : AppTheme.ivoryCanvas,
                              icon: Icon(Icons.language_rounded, color: primaryColor),
                              items: const [
                                DropdownMenuItem(
                                  value: TtsLanguage.english,
                                  child: Text('English', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                DropdownMenuItem(
                                  value: TtsLanguage.hindi,
                                  child: Text('हिंदी (Hindi)', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                                DropdownMenuItem(
                                  value: TtsLanguage.bengali,
                                  child: Text('বাংলা (Bengali)', style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ],
                              onChanged: (TtsLanguage? newLang) {
                                if (newLang != null) {
                                  provider.setTtsLanguage(newLang);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Brand Emblem
                      Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(30),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor.withAlpha(70),
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            Icons.agriculture_rounded,
                            size: 30,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Brand Header
                      Text(
                        strings.authTitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isLogin ? strings.authSignInHeader : strings.authCreateHeader,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? AppTheme.darkTextPrimary : AppTheme.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Name Field (Sign Up Only)
                      if (!isLogin) ...[
                        Text(
                          strings.authNameLabel,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.badge_outlined, size: 20, color: primaryColor),
                            filled: true,
                            fillColor: isDark ? AppTheme.darkCanvas : AppTheme.ivoryCanvas,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Mobile Number Field
                      Text(
                        strings.authMobileLabel,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _usernameController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone_rounded, size: 20, color: primaryColor),
                          hintText: strings.authMobileHint,
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                          ),
                          filled: true,
                          fillColor: isDark ? AppTheme.darkCanvas : AppTheme.ivoryCanvas,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      Text(
                        strings.authPasswordLabel,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline_rounded, size: 20, color: primaryColor),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          hintText: '••••••••',
                          filled: true,
                          fillColor: isDark ? AppTheme.darkCanvas : AppTheme.ivoryCanvas,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark ? AppTheme.darkBorder : AppTheme.sageBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      LiquidGlassButton(
                        onPressed: _isLoading ? null : _submit,
                        width: double.infinity,
                        height: 52,
                        text: _isLoading ? null : (isLogin ? strings.authSignInBtn : strings.authRegisterBtn),
                        icon: _isLoading ? null : (isLogin ? Icons.login_rounded : Icons.person_add_rounded),
                        variant: LiquidButtonVariant.primary,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Toggle Login/Register
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                            _formKey.currentState?.reset();
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? AppTheme.darkTextMuted : AppTheme.lightTextMuted,
                        ),
                        child: Text(
                          isLogin ? strings.authToggleToRegister : strings.authToggleToSignIn,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }
}
