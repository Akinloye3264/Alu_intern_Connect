import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../cubit/auth_cubit.dart';

class VerificationScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final bool canResendEmail;

  const VerificationScreen.email({super.key, required String email})
    : title = 'Verify your email',
      message =
          'We sent a verification link to $email. Open the link, then '
          'return here and check your status.',
      icon = Icons.mark_email_unread_rounded,
      canResendEmail = true;

  const VerificationScreen.startup({super.key})
    : title = 'Startup verification pending',
      message =
          'Your email is verified. Your company website and registration '
          'number are awaiting review. You can access the startup dashboard '
          'after an administrator approves your organization.',
      icon = Icons.domain_verification_rounded,
      canResendEmail = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () =>
                      context.read<AuthCubit>().checkVerificationStatus(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Check status'),
                ),
              ),
              if (canResendEmail) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    try {
                      await context.read<AuthCubit>().resendVerificationEmail();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Verification email sent.'),
                          ),
                        );
                      }
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not resend yet. Try later.'),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Resend verification email'),
                ),
              ],
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.read<AuthCubit>().signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
