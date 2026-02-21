import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

// ENTRY POINT: Provides BLoC to the page
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: const LoginView(),
    );
  }
}

// UI WIDGET: Builds the actual screen
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // LOGO
              Image.asset(
                'assets/images/KOMO_LOGO_MINI.png',
                height: 80,
              ),
              
              const SizedBox(height: 40),
              
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
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // EMAIL FIELD WITH ERROR
                    BlocBuilder<LoginBloc, LoginState>(
                      buildWhen: (previous, current) => 
                        previous.email != current.email ||
                        previous.emailError != current.emailError,
                      builder: (context, state) {
                        return KomoTextField(
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          errorText: state.emailError,
                          onChanged: (value) {
                            context.read<LoginBloc>().add(
                              LoginEmailChanged(value),
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // PASSWORD FIELD WITH ERROR
                    BlocBuilder<LoginBloc, LoginState>(
                      buildWhen: (previous, current) => 
                        previous.password != current.password ||
                        previous.passwordError != current.passwordError,
                      builder: (context, state) {
                        return KomoTextField(
                          hint: 'Password',
                          obscureText: true,
                          errorText: state.passwordError,
                          onChanged: (value) {
                            context.read<LoginBloc>().add(
                              LoginPasswordChanged(value),
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // LOG IN BUTTON
                    BlocConsumer<LoginBloc, LoginState>(
                      listenWhen: (previous, current) => 
                        previous.isSuccess != current.isSuccess ||
                        previous.errorMessage != current.errorMessage,
                      listener: (context, state) {
                        if (state.isSuccess) {
                          Navigator.of(context).pushReplacementNamed('/dashboard');
                        }
                        if (state.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.errorMessage!)),
                          );
                        }
                      },
                      builder: (context, state) {
                        return KomoButton(
                          text: state.isLoading ? 'Loading...' : 'Log In',
                          isLoading: state.isLoading,
                          onPressed: state.isLoading || !state.isValid
                              ? null
                              : () {
                                  context.read<LoginBloc>().add(
                                    LoginSubmitted(),
                                  );
                                },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // FORGOT PASSWORD
                    GestureDetector(
                      onTap: () {
                        context.read<LoginBloc>().add(
                          LoginForgotPasswordPressed(),
                        );
                      },
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // SIGN UP LINK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<LoginBloc>().add(
                        LoginSignUpPressed(),
                      );
                      Navigator.of(context).pushNamed('/signup');
                    },
                    child: const Text(
                      'Sign up',
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