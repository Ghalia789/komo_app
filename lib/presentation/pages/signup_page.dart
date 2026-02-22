import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupBloc(),
      child: const SignupView(),
    );
  }
}

class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      'Create account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // EMAIL
                    BlocBuilder<SignupBloc, SignupState>(
                      buildWhen: (previous, current) => 
                        previous.email != current.email ||
                        previous.emailError != current.emailError,
                      builder: (context, state) {
                        return KomoTextField(
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          errorText: state.emailError,
                          onChanged: (value) {
                            context.read<SignupBloc>().add(SignupEmailChanged(value));
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // PASSWORD with working eye toggle
                    BlocBuilder<SignupBloc, SignupState>(
                      buildWhen: (previous, current) => 
                        previous.password != current.password ||
                        previous.passwordError != current.passwordError ||
                        previous.isPasswordVisible != current.isPasswordVisible,
                      builder: (context, state) {
                        return KomoTextField(
                          hint: 'Password',
                          obscureText: !state.isPasswordVisible,
                          errorText: state.passwordError,
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.isPasswordVisible 
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              context.read<SignupBloc>().add(SignupTogglePasswordVisibility());
                            },
                          ),
                          onChanged: (value) {
                            context.read<SignupBloc>().add(SignupPasswordChanged(value));
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // CONFIRM PASSWORD with working eye toggle
                    BlocBuilder<SignupBloc, SignupState>(
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
                              state.isConfirmPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              context.read<SignupBloc>().add(SignupToggleConfirmPasswordVisibility());
                            },
                          ),
                          onChanged: (value) {
                            context.read<SignupBloc>().add(SignupConfirmPasswordChanged(value));
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // SIGN UP BUTTON
                    BlocConsumer<SignupBloc, SignupState>(
                      listenWhen: (previous, current) => 
                        previous.isSuccess != current.isSuccess,
                      listener: (context, state) {
                        if (state.isSuccess) {
                          Navigator.of(context).pushReplacementNamed('/complete-profile');
                        }
                      },
                      builder: (context, state) {
                        return KomoButton(
                          text: state.isLoading ? 'Loading...' : 'Sign Up',
                          isLoading: state.isLoading,
                          onPressed: state.isLoading || !state.isValid
                              ? null
                              : () {
                                  context.read<SignupBloc>().add(SignupSubmitted());
                                },
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // LOGIN LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<SignupBloc>().add(SignupLoginPressed());
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    child: Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}