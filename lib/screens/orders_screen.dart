import 'package:flutter/material.dart';
import '../models/order_response.dart';
import '../services/order_service.dart';
import '../utils/app_theme.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();
  List<OrderResponse> _orders = [];
  bool _isLoading = true;
  String _selectedFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _orderService.getMyOrders();
      setState(() {
        _orders = orders;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải đơn hàng: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<OrderResponse> get _filteredOrders {
    if (_selectedFilter == 'ALL') {
      return _orders;
    }
    return _orders.where((order) => order.status == _selectedFilter).toList();
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _confirmDelivery(String orderId, BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: const [
              CircularProgressIndicator(color: Color(0xFFEE4D2D)),
              SizedBox(width: 16),
              Text('Đang xử lý...',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

      // Call API to confirm delivery
      await _orderService.confirmDelivery(orderId);

      if (!mounted) return;

      // Close loading dialog
      if (Navigator.canPop(context)) Navigator.pop(context);

      // Close modal
      if (Navigator.canPop(context)) Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xác nhận nhận hàng thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload orders
      await _loadOrders();
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      if (Navigator.canPop(context)) Navigator.pop(context);

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEE4D2D), Color(0xFFFF6347)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "Đơn hàng của tôi",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
            : _orders.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadOrders,
                    color: AppTheme.primaryColor,
                    child: Column(
                      children: [
                        _buildFilterTabs(),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredOrders.length,
                            itemBuilder: (context, index) {
                              return _buildOrderCard(_filteredOrders[index]);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có đơn hàng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bạn chưa đặt hàng, hãy bắt đầu mua sắm ngay',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      ('ALL', 'Tất cả'),
      ('PENDING', 'Chờ xử lý'),
      ('CONFIRMED', 'Đã xác nhận'),
      ('SHIPPING', 'Đang giao'),
      ('DELIVERED', 'Đã giao'),
      ('CANCELLED', 'Đã hủy'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _selectedFilter == f.$1;
            return Container(
              margin: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  f.$2,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFFEE4D2D),
                backgroundColor: Colors.grey.shade200,
                onSelected: (_) => setState(() => _selectedFilter = f.$1),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderResponse order) {
    final statusColor = order.getStatusColor();
    final formattedDate = _formatDate(order.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mã đơn + trạng thái
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order.orderCode,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.getStatusDisplay(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                formattedDate,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 12),
              Divider(color: Colors.grey.shade300),

              const SizedBox(height: 12),
              // Địa chỉ + Tổng tiền
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Địa chỉ giao",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600)),
                        const SizedBox(height: 4),
                        Text(
                          order.shippingAddress,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("Tổng tiền",
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(
                        "${order.finalAmount.toStringAsFixed(0)}₫",
                        style: const TextStyle(
                          color: Color(0xFFEE4D2D),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(OrderResponse order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderCode,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.getStatusDisplay(),
                          style: TextStyle(
                            fontSize: 14,
                            color: order.getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipient info
                    const Text(
                      'Người nhận',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                order.recipientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                order.recipientPhone,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            order.shippingAddress,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Order summary
                    const Text(
                      'Tóm tắt đơn hàng',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                        'Tạm tính', '${order.totalAmount.toStringAsFixed(0)}₫'),
                    if (order.shippingFee > 0)
                      _buildSummaryRow('Phí vận chuyển',
                          '${order.shippingFee.toStringAsFixed(0)}₫'),
                    if (order.discountAmount > 0)
                      _buildSummaryRow(
                        'Giảm giá',
                        '-${order.discountAmount.toStringAsFixed(0)}₫',
                        isDiscount: true,
                      ),
                    const Divider(height: 24),
                    _buildSummaryRow(
                      'Tổng cộng',
                      '${order.finalAmount.toStringAsFixed(0)}₫',
                      isBold: true,
                    ),
                    const SizedBox(height: 24),

                    // Payment & Status
                    const Text(
                      'Thông tin thanh toán',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Phương thức', order.paymentMethod),
                    _buildInfoRow(
                        'Trạng thái', order.getPaymentStatusDisplay()),
                    const SizedBox(height: 24),

                    // Note
                    if (order.note != null && order.note!.isNotEmpty) ...[
                      const Text(
                        'Ghi chú',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          order.note!,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Date info
                    const Text(
                      'Thời gian',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Đặt hàng',
                      _formatDate(order.createdAt),
                    ),
                    if (order.updatedAt != order.createdAt)
                      _buildInfoRow(
                        'Cập nhật',
                        _formatDate(order.updatedAt),
                      ),
                  ],
                ),
              ),
            ),

            // Action button for shipping status
            if (order.status == 'SHIPPING')
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _confirmDelivery(order.orderId, context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEE4D2D),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text(
                        "ĐÃ NHẬN ĐƯỢC HÀNG",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    )),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isDiscount = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDiscount
                  ? Colors.green
                  : (isBold ? AppTheme.primaryColor : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
