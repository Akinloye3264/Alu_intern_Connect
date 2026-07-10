import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/primary_button.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signIn(
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
      );
    }
  }

  void _openForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ForgotPasswordScreen(
          initialEmail: _emailCtrl.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/alu-intern-logo.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to discover opportunities',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 36),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: Validators.password,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) {
                      final state = context.read<AuthCubit>().state;
                      if (state is! AuthLoginLoading) _submit();
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: const Key('forgot_password_button'),
                      onPressed: _openForgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        label: 'Sign In',
                        isLoading: state is AuthLoginLoading,
                        onPressed: state is AuthLoginLoading ? null : _submit,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: AppColors.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                      Expanded(child: Divider(color: AppColors.border)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () =>
                        context.read<AuthCubit>().signInWithGoogle(),
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text('Continue with Google'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                      ),
                      child: const Text("Don't have an account? Sign up"),
                    ),
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
