import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/neo_brutalist_decorations.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback? onAuthSuccess;

  const AuthScreen({super.key, this.onAuthSuccess});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController(text: 'Bruce Wayne');
  final _emailController =
      TextEditingController(text: 'brucewayne27@suarasa.com');
  final _passwordController = TextEditingController(text: '••••••••');
  bool _agreedToTerms = true;
  bool _isSignUp = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.onAuthSuccess != null) {
      widget.onAuthSuccess!();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Back Button
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    widget.onAuthSuccess?.call();
                  }
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: NeoBrutalist.iconButton(),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Row(
                children: [
                  Text(
                    _isSignUp ? 'Create Account' : 'Welcome Back',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 24)),
                ],
              ),

              const SizedBox(height: 10),

              // Subtitle
              const Text(
                'Please register on our Streamline, where you can continue using our service.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 32),

              // Full Name input
              if (_isSignUp) ...[
                _buildNeoInput(
                  controller: _nameController,
                  hintText: 'Full Name',
                ),
                const SizedBox(height: 18),
              ],

              // Email input
              _buildNeoInput(
                controller: _emailController,
                hintText: 'Email address',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 18),

              // Password input
              _buildNeoInput(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
              ),

              const SizedBox(height: 20),

              // Terms & Conditions Checkbox
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _agreedToTerms ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppColors.borderBlack,
                          width: 1.5,
                        ),
                      ),
                      child: _agreedToTerms
                          ? const Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'I agree to privacy policy & terms',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Continue Button
              GestureDetector(
                onTap: _submit,
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x35FA6551),
                        offset: Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isSignUp ? 'Continue' : 'Sign In',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // "Or" Divider
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFE2E4E8),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      'Or',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: const Color(0xFFE2E4E8),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Social Login Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSocialButton(
                    onTap: _submit,
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFEA4335),
                      ),
                    ),
                  ),
                  _buildSocialButton(
                    onTap: _submit,
                    child: const Icon(
                      Icons.apple,
                      size: 26,
                      color: Colors.black,
                    ),
                  ),
                  _buildSocialButton(
                    onTap: _submit,
                    child: const Text(
                      'f',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1877F2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Footer toggle
              Center(
                child: GestureDetector(
                  onTap: () => setState(() => _isSignUp = !_isSignUp),
                  child: RichText(
                    text: TextSpan(
                      text: _isSignUp
                          ? 'Already have an account? '
                          : "Don't have an account? ",
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: _isSignUp ? 'Sign in instead' : 'Sign up',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNeoInput({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: NeoBrutalist.card(
        borderRadius: 16,
        borderWidth: 1.5,
        shadowOffset: const Offset(0, 3.5),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 14,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        height: 52,
        decoration: NeoBrutalist.card(
          borderRadius: 16,
          borderWidth: 1.5,
          shadowOffset: const Offset(0, 3),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
