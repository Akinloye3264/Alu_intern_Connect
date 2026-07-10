import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../../models/opportunity.dart';

class OpportunityCard extends StatefulWidget {
  final Opportunity opportunity;
  final VoidCallback? onTap;
  final double? matchScore;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    this.onTap,
    this.matchScore,
  });

  @override
  State<OpportunityCard> createState() => _OpportunityCardState();
}

class _OpportunityCardState extends State<OpportunityCard> {
  bool _bookmarked = false;

  @override
  Widget build(BuildContext context) {
    final o = widget.opportunity;
    final score = widget.matchScore;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: score != null && score > 0.5
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      o.startupName.isNotEmpty
                          ? o.startupName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                        o.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        o.startupName,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _bookmarked = !_bookmarked),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _bookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      key: ValueKey(_bookmarked),
                      color: _bookmarked
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _chip(o.category, Icons.category_outlined),
                _chip(o.locationType, Icons.location_on_outlined),
                _chip(o.commitment, Icons.schedule_outlined),
              ],
            ),
            if (score != null && score > 0) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: score,
                        backgroundColor: AppColors.surfaceAlt,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          score >= 0.7
                              ? AppColors.success
                              : score >= 0.4
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(score * 100).round()}% match',
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, IconData icon) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: AppColors.textSecondary),
          const SizedBox(width: 4),
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
}
