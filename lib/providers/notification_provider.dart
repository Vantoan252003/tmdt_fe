import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  bool _isLoading = false;

  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadUnreadCount() async {
    try {
      _isLoading = true;
      notifyListeners();

      final count = await _notificationService.getUnreadCount();
      _unreadCount = count;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  void resetUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}