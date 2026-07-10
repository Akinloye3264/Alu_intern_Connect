import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../models/app_user.dart';
import '../../../models/application.dart';
import '../../../repositories/application_repository.dart';
import '../../../repositories/profile_repository.dart';
import '../auth/cubit/auth_cubit.dart';

class ProfileScreen extends StatefulWidget {
  final AppUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late List<String> _skills;
  late final TextEditingController _bioCtrl;
  final _profileRepo = ProfileRepository();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _skills = List<String>.from(widget.user.skills);
    _bioCtrl = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final authCubit = context.read<AuthCubit>();
    setState(() => _saving = true);
    if (_skills.isEmpty) {
      setState(() => _saving = false);
      _showMessage('Add at least one skill to your profile.', isError: true);
      return;
    }
    try {
      await _profileRepo.updateStudentProfile(
        uid: widget.user.uid,
        skills: _skills,
        bio: _bioCtrl.text,
      );
      await authCubit.refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 10),
                Text('Profile updated'),
              ],
            ),
            backgroundColor: AppColors.success.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = widget.user;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: Icon(
              Icons.logout_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Sign out',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.primarySoft,
                          backgroundImage: u.photoUrl.isNotEmpty
                              ? NetworkImage(u.photoUrl)
                              : null,
                          child: u.photoUrl.isEmpty
                              ? Text(
                                  u.fullName.isNotEmpty
                                      ? u.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 36,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          u.fullName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          u.email,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: u.role == UserRole.student
                                ? AppColors.primarySoft
                                : AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            u.role == UserRole.student ? 'Student' : 'Startup',
                            style: TextStyle(
                              color: u.role == UserRole.student
                                  ? AppColors.primary
                                  : AppColors.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                  ),
              const SizedBox(height: AppSpacing.xl),
              StreamBuilder<List<Application>>(
                stream: ApplicationRepository().watchStudentApplications(
                  widget.user.uid,
                ),
                builder: (context, snapshot) {
                  final applications = snapshot.data ?? const <Application>[];
                  final shortlisted = applications
                      .where(
                        (a) =>
                            a.status == ApplicationStatus.interview ||
                            a.status == ApplicationStatus.accepted,
                      )
                      .length;
                  final accepted = applications
                      .where((a) => a.status == ApplicationStatus.accepted)
                      .length;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _stat('${applications.length}', 'Applications'),
                        _stat('$shortlisted', 'Shortlisted'),
                        _stat('$accepted', 'Accepted'),
                      ],
                    ),
                  );
                },
              ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _detailRow(Icons.person_outline, 'Full name', u.fullName),
                    Divider(color: AppColors.border),
                    _detailRow(Icons.email_outlined, 'Email address', u.email),
                    Divider(color: AppColors.border),
                    _detailRow(
                      Icons.badge_outlined,
                      'Account type',
                      u.role == UserRole.student ? 'Student' : 'Startup',
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.lg),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, mode) {
                  final isDark = mode == ThemeMode.dark;
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SwitchListTile(
                      key: const Key('dark_mode_switch'),
                      value: isDark,
                      onChanged: (_) => context.read<ThemeCubit>().toggle(),
                      activeThumbColor: AppColors.primary,
                      secondary: Icon(
                        isDark
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Dark mode',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        isDark ? 'On' : 'Off',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.lg),
              _sectionLabel('Bio'),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _bioCtrl,
                maxLines: 3,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Tell startups a bit about yourself',
                ),
              ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.lg),
              _sectionLabel('Skills'),
              const SizedBox(height: AppSpacing.sm),
              _SkillChipsInput(
                skills: _skills,
                onAdd: (s) => setState(() => _skills.add(s)),
                onRemove: (s) => setState(() => _skills.remove(s)),
              ).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              const SizedBox(height: 6),
              Text(
                'Tap × to remove a skill. Powers recommendations on your feed.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  key: const Key('profile_logout_button'),
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
    label,
    style: TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 14,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    ),
  );

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? AppColors.danger : AppColors.success,
        ),
      );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (shouldLogout == true && mounted) {
      final signOut = context.read<AuthCubit>().signOut();
      Navigator.of(context).popUntil((route) => route.isFirst);
      await signOut;
    }
  }
}
class _SkillChipsInput extends StatefulWidget {
  final List<String> skills;
  final void Function(String skill) onAdd;
  final void Function(String skill) onRemove;

  const _SkillChipsInput({
    required this.skills,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<_SkillChipsInput> createState() => _SkillChipsInputState();
}

class _SkillChipsInputState extends State<_SkillChipsInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _tryAdd() {
    final text = _ctrl.text.replaceAll(',', '').trim();
    if (text.isNotEmpty && !widget.skills.contains(text)) {
      widget.onAdd(text);
    }
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.skills.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: widget.skills
                  .map(
                    (s) => Chip(
                      label: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: AppColors.primarySoft,
                      deleteIconColor:
                          AppColors.primary.withValues(alpha: 0.7),
                      side: BorderSide.none,
                      onDeleted: () => widget.onRemove(s),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  focusNode: _focus,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.skills.isEmpty
                        ? 'e.g. Flutter, Dart, Figma'
                        : 'Add another skill...',
                    hintStyle: const TextStyle(fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) {
                    _tryAdd();
                    _focus.requestFocus();
                  },
                  onChanged: (v) {
                    if (v.endsWith(',')) _tryAdd();
                  },
                ),
              ),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _ctrl,
                builder: (_, v, _) => v.text.trim().isNotEmpty
                    ? GestureDetector(
                        onTap: _tryAdd,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
