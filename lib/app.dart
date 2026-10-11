import 'dart:async';

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
import 'services/fcm_service.dart';
import 'services/firestore_service.dart';
import 'services/local_notification_service.dart';
import 'services/notification_service.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalNotificationService>(
          create: (_) => LocalNotificationService(),
          dispose: (_, service) => service.dispose(),
        ),
        Provider<FcmService>(
          lazy: false,
          create: (context) {
            final service = FcmService(
              localNotifications: context.read<LocalNotificationService>(),
            );
            unawaited(service.initialize());
            return service;
          },
          dispose: (_, service) => service.dispose(),
        ),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (context) => TaskProvider(
            context.read<FirestoreService>(),
            context.read<LocalNotificationService>(),
          ),
          update: (_, auth, tasks) => tasks!..updateUser(auth.user?.uid),
        ),
        Provider<NotificationService>(
          lazy: false,
          create: (context) => NotificationService(
            fcm: context.read<FcmService>(),
            local: context.read<LocalNotificationService>(),
            firestore: context.read<FirestoreService>(),
            auth: context.read<AuthProvider>(),
          )..start(),
          dispose: (_, service) => service.dispose(),
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