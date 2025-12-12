import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../screens/home_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/navigation_provider.dart';
import '../providers/notification_provider.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {

  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    NotificationScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Delay cart loading until after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartItems();
      _loadUnreadNotifications();
    });
  }

  Future<void> _loadCartItems() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.loadCartItems();
  }

  Future<void> _loadUnreadNotifications() async {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    await notificationProvider.loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          body: _screens[navProvider.currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Trang chủ',
                  index: 0,
                ),
                _buildNavItem(
                  icon: Icons.shopping_cart_outlined,
                  activeIcon: Icons.shopping_cart,
                  label: 'Giỏ hàng',
                  index: 1,
                  showBadge: true,
                ),
                  _buildNavItem(
                  icon: Icons.notifications_outlined,
                  activeIcon: Icons.notifications,
                  label: 'Thông báo',
                  index: 2,
                  showBadge: true,
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Cá nhân',
                  index: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  );
}
  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    bool showBadge = false,
  }) {
    final navProvider = Provider.of<NavigationProvider>(context, listen: false);
    final isActive = navProvider.currentIndex == index;

    return GestureDetector(
      onTap: () {
        navProvider.setIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isActive ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? Colors.white : AppTheme.textLight,
                  size: 24,
                ),
                if (showBadge)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: index == 1
                        ? Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
                              if (cartProvider.itemCount == 0) {
                                return const SizedBox();
                              }
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.errorColor,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${cartProvider.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          )
                        : Consumer<NotificationProvider>(
                            builder: (context, notificationProvider, child) {
                              if (notificationProvider.unreadCount == 0) {
                                return const SizedBox();
                              }
                              return Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.errorColor,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 18,
                                  minHeight: 18,
                                ),
                                child: Text(
                                  '${notificationProvider.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            },
                          ),
                  ),
              ],
            ),
          
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : AppTheme.textLight,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
