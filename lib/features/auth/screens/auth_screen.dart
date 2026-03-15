import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

enum _AuthMode { login, register }

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _ageFocusNode = FocusNode();
  bool _ageFocused = false;

  _AuthMode _mode = _AuthMode.login;
  bool _obscurePassword = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
    _animCtrl.forward();
    _ageFocusNode.addListener(() {
      setState(() => _ageFocused = _ageFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _ageCtrl.dispose();
    _ageFocusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleMode() {
    _animCtrl.reverse().then((_) {
      setState(() {
        _mode = _mode == _AuthMode.login ? _AuthMode.register : _AuthMode.login;
        ref.read(authProvider.notifier).clearError();
      });
      _animCtrl.forward();
    });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final notifier = ref.read(authProvider.notifier);
    bool success;
    if (_mode == _AuthMode.login) {
      success = await notifier.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
    } else {
      success = await notifier.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        age: int.tryParse(_ageCtrl.text),
      );
    }
    if (success && mounted) context.go('/editor');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLogin = _mode == _AuthMode.login;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xxl,
              AppSpacing.lg,
              AppSpacing.xxl +
                  (_ageFocused ? MediaQuery.of(context).viewInsets.bottom : 0),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isLogin ? 'Welcome back.' : 'Create account.',
                    style: AppTextStyles.displayLarge.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    isLogin
                        ? 'Sign in to manage your XRay configs'
                        : 'Join to start building configs',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _buildField(
                    controller: _emailCtrl,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    obscureText: _obscurePassword,
                    suffix: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? CupertinoIcons.eye
                            : CupertinoIcons.eye_slash,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                        size: 20,
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return 'Min 6 characters bestie';
                      }
                      return null;
                    },
                  ),
                  if (!isLogin) ...[
                    const SizedBox(height: AppSpacing.md),
                    _buildField(
                      controller: _ageCtrl,
                      label: 'Age (optional)',
                      keyboardType: TextInputType.number,
                      focusNode: _ageFocusNode,
                    ),
                  ],
                  if (authState.error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    _ErrorBanner(message: authState.error!),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  _SubmitButton(
                    label: isLogin ? 'Sign in' : 'Create account',
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Center(
                    child: CupertinoButton(
                      onPressed: _toggleMode,
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                          ),
                          children: [
                            TextSpan(
                              text: isLogin
                                  ? 'No account? '
                                  : 'Already got one? ',
                            ),
                            TextSpan(
                              text: isLogin ? 'Sign up' : 'Sign in',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
    FocusNode? focusNode,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 52,
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLines: 1,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            validator: validator,
            decoration: InputDecoration(
              suffixIcon: suffix != null
                  ? Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: suffix,
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 52,
              ),
              hintStyle: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withOpacity(0.35),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.errorRed.withOpacity(AppOpacity.light),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.errorRed.withOpacity(AppOpacity.medium),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle,
            color: AppColors.errorRed,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLoading ? AppOpacity.strong : AppOpacity.full,
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }
}
