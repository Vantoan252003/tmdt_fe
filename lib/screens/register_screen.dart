import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      _emailController.text.trim(),
      _fullNameController.text.trim(),
      _phoneController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor:
            result['success'] ? AppTheme.successColor : AppTheme.errorColor,
      ),
    );

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              _buildRegisterForm(),
              const SizedBox(height: 24),
              _buildLoginLink(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // HEADER
  // ---------------------------------------------------------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEE4D2D), Color(0xFFFF6347)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Tạo tài khoản mới",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Đăng ký để bắt đầu mua sắm dụng cụ học tập",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // FORM
  // ---------------------------------------------------------
  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField(
              controller: _fullNameController,
              label: "Họ và tên",
              hint: "Nhập họ và tên đầy đủ",
              icon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.isEmpty) return "Vui lòng nhập họ tên";
                if (v.length < 2) return "Họ tên phải có ít nhất 2 ký tự";
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _emailController,
              label: "Email",
              hint: "Nhập email của bạn",
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return "Vui lòng nhập email";
                if (!RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(v)) {
                  return "Email không hợp lệ";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _phoneController,
              label: "Số điện thoại",
              hint: "Nhập số điện thoại",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.isEmpty) return "Vui lòng nhập số điện thoại";
                if (!RegExp(r"^[0-9]{10,11}$").hasMatch(v)) {
                  return "Số điện thoại không hợp lệ";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _passwordController,
              label: "Mật khẩu",
              hint: "Ít nhất 6 ký tự",
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return "Vui lòng nhập mật khẩu";
                if (v.length < 6) return "Mật khẩu phải ít nhất 6 ký tự";
                return null;
              },
            ),
            const SizedBox(height: 20),

            _buildTextField(
              controller: _confirmPasswordController,
              label: "Xác nhận mật khẩu",
              hint: "Nhập lại mật khẩu",
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppTheme.primaryColor,
                ),
                onPressed: () => setState(() =>
                    _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return "Vui lòng xác nhận mật khẩu";
                }
                if (v != _passwordController.text) {
                  return "Mật khẩu xác nhận không khớp";
                }
                return null;
              },
            ),
            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE4D2D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey[400],
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      "ĐĂNG KÝ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------
  // TEXTFIELD TEMPLATE
  // ---------------------------------------------------------
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFEE4D2D), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------
  // LOGIN LINK
  // ---------------------------------------------------------
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Đã có tài khoản? ",
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text(
            "Đăng nhập",
            style: TextStyle(
              color: Color(0xFFEE4D2D),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
