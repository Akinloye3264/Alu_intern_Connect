import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_user.dart';
import '../../../models/application.dart';
import '../../../repositories/application_repository.dart';
import '../cubit/application_cubit.dart';
import '../cubit/application_state.dart';

class MyApplicationsScreen extends StatelessWidget {
  final AppUser user;
  const MyApplicationsScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ApplicationCubit(ApplicationRepository())..loadForStudent(user.uid),
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'My Applications',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.background,
            bottom: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Applied'),
                Tab(text: 'Review'),
                Tab(text: 'Interview'),
                Tab(text: 'Accepted'),
              ],
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
              final loaded = state as ApplicationLoaded;
              return TabBarView(
                children: [
                  _list(loaded.applications),
                  _list(loaded.byStatus(ApplicationStatus.applied)),
                  _list(loaded.byStatus(ApplicationStatus.underReview)),
                  _list(loaded.byStatus(ApplicationStatus.interview)),
                  _list(loaded.byStatus(ApplicationStatus.accepted)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _list(List<Application> apps) {
    if (apps.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Nothing here yet',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your applications will appear here',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
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
        child: _AppCard(application: apps[i])
            .animate()
            .fadeIn(delay: (i * 60).ms, duration: 350.ms)
            .slideY(begin: 0.05, end: 0),
      ),
    );
  }
}

class _AppCard extends StatelessWidget {
  final Application application;
  const _AppCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final a = application;
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
                    a.startupName.isNotEmpty
                        ? a.startupName[0].toUpperCase()
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      a.opportunityTitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      a.startupName,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: a.status),
            ],
          ),
          const SizedBox(height: 12),
          _PipelineIndicator(status: a.status),
        ],
      ),
    );
  }
}

class _PipelineIndicator extends StatelessWidget {
  final ApplicationStatus status;
  const _PipelineIndicator({required this.status});

  static const _stages = [
    ApplicationStatus.applied,
    ApplicationStatus.underReview,
    ApplicationStatus.interview,
    ApplicationStatus.accepted,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIdx = _stages.indexOf(status);
    if (status == ApplicationStatus.closed) {
      return const Text(
        'Closed',
        style: TextStyle(color: AppColors.danger, fontSize: 11),
      );
    }
    return Row(
      children: List.generate(_stages.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stageIdx = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stageIdx < currentIdx
                  ? AppColors.primary
                  : AppColors.border,
            ),
          );
        }
        final stageIdx = i ~/ 2;
        final active = stageIdx <= currentIdx;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.primary : AppColors.border,
          ),
        );
      }),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  const _StatusBadge({required this.status});

  Color get _color {
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: _color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
