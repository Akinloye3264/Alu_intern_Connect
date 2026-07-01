import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/skill_matcher.dart';
import '../../../core/widgets/opportunity_card.dart';
import '../../../models/app_user.dart';
import '../../../models/opportunity.dart';
import '../../../repositories/opportunity_repository.dart';
import '../../../repositories/auth_repository.dart';
import '../../opportunities/cubit/opportunity_cubit.dart';
import '../../opportunities/cubit/opportunity_state.dart';
import '../../opportunities/view/opportunity_detail_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onProfileTap;

  const StudentHomeScreen({
    super.key,
    required this.user,
    required this.onProfileTap,
  });

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _authRepo = AuthRepository();
  String _search = '';
  String _filterCategory = 'All';
  String _filterLocation = 'All';
  bool _verified = true;

  static const _categories = [
    'All',
    'Design',
    'Engineering',
    'Marketing',
    'Data',
    'Operations',
    'Other',
  ];
  static const _locations = ['All', 'On-campus', 'Remote', 'Hybrid'];
  static const _categoryIcons = <String, IconData>{
    'Design': Icons.palette_outlined,
    'Engineering': Icons.code_rounded,
    'Marketing': Icons.campaign_outlined,
    'Data': Icons.analytics_outlined,
    'Operations': Icons.settings_suggest_outlined,
    'Other': Icons.grid_view_rounded,
  };

  @override
  void initState() {
    super.initState();
    _verified = _authRepo.isEmailVerified;
  }

  Future<void> _recheckVerified() async {
    final v = await _authRepo.refreshAndCheckVerified();
    if (mounted) setState(() => _verified = v);
  }

  List<Opportunity> _applyFilters(List<Opportunity> list) {
    return list.where((o) {
      final matchSearch =
          _search.isEmpty ||
          o.title.toLowerCase().contains(_search.toLowerCase()) ||
          o.startupName.toLowerCase().contains(_search.toLowerCase());
      final matchCat =
          _filterCategory == 'All' || o.category == _filterCategory;
      final matchLoc =
          _filterLocation == 'All' || o.locationType == _filterLocation;
      return matchSearch && matchCat && matchLoc;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OpportunityCubit(OpportunityRepository())
            ..loadForStudent(widget.user.skills),
      child: Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              if (!_verified)
                SliverToBoxAdapter(child: _buildVerificationBanner()),
              if (widget.user.skills.isEmpty ||
                  widget.user.resumeUrl.isEmpty ||
                  widget.user.identityImageUrl.isEmpty)
                SliverToBoxAdapter(child: _buildProfileCompletionBanner()),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildCategoryBrowse()),
              SliverToBoxAdapter(child: _buildFilters()),
              BlocBuilder<OpportunityCubit, OpportunityState>(
                builder: (context, state) {
                  if (state is OpportunityLoading) return _buildShimmer();
                  if (state is OpportunityError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              state.message,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final loaded = state as OpportunityLoaded;
                  final filtered = _applyFilters(loaded.all);
                  final filteredRec = _applyFilters(loaded.recommended);

                  if (filtered.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No opportunities found',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      if (filteredRec.isNotEmpty) ...[
                        _sectionHeader(
                          'Recommended for you',
                          '${filteredRec.length} matches',
                          icon: Icons.bolt_rounded,
                        ),
                        SizedBox(
                          height: 200,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            itemCount: filteredRec.take(5).length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) {
                              final o = filteredRec[i];
                              return SizedBox(
                                    width: 280,
                                    child: OpportunityCard(
                                      opportunity: o,
                                      matchScore: SkillMatcher.score(
                                        widget.user.skills,
                                        o,
                                      ),
                                      onTap: () => _openDetail(context, o),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(delay: (i * 80).ms, duration: 400.ms)
                                  .slideX(begin: 0.1, end: 0);
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                      _sectionHeader(
                        'Recent opportunities',
                        '${filtered.length} total',
                      ),
                      ...filtered.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.md,
                          ),
                          child:
                              OpportunityCard(
                                    opportunity: e.value,
                                    onTap: () => _openDetail(context, e.value),
                                  )
                                  .animate()
                                  .fadeIn(
                                    delay: (e.key * 60).ms,
                                    duration: 350.ms,
                                  )
                                  .slideY(begin: 0.05, end: 0),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, Opportunity o) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OpportunityDetailScreen(
          opportunityId: o.opportunityId,
          user: widget.user,
        ),
      ),
    );
  }

  Widget _buildVerificationBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.mark_email_unread_outlined,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          const Expanded(
            child: Text(
              'Verify your email to secure your account.',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () async {
              await _authRepo.resendVerificationEmail();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent')),
                );
              }
            },
            child: const Text('Resend', style: TextStyle(fontSize: 12)),
          ),
          TextButton(
            onPressed: _recheckVerified,
            child: const Text("I've done it", style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 400.ms);
  }

  Widget _buildProfileCompletionBanner() {
    final u = widget.user;
    final missingRequired = <String>[
      if (u.skills.isEmpty) 'skills',
      if (u.resumeUrl.isEmpty) 'resume',
    ];

    final IconData icon;
    final Color color;
    final String text;

    if (missingRequired.isNotEmpty) {
      icon = Icons.assignment_ind_outlined;
      color = const Color(0xFFF59E0B);
      text = missingRequired.length == 2
          ? 'Add your skills and upload a resume to start applying.'
          : missingRequired.first == 'skills'
              ? 'Add your skills to start applying to opportunities.'
              : 'Upload your resume to start applying to opportunities.';
    } else {
      icon = Icons.verified_user_outlined;
      color = AppColors.primary;
      text = 'Recommended: Add your identity image for a stronger profile.';
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: widget.onProfileTap,
            child: Text(
              'Set up',
              style: TextStyle(fontSize: 12, color: color),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 80.ms, duration: 400.ms);
  }

  Widget _buildHeader(BuildContext context) {
    final firstName = widget.user.fullName.split(' ').first;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Hello, $firstName',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.waving_hand_outlined,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Find your next opportunity',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Open profile',
            child: InkWell(
              key: const Key('home_profile_button'),
              onTap: widget.onProfileTap,
              customBorder: const CircleBorder(),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primarySoft,
                backgroundImage: widget.user.photoUrl.isNotEmpty
                    ? NetworkImage(widget.user.photoUrl)
                    : null,
                child: widget.user.photoUrl.isEmpty
                    ? Text(
                        widget.user.fullName.isNotEmpty
                            ? widget.user.fullName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: TextField(
        onChanged: (v) => setState(() => _search = v),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search roles, startups...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () => setState(() => _search = ''),
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceAlt,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms, duration: 400.ms);
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          ..._categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: c,
                selected: _filterCategory == c,
                onTap: () => setState(() => _filterCategory = c),
              ),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '|',
            style: TextStyle(color: AppColors.border, fontSize: 18),
          ),
          const SizedBox(width: 12),
          ..._locations.map(
            (l) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: l,
                selected: _filterLocation == l,
                onTap: () => setState(() => _filterLocation = l),
                color: const Color(0xFF2A3A2A),
                selectedColor: AppColors.success,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
  }

  Widget _buildCategoryBrowse() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(
              'Browse by category',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: _categoryIcons.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final entry = _categoryIcons.entries.elementAt(index);
                final selected = _filterCategory == entry.key;
                return InkWell(
                  onTap: () => setState(() {
                    _filterCategory = selected ? 'All' : entry.key;
                  }),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 86,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primarySoft
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(
                        color: selected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          entry.value,
                          color: selected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          entry.key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 130.ms, duration: 400.ms);
  }

  Widget _sectionHeader(String title, String subtitle, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: AppColors.primary),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => Shimmer.fromColors(
          baseColor: AppColors.surface,
          highlightColor: AppColors.surfaceAlt,
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
        ),
        childCount: 5,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;
  final Color? selectedColor;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final sel = selectedColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? sel.withValues(alpha: 0.15) : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? sel : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? sel : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
