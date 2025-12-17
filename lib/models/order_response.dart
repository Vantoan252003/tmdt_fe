import 'package:flutter/material.dart';

class OrderResponse {
  final String orderId;
  final String userId;
  final String shopId;
  final String orderCode;
  final double totalAmount;
  final double shippingFee;
  final double discountAmount;
  final double finalAmount;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String shippingAddress;
  final String recipientName;
  final String recipientPhone;
  final String? note;
  final String createdAt;
  final String updatedAt;
  final bool canConfirmDelivery;
  final String? deliveryProofImage;

  OrderResponse({
    required this.orderId,
    required this.userId,
    required this.shopId,
    required this.orderCode,
    required this.totalAmount,
    required this.shippingFee,
    required this.discountAmount,
    required this.finalAmount,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.shippingAddress,
    required this.recipientName,
    required this.recipientPhone,
    this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.canConfirmDelivery,
    this.deliveryProofImage,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    return OrderResponse(
      orderId: json['orderId'] ?? '',
      userId: json['userId'] ?? '',
      shopId: json['shopId'] ?? '',
      orderCode: json['orderCode'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      shippingFee: (json['shippingFee'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      shippingAddress: json['shippingAddress'] ?? '',
      recipientName: json['recipientName'] ?? '',
      recipientPhone: json['recipientPhone'] ?? '',
      note: json['note'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      canConfirmDelivery: json['canConfirmDelivery'] ?? false,
      deliveryProofImage: json['deliveryProofImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'shopId': shopId,
      'orderCode': orderCode,
      'totalAmount': totalAmount,
      'shippingFee': shippingFee,
      'discountAmount': discountAmount,
      'finalAmount': finalAmount,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'shippingAddress': shippingAddress,
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'note': note,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'canConfirmDelivery': canConfirmDelivery,
      'deliveryProofImage': deliveryProofImage,
    };
  }

  // Helper method to get status display
  String getStatusDisplay() {
    switch (status) {
      case 'PENDING':
        return 'Chờ xử lý';
      case 'CONFIRMED':
        return 'Đã xác nhận';
      case 'SHIPPING':
        return 'Đang giao';
      case 'DELIVERED':
        return 'Đã giao';
      case 'CANCELLED':
        return 'Đã hủy';
      case 'RETURNED':
        return 'Đã hoàn trả';
      default:
        return status;
    }
  }

  // Helper method to get payment status display
  String getPaymentStatusDisplay() {
    switch (paymentStatus) {
      case 'UNPAID':
        return 'Chưa thanh toán';
      case 'PAID':
        return 'Đã thanh toán';
      case 'REFUNDED':
        return 'Đã hoàn tiền';
      default:
        return paymentStatus;
    }
  }

  // Helper method to get status color
  getStatusColor() {
    switch (status) {
      case 'PENDING':
        return const Color(0xFFFFA500); // Orange
      case 'CONFIRMED':
        return const Color(0xFF2196F3); // Blue
      case 'SHIPPING':
        return const Color(0xFF9C27B0); // Purple
      case 'DELIVERED':
        return const Color(0xFF4CAF50); // Green
      case 'CANCELLED':
        return const Color(0xFFF44336); // Red
      case 'RETURNED':
        return const Color(0xFF757575); // Grey
      default:
        return const Color(0xFF757575);
    }
  }
}
