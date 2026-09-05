import 'package:flutter/material.dart';
import '../../services/secure_db_service.dart';
import 'main_shell_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLogin = true;

  void _submit() async {
    String user = _usernameController.text.trim();
    String pass = _passwordController.text.trim();

    if (user.isEmpty || pass.isEmpty) return;

    if (isLogin) {
      bool success = await SecureDatabaseService.instance.loginUser(user, pass);
      if (success) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShellScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid credentials')));
      }
    } else {
      bool success = await SecureDatabaseService.instance.registerUser(user, pass);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registered! Please Sign In.')));
        setState(() => isLogin = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username already exists')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(isLogin ? 'Sign In' : 'Sign Up', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: Text(isLogin ? 'Sign In' : 'Sign Up'),
              ),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: Text(isLogin ? 'Create an account' : 'Already have an account? Sign in'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
