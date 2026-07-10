import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../models/app_user.dart';
import '../../../models/startup.dart';
import '../../../repositories/admin_repository.dart';
import '../../auth/cubit/auth_cubit.dart';

class AdminStartupsScreen extends StatefulWidget {
  final AppUser user;

  const AdminStartupsScreen({super.key, required this.user});

  @override
  State<AdminStartupsScreen> createState() => _AdminStartupsScreenState();
}

class _AdminStartupsScreenState extends State<AdminStartupsScreen> {
  final _repository = AdminRepository();
  String? _updatingId;

  @override
  Widget build(BuildContext context) {
    if (widget.user.role != UserRole.admin) {
      return const Scaffold(body: Center(child: Text('Access denied')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup approvals'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => context.read<AuthCubit>().signOut(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: StreamBuilder<List<Startup>>(
        stream: _repository.watchStartups(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Could not load startups: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final startups = snapshot.data!;
          if (startups.isEmpty) {
            return const Center(child: Text('No startup applications yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: startups.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _startupCard(startups[index]),
          );
        },
      ),
    );
  }

  Widget _startupCard(Startup startup) {
    final updating = _updatingId == startup.startupId;
    final statusColor = switch (startup.verificationStatus) {
      StartupVerificationStatus.approved => AppColors.success,
      StartupVerificationStatus.rejected => AppColors.danger,
      StartupVerificationStatus.pending => Colors.orange,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    startup.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(startup.verificationStatus.name.toUpperCase()),
                  side: BorderSide(color: statusColor),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _detail('Email', startup.email),
            _detail('Website', startup.website),
            _detail('Registration number', startup.registrationNumber),
            _detail('Category', startup.category),
            const SizedBox(height: AppSpacing.md),
            if (updating)
              const Center(child: CircularProgressIndicator())
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _setStatus(
                        startup,
                        StartupVerificationStatus.rejected,
                      ),
                      icon: const Icon(Icons.close_rounded),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _setStatus(
                        startup,
                        StartupVerificationStatus.approved,
                      ),
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text('$label: ${value.isEmpty ? 'Not provided' : value}'),
    );
  }

  Future<void> _setStatus(
    Startup startup,
    StartupVerificationStatus status,
  ) async {
    setState(() => _updatingId = startup.startupId);
    try {
      await _repository.setVerificationStatus(startup.startupId, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${startup.name} marked ${status.name}.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _updatingId = null);
    }
  }
}
