import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/routes/app_navigator.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/tasks/task_list_screen.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        // TaskProvider follows the signed-in user: it listens to that user's
        // tasks and clears them on logout.
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (_) => TaskProvider(FirestoreService()),
          update: (_, auth, tasks) => tasks!..updateUser(auth.user?.uid),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorKey: navigatorKey,
        home: const _AuthGate(),
      ),
    );
  }
}

/// Chooses the home screen from the Firebase Auth state:
/// restoring session -> splash, signed in -> task list, otherwise -> login.
/// The splash is kept on screen for a minimum time so it is actually visible.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  static const Duration _minSplashDuration = Duration(seconds: 2);

  bool _splashTimeElapsed = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(_minSplashDuration, () {
      if (mounted) setState(() => _splashTimeElapsed = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!_splashTimeElapsed || !auth.isInitialized) {
      return const SplashScreen();
    }
    return auth.isAuthenticated ? const TaskListScreen() : const LoginScreen();
  }
}