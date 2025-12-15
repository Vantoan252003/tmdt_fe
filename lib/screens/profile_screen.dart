import 'package:flutter/material.dart';
import 'package:student_ecommerce/screens/address_screen.dart';
import 'package:student_ecommerce/screens/profile_edit_screen.dart';
import 'package:student_ecommerce/screens/orders_screen.dart';
import 'package:student_ecommerce/screens/notification_screen.dart';
import '../utils/app_theme.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getUserData();
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải thông tin người dùng')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // LOADING SCREEN
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFFEE4D2D))),
      );
    }

    // ERROR SCREEN
    if (_user == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Không thể tải thông tin", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadUserData, child: const Text("Thử lại")),
            ],
          ),
        ),
      );
    }

    // MAIN SCREEN
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              
              // ---------------- HEADER ----------------
              _buildProfileHeader(_user!),
              const SizedBox(height: 20),

              // ---------------- MENU ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildMenuSection(
                      title: "Tài khoản",
                      items: [
                        _MenuItem(
                          icon: Icons.person_outline,
                          title: "Thông tin cá nhân",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProfileEditScreen(user: _user!),
                              ),
                            );
                          },
                        ),
                        _MenuItem(
                          icon: Icons.location_on_outlined,
                          title: "Địa chỉ giao hàng",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddressScreen()),
                          ),
                        ),
                        _MenuItem(
                          icon: Icons.payment_outlined,
                          title: "Phương thức thanh toán",
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _buildMenuSection(
                      title: "Đơn hàng",
                      items: [
                        _MenuItem(
                          icon: Icons.shopping_bag_outlined,
                          title: "Đơn hàng của tôi",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OrdersScreen()),
                          ),
                        ),
                        _MenuItem(
                          icon: Icons.favorite_border,
                          title: "Sản phẩm yêu thích",
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.rate_review_outlined,
                          title: "Đánh giá của tôi",
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _buildMenuSection(
                      title: "Hỗ trợ",
                      items: [
                        _MenuItem(
                          icon: Icons.help_outline,
                          title: "Trung tâm trợ giúp",
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.info_outline,
                          title: "Về chúng tôi",
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.privacy_tip_outlined,
                          title: "Chính sách & Điều khoản",
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _buildMenuSection(
                      title: "Cài đặt",
                      items: [
                        _MenuItem(
                          icon: Icons.notifications_outlined,
                          title: "Thông báo",
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationScreen()),
                          ),
                        ),
                        _MenuItem(
                          icon: Icons.language_outlined,
                          title: "Ngôn ngữ",
                          onTap: () {},
                        ),
                        _MenuItem(
                          icon: Icons.dark_mode_outlined,
                          title: "Chế độ tối",
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // LOGOUT BUTTON
                    _buildLogoutButton(context),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER UI ----------------
  Widget _buildProfileHeader(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEE4D2D), Color(0xFFFF7043)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Avatar với viền gradient
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.white, Colors.white],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white,
              child: Text(
                user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : "U",
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEE4D2D),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Name
          Text(
            user.fullName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Email
          Text(
            user.email,
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 25),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem("Đơn hàng", "12"),
              _dividerLine(),
              _buildStatItem("Yêu thích", "34"),
              _dividerLine(),
              _buildStatItem("Đánh giá", "8"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dividerLine() => Container(
        height: 40,
        width: 1.2,
        color: Colors.white38,
      );

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  // ---------------- MENU SECTIONS ----------------
  Widget _buildMenuSection({
    required String title,
    required List<_MenuItem> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        ...items.map(_buildMenuItem),
      ]),
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE5DB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: const Color(0xFFEE4D2D)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.title,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // ---------------- LOGOUT BUTTON ----------------
  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Đăng xuất"),
            content: const Text("Bạn có chắc muốn đăng xuất?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hủy"),
              ),
              TextButton(
                onPressed: () async {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                  await AuthService.logout();

                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
                child: const Text("Đăng xuất",
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.redAccent],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text(
            "Đăng xuất",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.title, required this.onTap});
}
