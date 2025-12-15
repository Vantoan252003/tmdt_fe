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
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 60,
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
                      label: 'Tôi',
                      index: 3,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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
        padding: const EdgeInsets.symmetric(horizontal: 12),
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? const Color(0xFFEE4D2D) : Colors.grey[600],
                  size: 26,
                ),
                if (showBadge)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: index == 1
                        ? Consumer<CartProvider>(
                            builder: (context, cartProvider, child) {
                              if (cartProvider.itemCount == 0) {
                                return const SizedBox();
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEE4D2D),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  cartProvider.itemCount > 99 
                                      ? '99+' 
                                      : '${cartProvider.itemCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEE4D2D),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  notificationProvider.unreadCount > 99 
                                      ? '99+' 
                                      : '${notificationProvider.unreadCount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFEE4D2D) : Colors.grey[600],
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}