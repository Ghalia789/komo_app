import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../injection.dart';

class EmailVerificationGuard extends StatefulWidget {
  const EmailVerificationGuard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<EmailVerificationGuard> createState() => _EmailVerificationGuardState();
}

class _EmailVerificationGuardState extends State<EmailVerificationGuard> {
  bool _isChecking = true;
  bool _isVerified = false;
  bool _isBusy = false;
  String? _message;

  AuthRepository get _authRepository => locator<AuthRepository>();

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      _isChecking = true;
      _message = null;
    });

    final result = await _authRepository.isCurrentUserEmailVerified(reload: true);
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isChecking = false;
          _isVerified = false;
          _message = failure.message;
        });
      },
      (isVerified) {
        setState(() {
          _isChecking = false;
          _isVerified = isVerified;
          _message = isVerified ? null : null;
        });
      },
    );
  }

  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isBusy = true;
      _message = null;
    });

    final result = await _authRepository.sendEmailVerification();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isBusy = false;
          _message = failure.message;
        });
      },
      (_) {
        setState(() {
          _isBusy = false;
          _message = 'Verification email sent. Please check your inbox.';
        });
      },
    );
  }

  Future<void> _signOut() async {
    await _authRepository.signOut();
    if (!mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      RouteConstants.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_isVerified) {
      return widget.child;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify your email'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Your account email is not verified yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please open the verification link from your inbox before continuing.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBusy ? null : _resendVerificationEmail,
                  child: Text(_isBusy ? 'Sending...' : 'Resend verification email'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isBusy ? null : _checkVerificationStatus,
                  child: const Text("I've verified, continue"),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _isBusy ? null : _signOut,
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
