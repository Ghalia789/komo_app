import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../injection.dart';
import '../blocs/blocs.dart';
import '../widgets/widgets.dart';

// ENTRY POINT: Provides BLoC to the page
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(
        authRepository: locator(),
      )..add(LoginInitializeRequested()),
      child: const LoginView(),
    );
  }
}

// UI WIDGET: Builds the actual screen
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _showForgotDialog(BuildContext context, String prefill) async {
    final loginBloc = context.read<LoginBloc>();
    final controller = TextEditingController(text: prefill);
    String? error;
    bool isLoading = false;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return BlocProvider.value(
          value: loginBloc,
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return BlocListener<LoginBloc, LoginState>(
                listenWhen: (previous, current) =>
                    previous.isLoading != current.isLoading ||
                    previous.infoMessage != current.infoMessage ||
                    previous.errorMessage != current.errorMessage,
                listener: (context, state) {
                  setState(() => isLoading = state.isLoading);
                  if (!state.isLoading && state.infoMessage != null) {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.infoMessage!)),
                    );
                    Future.delayed(const Duration(milliseconds: 500), () {
                      Navigator.of(context).pushNamed(
                        RouteConstants.resetPassword,
                        arguments: controller.text.trim(),
                      );
                    });
                  }
                  if (state.errorMessage != null) {
                    setState(() => error = state.errorMessage);
                  }
                },
                child: AlertDialog(
                  title: const Text('Reset password'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Enter your email to receive a 6-digit password reset code',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          errorText: error,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: isLoading ? null : () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              final value = controller.text.trim();
                              final validation = Validators.email(value);
                              if (validation != null) {
                                setState(() => error = validation);
                                return;
                              }
                              context.read<LoginBloc>().add(
                                    LoginForgotPasswordSubmitted(value),
                                  );
                            },
                      child: Text(isLoading ? 'Sending...' : 'Send'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

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
                      'Welcome back',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // EMAIL FIELD WITH ERROR
                    BlocListener<LoginBloc, LoginState>(
                      listenWhen: (previous, current) => previous.email != current.email,
                      listener: (_, state) {
                        if (_emailController.text != state.email) {
                          _emailController.text = state.email;
                          _emailController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _emailController.text.length),
                          );
                        }
                      },
                      child: BlocBuilder<LoginBloc, LoginState>(
                        buildWhen: (previous, current) =>
                            previous.email != current.email ||
                            previous.emailError != current.emailError,
                        builder: (context, state) {
                          return KomoTextField(
                            hint: 'Email',
                            controller: _emailController,
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
                    
                    const SizedBox(height: 12),

                    // REMEMBER ME
                    BlocBuilder<LoginBloc, LoginState>(
                      buildWhen: (previous, current) => previous.rememberMe != current.rememberMe,
                      builder: (context, state) {
                        return Row(
                          children: [
                            Checkbox(
                              value: state.rememberMe,
                              onChanged: state.isLoading
                                  ? null
                                  : (value) {
                                      if (value != null) {
                                        context.read<LoginBloc>().add(
                                              LoginRememberMeToggled(value),
                                            );
                                      }
                                    },
                              activeColor: AppColors.primary,
                            ),
                            const Text(
                              'Remember me',
                              style: TextStyle(color: AppColors.textPrimary),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                    
                    // LOG IN BUTTON
                    BlocConsumer<LoginBloc, LoginState>(
                      listenWhen: (previous, current) =>
                          previous.isSuccess != current.isSuccess ||
                          previous.errorMessage != current.errorMessage ||
                          previous.infoMessage != current.infoMessage,
                      listener: (context, state) {
                        if (state.isSuccess) {
                          Navigator.of(context).pushReplacementNamed(RouteConstants.dashboard);
                        }
                        if (state.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.errorMessage!)),
                          );
                        }
                        if (state.infoMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.infoMessage!)),
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

                    const SizedBox(height: 12),

                    BlocBuilder<LoginBloc, LoginState>(
                      buildWhen: (previous, current) =>
                          previous.requiresEmailVerification !=
                              current.requiresEmailVerification ||
                          previous.isLoading != current.isLoading,
                      builder: (context, state) {
                        if (!state.requiresEmailVerification) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email not verified yet.',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Open the verification link from your inbox to continue.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        context.read<LoginBloc>().add(
                                              LoginResendVerificationPressed(),
                                            );
                                      },
                                child: const Text('Resend verification email'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // FORGOT PASSWORD
                    BlocBuilder<LoginBloc, LoginState>(
                      buildWhen: (previous, current) => previous.isLoading != current.isLoading,
                      builder: (context, state) {
                        return GestureDetector(
                          onTap: state.isLoading
                              ? null
                              : () => _showForgotDialog(context, state.email),
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              fontSize: 14,
                              color: state.isLoading
                                  ? AppColors.textHint
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
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