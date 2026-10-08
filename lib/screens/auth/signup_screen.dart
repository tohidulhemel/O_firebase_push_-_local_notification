import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/error_message.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final success = await context.read<AuthProvider>().signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
    // Firebase signs the new user in automatically. The auth gate swaps its
    // home screen, so remove this pushed route to reveal it.
    if (success && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final busy = auth.isLoading;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.pagePadding,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.textSecondary),
                          onPressed:
                              busy ? null : () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const AuthHeader(
                        title: 'Create Account',
                        subtitle: 'Sign up to start managing your tasks',
                      ),
                      const SizedBox(height: 32),
                      AppTextField(
                        label: 'Email address',
                        controller: _emailController,
                        hint: 'you@example.com',
                        enabled: !busy,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Password',
                        controller: _passwordController,
                        hint: 'At least 6 characters',
                        isPassword: true,
                        enabled: !busy,
                        textInputAction: TextInputAction.next,
                        validator: Validators.newPassword,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Confirm password',
                        controller: _confirmController,
                        hint: 'Re-enter your password',
                        isPassword: true,
                        enabled: !busy,
                        textInputAction: TextInputAction.done,
                        validator:
                            Validators.confirmPassword(_passwordController),
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      if (auth.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        ErrorMessage(message: auth.errorMessage!),
                      ],
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Create Account',
                        isLoading: busy,
                        onPressed: busy ? null : _submit,
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ',
                              style: AppTextStyles.subtitle),
                          GestureDetector(
                            onTap:
                                busy ? null : () => Navigator.of(context).pop(),
                            child: Text('Sign In',
                                style: AppTextStyles.link
                                    .copyWith(fontSize: 15)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}