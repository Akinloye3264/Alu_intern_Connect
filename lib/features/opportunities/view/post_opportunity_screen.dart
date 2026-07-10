import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../models/app_user.dart';
import '../../../models/opportunity.dart';
import '../../../repositories/opportunity_repository.dart';

class PostOpportunityScreen extends StatefulWidget {
  final AppUser user;
  const PostOpportunityScreen({super.key, required this.user});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _skillsCtrl = TextEditingController();
  final _repo = OpportunityRepository();

  static const _categories = [
    'Design',
    'Engineering',
    'Marketing',
    'Data',
    'Operations',
    'Other',
  ];
  static const _commitments = [
    'Part-time (4–6 hrs/week)',
    'Part-time (8–10 hrs/week)',
    'Full-time',
    'Flexible',
  ];
  static const _locations = ['On-campus', 'Remote', 'Hybrid'];

  String _category = 'Engineering';
  String _commitment = 'Part-time (8–10 hrs/week)';
  String _location = 'On-campus';
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final skills = _skillsCtrl.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final opp = Opportunity(
      opportunityId: '',
      startupId: widget.user.uid,
      startupName: widget.user.fullName,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      category: _category,
      skillsRequired: skills,
      commitment: _commitment,
      locationType: _location,
      createdAt: DateTime.now(),
    );

    try {
      await _repo.post(opp).timeout(const Duration(seconds: 15));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Opportunity posted')));
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to post: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post an opportunity')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Flutter Developer',
                  ),
                  validator: (v) => Validators.notEmpty(v, 'Title'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'What will the intern work on?',
                    alignLabelWithHint: true,
                  ),
                  validator: (v) => Validators.notEmpty(v, 'Description'),
                ),
                const SizedBox(height: AppSpacing.md),
                _dropdown(
                  'Category',
                  _category,
                  _categories,
                  (v) => setState(() => _category = v!),
                ),
                const SizedBox(height: AppSpacing.md),
                _dropdown(
                  'Commitment',
                  _commitment,
                  _commitments,
                  (v) => setState(() => _commitment = v!),
                ),
                const SizedBox(height: AppSpacing.md),
                _dropdown(
                  'Location',
                  _location,
                  _locations,
                  (v) => setState(() => _location = v!),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _skillsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Skills required',
                    hintText: 'Comma-separated, e.g. Flutter, Dart, Firebase',
                  ),
                  validator: (v) => Validators.notEmpty(v, 'Skills'),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Skills are used to recommend this to matching students.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Post opportunity',
                  isLoading: _submitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      dropdownColor: AppColors.surface,
      items: options
          .map((o) => DropdownMenuItem(value: o, child: Text(o)))
          .toList(),
      onChanged: onChanged,
    );
  }
}
