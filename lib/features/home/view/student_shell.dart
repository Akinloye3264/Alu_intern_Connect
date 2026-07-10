import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/app_user.dart';
import '../../applications/view/my_applications_screen.dart';
import '../../profile/profile_screen.dart';
import 'student_home_screen.dart';

class StudentShell extends StatefulWidget {
  final AppUser user;
  const StudentShell({super.key, required this.user});

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  int _index = 0;

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileScreen(user: widget.user)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      StudentHomeScreen(user: widget.user, onProfileTap: _openProfile),
      MyApplicationsScreen(user: widget.user),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.primarySoft,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(
                Icons.home_rounded,
                color: AppColors.primary,
              ),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.assignment_outlined,
                color: AppColors.textSecondary,
              ),
              selectedIcon: Icon(
                Icons.assignment_rounded,
                color: AppColors.primary,
              ),
              label: 'Applications',
            ),
          ],
        ),
      ),
    );
  }
}
