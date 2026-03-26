import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../injection.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ResetPasswordBloc(
        authRepository: locator(),
        email: widget.email,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 35),
                
                // LOGO
                Image.asset(
                  'assets/images/KOMO_LOGO_MINI.png',
                  height: 130,
                ),
                
                const SizedBox(height: 25),
                
                // WHITE CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDark.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // TITLE
                      const Text(
                        'Reset Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // SUBTITLE
                      const Text(
                        'Enter the 6-digit code from your email and create a new password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (widget.email.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          widget.email,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // RESET CODE FIELD
                      BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                        buildWhen: (previous, current) =>
                            previous.code != current.code ||
                            previous.codeError != current.codeError,
                        builder: (context, state) {
                          return KomoTextField(
                            hint: 'Reset Code',
                            errorText: state.codeError,
                            onChanged: (value) {
                              context.read<ResetPasswordBloc>().add(
                                    ResetPasswordCodeChanged(value),
                                  );
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // NEW PASSWORD FIELD
                      BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                        buildWhen: (previous, current) =>
                            previous.password != current.password ||
                            previous.passwordError != current.passwordError ||
                            previous.isPasswordVisible != current.isPasswordVisible,
                        builder: (context, state) {
                          return KomoTextField(
                            hint: 'New Password',
                            obscureText: !state.isPasswordVisible,
                            errorText: state.passwordError,
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                context.read<ResetPasswordBloc>().add(
                                      const ResetPasswordToggleVisibility(),
                                    );
                              },
                            ),
                            onChanged: (value) {
                              context.read<ResetPasswordBloc>().add(
                                    ResetPasswordChanged(value),
                                  );
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // CONFIRM PASSWORD FIELD
                      BlocBuilder<ResetPasswordBloc, ResetPasswordState>(
                        buildWhen: (previous, current) =>
                            previous.confirmPassword != current.confirmPassword ||
                            previous.confirmPasswordError != current.confirmPasswordError ||
                            previous.isConfirmPasswordVisible != current.isConfirmPasswordVisible,
                        builder: (context, state) {
                          return KomoTextField(
                            hint: 'Confirm Password',
                            obscureText: !state.isConfirmPasswordVisible,
                            errorText: state.confirmPasswordError,
                            suffixIcon: IconButton(
                              icon: Icon(
                                state.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                context.read<ResetPasswordBloc>().add(
                                      const ResetPasswordToggleConfirmVisibility(),
                                    );
                              },
                            ),
                            onChanged: (value) {
                              context.read<ResetPasswordBloc>().add(
                                    ResetPasswordConfirmChanged(value),
                                  );
                            },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // RESET PASSWORD BUTTON
                      BlocConsumer<ResetPasswordBloc, ResetPasswordState>(
                        listenWhen: (previous, current) =>
                            previous.isSuccess != current.isSuccess ||
                            previous.errorMessage != current.errorMessage ||
                            previous.infoMessage != current.infoMessage,
                        listener: (context, state) {
                          if (state.isSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.infoMessage ?? 'Password reset successfully')),
                            );
                            Future.delayed(const Duration(seconds: 1), () {
                              if (mounted) {
                                Navigator.of(context).pushReplacementNamed(RouteConstants.login);
                              }
                            });
                          }
                          if (state.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.errorMessage!)),
                            );
                          }
                        },
                        builder: (context, state) {
                          return KomoButton(
                            text: state.isLoading ? 'Resetting...' : 'Reset Password',
                            isLoading: state.isLoading,
                            onPressed: state.isLoading || !state.isValid
                                ? null
                                : () {
                                    context.read<ResetPasswordBloc>().add(
                                          const ResetPasswordSubmitted(),
                                        );
                                  },
                          );
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // BACK TO LOGIN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Remember your password? ',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pushReplacementNamed(RouteConstants.login);
                            },
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
