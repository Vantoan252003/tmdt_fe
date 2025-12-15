import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final User user;
  const ProfileEditScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final updatedUser = User(
      id: widget.user.id,
      role: widget.user.role,
      fullName: _nameController.text.trim(),
      email: widget.user.email,
      phone: _phoneController.text.trim(),
    );

    final result = await AuthService.updateUserInfo(updatedUser);

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['success']
              ? 'Cập nhật thông tin thành công! 🎉'
              : result['message'] ?? 'Đã có lỗi xảy ra',
        ),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );

    if (result['success']) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Chỉnh sửa thông tin",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEE4D2D), Color(0xFFFF7043)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),

      // ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar
            Container(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFEE4D2D), Color(0xFFFFA36C)],
                  ),
                ),
                child: const CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 55, color: Color(0xFFEE4D2D)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Card form
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInput(
                        controller: _nameController,
                        label: "Họ và tên",
                        icon: Icons.person,
                        validatorMsg: "Vui lòng nhập họ tên",
                      ),
                      _buildInput(
                        controller: _emailController,
                        label: "Email đăng nhập",
                        icon: Icons.email,
                        enabled: false,
                      ),
                      _buildInput(
                        controller: _phoneController,
                        label: "Số điện thoại",
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validatorMsg: "Vui lòng nhập số điện thoại hợp lệ",
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Button Update
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [Color(0xFFEE4D2D), Color(0xFFFF7043)],
                ),
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Cập nhật",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CUSTOM INPUT ----------------
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    String? validatorMsg,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Color(0xFFEE4D2D)),
          labelText: label,
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey.shade200,
          labelStyle: const TextStyle(color: Colors.black54),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEE4D2D), width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        validator: validatorMsg == null
            ? null
            : (value) => value!.trim().isEmpty ? validatorMsg : null,
      ),
    );
  }
}
