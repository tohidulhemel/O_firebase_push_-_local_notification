import 'package:firebase_push_local_notification/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/google_sign_in_button.dart';
import '../../widgets/auth/or_divider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/error_message.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _usingGoogle = false;

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
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await context.read<AuthProvider>().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Future<void> _signInWithGoogle() async {
    FocusScope.of(context).unfocus();
    setState(() => _usingGoogle = true);
    await context.read<AuthProvider>().signInWithGoogle();
    if (mounted) setState(() => _usingGoogle = false);
  }

  Future<void> _forgotPassword() async {
    if (Validators.email(_emailController.text) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid email address first.')),
      );
      return;
    }
    final sent = await context
        .read<AuthProvider>()
        .sendPasswordReset(_emailController.text);
    if (sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
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
                      const SizedBox(height: 56),
                      const AuthHeader(
                        title: 'Welcome Back',
                        subtitle: 'Sign in to your Firebase Task Manager',
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
                        hint: 'Enter your password',
                        isPassword: true,
                        enabled: !busy,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        validator: Validators.requiredPassword,
                        onFieldSubmitted: (_) => _submit(),
                        labelTrailing: GestureDetector(
                          onTap: busy ? null : _forgotPassword,
                          child: Text('Forgot Password?',
                              style: AppTextStyles.link),
                        ),
                      ),
                      if (auth.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        ErrorMessage(message: auth.errorMessage!),
                      ],
                      const SizedBox(height: 20),
                      AppButton(
                        label: 'Sign In',
                        isLoading: busy && !_usingGoogle,
                        onPressed: busy ? null : _submit,
                        trailing: const Icon(Icons.arrow_forward,
                            color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 24),
                      const OrDivider(),
                      const SizedBox(height: 24),
                      GoogleSignInButton(
                        isLoading: busy && _usingGoogle,
                        onPressed: busy ? null : _signInWithGoogle,
                      ),
                      const Spacer(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: AppTextStyles.subtitle),
                          GestureDetector(
                            onTap: busy
                                ? null
                                : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    ),
                            child: Text('Sign Up',
                                style: AppTextStyles.link
                                    .copyWith(fontSize: 15)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Flutter  •  Firebase Auth',
                          style: AppTextStyles.caption),
                      const SizedBox(height: 16),
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