import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/firestore_paths.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/skill_matcher.dart';
import '../../../models/app_user.dart';
import '../../../models/application.dart';
import '../../../models/opportunity.dart';
import '../../../repositories/application_repository.dart';
import '../../applications/cubit/application_cubit.dart';
import '../../applications/cubit/application_state.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final String opportunityId;
  final AppUser user;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunityId,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ApplicationCubit(ApplicationRepository())
            ..checkApplied(user.uid, opportunityId),
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
          actions: [
            IconButton(
              icon: Icon(
                Icons.bookmark_border_rounded,
                color: AppColors.textPrimary,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: FirebaseFirestore.instance
              .collection(FirestorePaths.opportunities)
              .doc(opportunityId)
              .get(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snap.hasData || !snap.data!.exists) {
              return Center(
                child: Text(
                  'Opportunity not found.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }
            return _DetailBody(
              opportunity: Opportunity.fromMap(snap.data!.data()!),
              user: user,
            );
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatefulWidget {
  final Opportunity opportunity;
  final AppUser user;
  const _DetailBody({required this.opportunity, required this.user});

  @override
  State<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends State<_DetailBody> {
  final _msgCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opportunity = widget.opportunity;
    final user = widget.user;
    final o = opportunity;
    final isStudent = user.role == UserRole.student;
    final skillsMatch =
        o.skillsRequired.isEmpty || SkillMatcher.score(user.skills, o) > 0;

    return BlocListener<ApplicationCubit, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationError) {
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
        if (state is ApplicationSuccess) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Application submitted'),
                  ],
                ),
                backgroundColor: AppColors.success.withValues(alpha: 0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            o.startupName.isNotEmpty
                                ? o.startupName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              o.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              o.startupName,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _pill(
                        o.category,
                        Icons.category_outlined,
                        AppColors.primary,
                      ),
                      _pill(
                        o.locationType,
                        Icons.location_on_outlined,
                        AppColors.success,
                      ),
                      _pill(
                        o.commitment,
                        Icons.schedule_outlined,
                        const Color(0xFFFBBF24),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: AppSpacing.lg),
            _section(
              'About this role',
              child: Text(
                o.description,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
            if (o.skillsRequired.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              _section(
                'Skills required',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: o.skillsRequired
                      .map(
                        (s) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            s,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
            ],
            const SizedBox(height: AppSpacing.xl),
            if (isStudent && skillsMatch) ...[
              BlocBuilder<ApplicationCubit, ApplicationState>(
                builder: (context, state) => state is ApplicationSuccess
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cover letter',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextField(
                            controller: _msgCtrl,
                            maxLines: 4,
                            maxLength: 500,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Tell the startup why you\'re a great fit for this role...',
                              counterStyle: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ),
              ).animate().fadeIn(delay: 180.ms, duration: 400.ms),
              BlocBuilder<ApplicationCubit, ApplicationState>(
                builder: (context, state) => SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: state is ApplicationSuccess
                          ? AppColors.success
                          : AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: state is ApplicationIdle
                        ? () => _apply(context)
                        : null,
                    child: state is ApplicationLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (state is ApplicationSuccess) ...[
                                const Icon(Icons.check_rounded, size: 20),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                state is ApplicationSuccess
                                    ? 'Applied'
                                    : 'Apply now',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
            ] else if (isStudent && !skillsMatch)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.block_rounded,
                      color: AppColors.danger,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Your skills don't match this opportunity's requirements. "
                        'Add matching skills in your Profile to apply.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'This is how students see your posting.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _apply(BuildContext context) {
    if (widget.user.role != UserRole.student) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only students can apply to opportunities.')),
      );
      return;
    }
    if (widget.user.skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add your skills in Profile before applying.'),
        ),
      );
      return;
    }
    if (_msgCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a cover letter.')),
      );
      return;
    }
    final opportunity = widget.opportunity;
    if (opportunity.skillsRequired.isNotEmpty &&
        SkillMatcher.score(widget.user.skills, opportunity) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Your skills don't match this opportunity's requirements.",
          ),
        ),
      );
      return;
    }
    context.read<ApplicationCubit>().apply(
      Application(
        applicationId: '',
        opportunityId: widget.opportunity.opportunityId,
        opportunityTitle: widget.opportunity.title,
        startupName: widget.opportunity.startupName,
        studentUid: widget.user.uid,
        studentName: widget.user.fullName,
        studentSkills: widget.user.skills,
        message: _msgCtrl.text.trim(),
        appliedAt: DateTime.now(),
      ),
    );
  }

  Widget _section(String title, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }

  Widget _pill(String label, IconData icon, Color color) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
