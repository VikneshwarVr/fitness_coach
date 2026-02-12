import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../data/repositories/auth_repository.dart';
import '../components/fitness_card.dart';
import '../components/buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;
  bool _isPhoneLogin = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isPhoneLogin) {
      if (_otpSent) {
        return _verifyOtp();
      } else {
        return _sendOtp();
      }
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      final authRepo = context.read<AuthRepository>();
      if (_isSignUp) {
        await authRepo.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          metadata: {
            'username': _usernameController.text.trim(),
          },
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Verification email sent! Please check your inbox.')),
          );
        }
      } else {
        await authRepo.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendOtp() async {
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthRepository>().signInWithPhone(_phoneController.text.trim());
      setState(() => _otpSent = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP sent! Please check your messages.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await context.read<AuthRepository>().verifyOtp(
        phoneNumber: _phoneController.text.trim(),
        token: _otpController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthRepository>().signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(LucideIcons.dumbbell, size: 64, color: AppTheme.primary),
                  const SizedBox(height: 24),
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isSignUp 
                      ? 'Join our community and track your progress'
                      : 'Sign in to continue your fitness journey',
                    style: const TextStyle(color: AppTheme.mutedForeground),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  if (_isPhoneLogin) ...[
                    // Phone Number / OTP Field
                    FitnessCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_otpSent ? 'Enter OTP' : 'Phone Number', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _otpSent ? _otpController : _phoneController,
                            keyboardType: _otpSent ? TextInputType.number : TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: _otpSent ? '123456' : '+1234567890',
                              prefixIcon: Icon(_otpSent ? LucideIcons.hash : LucideIcons.phone, size: 20),
                              filled: true,
                              fillColor: AppTheme.input,
                              border: const OutlineInputBorder(borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Username (Only for Sign Up)
                    if (_isSignUp) ...[
                      FitnessCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                hintText: 'howyoudoin',
                                prefixIcon: Icon(LucideIcons.user, size: 20),
                                filled: true,
                                fillColor: AppTheme.input,
                                border: OutlineInputBorder(borderSide: BorderSide.none),
                              ),
                              validator: (value) {
                                if (_isSignUp && (value == null || value.length < 3)) {
                                  return 'Username must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Email
                    FitnessCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'name@example.com',
                              prefixIcon: Icon(LucideIcons.mail, size: 20),
                              filled: true,
                              fillColor: AppTheme.input,
                              border: OutlineInputBorder(borderSide: BorderSide.none),
                            ),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Password
                    FitnessCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Password', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: Icon(LucideIcons.lock, size: 20),
                              filled: true,
                              fillColor: AppTheme.input,
                              border: OutlineInputBorder(borderSide: BorderSide.none),
                            ),
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator(color: AppTheme.primary))
                  else
                    PrimaryButton(
                      label: _isPhoneLogin 
                        ? (_otpSent ? 'Verify OTP' : 'Send OTP') 
                        : (_isSignUp ? 'Sign Up' : 'Sign In'),
                      onPressed: _submit,
                    ),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Social Login Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _continueWithGoogle,
                          icon: const Icon(LucideIcons.chrome, size: 20),
                          label: const Text('Google'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : () {
                            setState(() {
                              _isPhoneLogin = !_isPhoneLogin;
                              _otpSent = false;
                            });
                          },
                          icon: Icon(_isPhoneLogin ? LucideIcons.mail : LucideIcons.phone, size: 20),
                          label: Text(_isPhoneLogin ? 'Email' : 'Phone'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                        style: const TextStyle(color: AppTheme.mutedForeground),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _isSignUp = !_isSignUp),
                        child: Text(
                          _isSignUp ? 'Sign In' : 'Sign Up',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
