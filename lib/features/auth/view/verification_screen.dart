import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/startup.dart';
import '../cubit/auth_cubit.dart';

class VerificationScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const VerificationScreen.startup({
    super.key,
    StartupVerificationStatus status = StartupVerificationStatus.pending,
  }) : title = status == StartupVerificationStatus.rejected
           ? 'Startup application not approved'
           : 'Startup verification pending',
       message = status == StartupVerificationStatus.rejected
           ? "Your startup application wasn't approved. Contact the ALU "
                 'Intern Connect team if you think this is a mistake.'
           : 'Your company website and registration number are awaiting '
                 'review. You can access the startup '
                 'dashboard after an administrator approves your organization.',
       icon = status == StartupVerificationStatus.rejected
           ? Icons.cancel_outlined
           : Icons.domain_verification_rounded;

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
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
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
