import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/application.dart';
import '../../../repositories/application_repository.dart';
import '../cubit/application_cubit.dart';
import '../cubit/application_state.dart';

class ApplicantsScreen extends StatelessWidget {
  final String opportunityId;
  final String opportunityTitle;

  const ApplicantsScreen({
    super.key,
    required this.opportunityId,
    required this.opportunityTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ApplicationCubit(ApplicationRepository())
        ..loadForOpportunity(opportunityId),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            opportunityTitle,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: BlocBuilder<ApplicationCubit, ApplicationState>(
          builder: (context, state) {
            if (state is ApplicationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ApplicationError) {
              return Center(
                child: Text(
                  state.message,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            final apps = (state as ApplicationLoaded).applications;
            if (apps.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 48,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No applicants yet',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Applicants will appear here once students apply',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: apps.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _ApplicantCard(application: apps[i])
                    .animate()
                    .fadeIn(delay: (i * 60).ms, duration: 350.ms)
                    .slideY(begin: 0.05, end: 0),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ApplicantCard extends StatelessWidget {
  final Application application;
  const _ApplicantCard({required this.application});

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.applied:
        return AppColors.textSecondary;
      case ApplicationStatus.underReview:
        return const Color(0xFFFBBF24);
      case ApplicationStatus.interview:
        return AppColors.primary;
      case ApplicationStatus.accepted:
        return AppColors.success;
      case ApplicationStatus.closed:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = application;
    final color = _statusColor(a.status);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    a.studentName.isNotEmpty
                        ? a.studentName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  a.studentName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  a.status.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (a.studentSkills.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: a.studentSkills
                  .map(
                    (s) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (a.message.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cover letter',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    a.message.trim(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: PopupMenuButton<ApplicationStatus>(
              onSelected: (status) => context
                  .read<ApplicationCubit>()
                  .advanceStatus(a.applicationId, status),
              itemBuilder: (_) => ApplicationStatus.values
                  .map(
                    (s) => PopupMenuItem(value: s, child: Text(s.label)),
                  )
                  .toList(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Change status',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down_rounded,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
