import 'package:flutter/material.dart';

class Notification {
  final String notificationId;
  final String userId;
  final String title;
  final String message;
  final String? type;
  final String? referenceId;
  final bool isRead;
  final String createdAt;
  final String? readAt;

  Notification({
    required this.notificationId,
    required this.userId,
    required this.title,
    required this.message,
    this.type,
    this.referenceId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'],
      referenceId: json['referenceId'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? '',
      readAt: json['readAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'title': title,
      'message': message,
      'type': type,
      'referenceId': referenceId,
      'isRead': isRead,
      'createdAt': createdAt,
      'readAt': readAt,
    };
  }

  String get timeAgo {
    try {
      final createdDateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdDateTime);

      if (difference.inSeconds < 60) {
        return 'Vừa xong';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}p trước';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h trước';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d trước';
      } else {
        return createdDateTime.toString().split(' ')[0];
      }
    } catch (e) {
      return createdAt;
    }
  }

  IconData get typeIcon {
    final typeStr = type?.toUpperCase() ?? '';
    if (typeStr.contains('ORDER')) {
      return Icons.shopping_bag_outlined;
    } else if (typeStr.contains('DELIVERY') || typeStr.contains('SHIPPING')) {
      return Icons.local_shipping_outlined;
    } else if (typeStr.contains('PROMO')) {
      return Icons.local_offer_outlined;
    } else if (typeStr.contains('REVIEW')) {
      return Icons.star_outline;
    } else if (typeStr.contains('PAYMENT')) {
      return Icons.payment;
    }
    return Icons.notifications_outlined;
  }

  Color get typeColor {
    final typeStr = type?.toUpperCase() ?? '';
    if (typeStr.contains('ORDER')) {
      return const Color(0xFF667eea);
    } else if (typeStr.contains('DELIVERY') || typeStr.contains('SHIPPING')) {
      return const Color(0xFF48BB78);
    } else if (typeStr.contains('PROMO')) {
      return const Color(0xFFF6AD55);
    } else if (typeStr.contains('REVIEW')) {
      return const Color(0xFFFBBF24);
    } else if (typeStr.contains('PAYMENT')) {
      return const Color(0xFFED8936);
    }
    return const Color(0xFFA0AEC0);
  }
}
