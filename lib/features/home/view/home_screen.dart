import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/app_user.dart';
import '../../auth/cubit/auth_cubit.dart';
import '../../auth/cubit/auth_state.dart';
import 'student_shell.dart';
import 'startup_home_screen.dart';
import '../../admin/view/admin_startups_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = state.user;
        return switch (user.role) {
          UserRole.admin => AdminStartupsScreen(user: user),
          UserRole.startup => StartupHomeScreen(user: user),
          UserRole.student => StudentShell(user: user),
        };
      },
    );
  }
}
