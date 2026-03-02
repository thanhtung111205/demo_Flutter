import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userCred = await AuthService.signInWithGoogle();
      if (userCred == null) {
        setState(() => _error = 'Sign-in cancelled');
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FlutterLogo(size: 96),
                const SizedBox(height: 24),
                Text('Smart Note Pro', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Sign in to sync your notes across devices', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 24),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
                FilledButton.icon(
                  icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : Image.asset('assets/google_logo.png', width: 20, height: 20),
                  label: Text(_loading ? 'Signing in…' : 'Sign in with Google'),
                  onPressed: _loading ? null : _handleGoogleSignIn,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
