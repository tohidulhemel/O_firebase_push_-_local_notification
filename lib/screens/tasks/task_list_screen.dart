import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tasks', style: AppTextStyles.heading),
              const SizedBox(height: 8),
              Text(
                'Signed in as ${auth.user?.email ?? 'unknown'}',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Log out',
                variant: AppButtonVariant.outlined,
                isLoading: auth.isLoading,
                leading: const Icon(Icons.logout, size: 20),
                onPressed: auth.signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}