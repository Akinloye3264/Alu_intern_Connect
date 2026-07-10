import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'repositories/auth_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/cubit/auth_state.dart';
import 'features/auth/view/login_screen.dart';
import 'features/auth/view/verification_screen.dart';
import 'features/home/view/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const AluInternApp());
}

class AluInternApp extends StatelessWidget {
  const AluInternApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => AuthRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (ctx) => AuthCubit(ctx.read<AuthRepository>())),
          BlocProvider(create: (_) => ThemeCubit()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, mode) {
            return MaterialApp(
              key: ValueKey(mode),
              title: 'ALU Intern Connect',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: mode,
              home: const AuthGate(),
            );
          },
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) return const HomeScreen();
        if (state is StartupVerificationPending) {
          return VerificationScreen.startup(status: state.status);
        }
        if (state is AuthLoading || state is AuthInitial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const LoginScreen();
      },
    );
  }
}
