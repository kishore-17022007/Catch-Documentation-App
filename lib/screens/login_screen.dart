import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/app_state.dart';
import '../services/localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String _verificationId = '';
  String _phoneAuthError = '';
  ConfirmationResult? _confirmationResult;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _normalizePhone(String input) {
    final trimmed = input.trim();
    final digitsOnly = trimmed.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) return '';
    if (trimmed.startsWith('+')) {
      return '+$digitsOnly';
    }
    return '+91$digitsOnly';
  }

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showMessage('Please enter a phone number');
      return;
    }

    final formattedPhone = _normalizePhone(phone);
    final digitsOnly = formattedPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 10 || !formattedPhone.startsWith('+')) {
      _showMessage('Please enter a valid phone number');
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneAuthError = '';
    });

    try {
      await FirebaseAuth.instance.setLanguageCode('en');
      print('Requesting phone auth for: $formattedPhone');

      if (kIsWeb) {
        _confirmationResult = await FirebaseAuth.instance.signInWithPhoneNumber(formattedPhone);
        setState(() {
          _isLoading = false;
          _otpSent = true;
        });
      } else {
        await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: formattedPhone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
              final user = userCredential.user;
              if (mounted && user != null && user.phoneNumber != null) {
                await context.read<AppState>().login(phoneNumber: user.phoneNumber!);
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/dashboard');
                }
              }
            } catch (e) {
              _showMessage('Auto-verification failed: $e');
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            setState(() {
              _isLoading = false;
              _otpSent = false;
              _phoneAuthError = e.code == 'operation-not-allowed'
                  ? 'Phone authentication failed. Confirm Phone sign-in is enabled in Firebase Auth and use an exact Firebase test number in the format +911234567890.'
                  : 'Verification failed: ${e.message ?? e.code}';
            });
            _showMessage(_phoneAuthError);
          },
          codeSent: (String verificationId, int? resendToken) {
            setState(() {
              _isLoading = false;
              _otpSent = true;
              _verificationId = verificationId;
            });
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            setState(() => _verificationId = verificationId);
          },
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _otpSent = false;
        _phoneAuthError = e is FirebaseAuthException && e.code == 'operation-not-allowed'
            ? 'Phone authentication failed. Confirm Phone sign-in is enabled in Firebase Auth and use an exact Firebase test number in the format +911234567890.'
            : 'Unable to send OTP: $e';
      });
      _showMessage(_phoneAuthError);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      _showMessage('Please enter the OTP');
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneAuthError = '';
    });

    try {
      User? user;
      if (kIsWeb) {
        if (_confirmationResult == null) throw Exception('No confirmation result available');
        final userCredential = await _confirmationResult!.confirm(otp);
        user = userCredential.user;
      } else {
        if (_verificationId.isEmpty) throw Exception('No verification ID available');
        final credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: otp,
        );
        final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
        user = userCredential.user;
      }

      if (mounted && user != null && user.phoneNumber != null) {
        await context.read<AppState>().login(phoneNumber: user.phoneNumber!);
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        setState(() {
          _phoneAuthError = 'Could not complete sign-in. Please try again.';
        });
        _showMessage(_phoneAuthError);
      }
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'operation-not-allowed'
          ? 'Phone authentication failed. Confirm Phone sign-in is enabled in Firebase Auth and use an exact Firebase test number.'
          : 'Verification failed: ${e.message ?? e.code}';
      setState(() {
        _phoneAuthError = message;
        _otpSent = false;
      });
      _showMessage(message);
    } catch (e) {
      setState(() {
        _phoneAuthError = 'Invalid OTP or verification error. Please try again.';
        _otpSent = false;
      });
      _showMessage(_phoneAuthError);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      final user = userCredential.user;
      if (mounted && user != null) {
        await context.read<AppState>().login();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        _showMessage('Anonymous sign-in failed.');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage('Anonymous login failed: ${e.message ?? e.code}');
    } catch (e) {
      _showMessage('Anonymous login failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final currentLang = state.currentLanguage;
    final translate = (String key) => AppLocalization.translate(currentLang, key);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(translate('login_title')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.security,
                size: 80,
                color: Color(0xFF00796B),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_otpSent,
                decoration: InputDecoration(
                  labelText: translate('mobile_number'),
                  hintText: 'Use a Firebase test number like +911234567890',
                  helperText: 'Enter the exact test number from Firebase Console without spaces.',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: translate('otp_code'),
                    prefixIcon: const Icon(Icons.password),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_otpSent ? _verifyOtp : _sendOtp),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          _otpSent ? translate('login_btn') : 'Send OTP',
                          style: const TextStyle(fontSize: 18),
                        ),
                ),
              ),
              if (_phoneAuthError.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  _phoneAuthError,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signInAnonymously,
                    child: const Text('Continue with anonymous login'),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'If phone auth is disabled, use anonymous login or enable Phone sign-in in Firebase Auth settings.',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
