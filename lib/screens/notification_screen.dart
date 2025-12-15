import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../models/notification.dart' as notif_model;
import '../providers/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  late Future<List<notif_model.Notification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    setState(() {
      _notificationsFuture = _notificationService.getNotifications();
    });
  }

  Future<void> _markAsRead(String id) async {
    try {
      await _notificationService.markAsRead(id);
      Provider.of<NotificationProvider>(context, listen: false)
          .decrementUnreadCount();
      _loadNotifications();
    } catch (_) {}
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationService.markAllAsRead();
      Provider.of<NotificationProvider>(context, listen: false)
          .resetUnreadCount();
      _loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Đã đánh dấu tất cả là đã đọc")
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {}
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _notificationService.deleteNotification(id);
      _loadNotifications();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Đã xóa thông báo")
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {}
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.delete_outline, color: Colors.red, size: 28),
            SizedBox(width: 12),
            Text("Xóa thông báo",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: const Text(
          "Bạn có chắc chắn muốn xóa thông báo này?",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Hủy",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
              _deleteNotification(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEE4D2D),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: FutureBuilder<List<notif_model.Notification>>(
                future: _notificationsFuture,
                builder: (context, snapshot) {
                  // Loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFEE4D2D)),
                      ),
                    );
                  }

                  // Error
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  final notifications = snapshot.data ?? [];

                  // Empty
                  if (notifications.isEmpty) {
                    return _buildEmptyState();
                  }

                  // List
                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        itemBuilder: (_, i) =>
                            _buildNotificationItem(notifications[i]),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  // ------------------------ UI COMPONENTS ------------------------

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 110,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEE4D2D), Color(0xFFFF6347)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "Thông báo",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                FutureBuilder<List<notif_model.Notification>>(
                  future: _notificationsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData &&
                        snapshot.data!.any((n) => !n.isRead)) {
                      return GestureDetector(
                        onTap: _markAllAsRead,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.done_all,
                                  color: Colors.white, size: 18),
                              SizedBox(width: 6),
                              Text("Đọc hết",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(notif_model.Notification n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: n.isRead ? Colors.grey.shade200 : const Color(0xFFEE4D2D),
            width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ICON
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  n.typeColor.withOpacity(0.85),
                  n.typeColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(n.typeIcon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),

          // TEXT
          Expanded(
            child: InkWell(
              onTap: () {
                if (!n.isRead) _markAsRead(n.notificationId);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                n.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (!n.isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFFEE4D2D), Color(0xFFFF6347)],
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        n.timeAgo,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // MENU
          PopupMenuButton(
            padding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == "read" && !n.isRead) {
                _markAsRead(n.notificationId);
              } else if (value == "delete") {
                _showDeleteConfirmation(n.notificationId);
              }
            },
            itemBuilder: (_) => [
              if (!n.isRead)
                const PopupMenuItem(
                  value: "read",
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: Color(0xFFEE4D2D)),
                      SizedBox(width: 10),
                      Text("Đánh dấu đã đọc")
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: "delete",
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Xóa thông báo")
                  ],
                ),
              ),
            ],
            icon: Icon(Icons.more_horiz, color: Colors.grey[600]),
          )
        ],
      ),
    );
  }

  // ------------------- EMPTY + ERROR UI -------------------

  Widget _buildEmptyState() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Icon(Icons.notifications_off_outlined,
                size: 80, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          const Text(
            "Chưa có thông báo",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Các thông báo từ hệ thống và đơn hàng\nsẽ hiển thị tại đây.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          )
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 70, color: Colors.red.shade400),
            const SizedBox(height: 16),
            const Text(
              "Đã xảy ra lỗi",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(error,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadNotifications,
              icon: const Icon(Icons.refresh),
              label: const Text("Thử lại"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE4D2D),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
