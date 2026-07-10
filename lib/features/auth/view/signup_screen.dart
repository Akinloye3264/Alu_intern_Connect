import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../models/app_user.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _registrationCtrl = TextEditingController();
  UserRole _role = UserRole.student;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _websiteCtrl.dispose();
    _registrationCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthCubit>().signUp(
        fullName: _nameCtrl.text,
        email: _emailCtrl.text,
        password: _passwordCtrl.text,
        role: _role,
        startupWebsite: _websiteCtrl.text,
        registrationNumber: _registrationCtrl.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.danger.withValues(alpha: 0.9),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
          if (state is Authenticated) {
            Navigator.of(context).popUntil((r) => r.isFirst);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        'Create account',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: -0.1, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    'Join the ALU intern network',
                    style: TextStyle(color: AppColors.textSecondary),
                  ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
                  const SizedBox(height: 32),
                  Text(
                    'I am a...',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ).animate().fadeIn(delay: 120.ms, duration: 400.ms),
                  const SizedBox(height: 10),
                  Row(
                        children: [
                          _roleChip(
                            UserRole.student,
                            Icons.school_rounded,
                            'Student',
                          ),
                          const SizedBox(width: 12),
                          _roleChip(
                            UserRole.startup,
                            Icons.rocket_launch_rounded,
                            'Startup',
                          ),
                        ],
                      )
                      .animate()
                      .fadeIn(delay: 160.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 24),
                  TextFormField(
                        controller: _nameCtrl,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: _role == UserRole.startup
                              ? 'Startup / your name'
                              : 'Full name',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: (v) => Validators.notEmpty(v, 'Name'),
                      )
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        validator: _role == UserRole.student
                            ? Validators.aluStudentEmail
                            : Validators.email,
                      )
                      .animate()
                      .fadeIn(delay: 240.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 16),
                  if (_role == UserRole.startup) ...[
                    TextFormField(
                      controller: _websiteCtrl,
                      keyboardType: TextInputType.url,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Company website',
                        hintText: 'https://example.com',
                        prefixIcon: Icon(
                          Icons.language_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: Validators.website,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _registrationCtrl,
                      style: TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Company registration number',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      validator: (v) =>
                          Validators.notEmpty(v, 'Registration number'),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: Validators.password,
                      )
                      .animate()
                      .fadeIn(delay: 280.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: state is AuthLoading ? null : _submit,
                            child: state is AuthLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create account',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 320.ms, duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleChip(UserRole role, IconData icon, String label) {
    final selected = _role == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _role = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
