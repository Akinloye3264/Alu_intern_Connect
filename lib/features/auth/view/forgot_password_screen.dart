import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailCtrl;
  bool _sending = false;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await context.read<AuthRepository>().sendPasswordResetEmail(
        _emailCtrl.text,
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sent = true;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      _showError(_mapError(e));
    } catch (_) {
      if (!mounted) return;
      setState(() => _sending = false);
      _showError('Something went wrong. Please try again.');
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with that email.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'too-many-requests':
        return 'Too many requests. Please wait before trying again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network and try again.';
      default:
        return e.message ?? 'Could not send reset email.';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.danger.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _sent ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Icon(
            Icons.lock_reset_rounded,
            size: 56,
            color: AppColors.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Reset your password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Enter the email you used to sign up and we'll send you a link to reset your password.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 32),
          TextFormField(
            key: const Key('forgot_password_email_field'),
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: Validators.email,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            key: const Key('forgot_password_submit_button'),
            label: 'Send reset link',
            isLoading: _sending,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.mark_email_read_outlined,
          size: 64,
          color: AppColors.success,
        ),
        const SizedBox(height: 20),
        Text(
          'Check your inbox',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We sent a password reset link to ${_emailCtrl.text.trim()}. Follow the instructions in the email to set a new password.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        PrimaryButton(
          label: 'Back to sign in',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
