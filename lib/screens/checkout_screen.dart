import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address.dart';
import '../models/cart_item_response.dart';
import '../models/order.dart';
import '../models/voucher.dart';
import '../services/address_service.dart';
import '../services/order_service.dart';
import '../providers/cart_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../widgets/voucher_selector_widget.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItemResponse> cartItems;
  final double totalAmount;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final AddressService _addressService = AddressService();
  final OrderService _orderService = OrderService();
  final TextEditingController _noteController = TextEditingController();

  List<Address> _addresses = [];
  Address? _selectedAddress;
  String _paymentMethod = 'COD';
  bool _isLoadingAddresses = true;
  bool _isCreatingOrder = false;
  Voucher? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });

    try {
      final addresses = await _addressService.getUserAddresses();
      setState(() {
        _addresses = addresses;
        if (addresses.isNotEmpty) {
          _selectedAddress = addresses.firstWhere(
            (addr) => addr.isDefault,
            orElse: () => addresses.first,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải địa chỉ: $e'),
            backgroundColor: const Color(0xFFEE4D2D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  Future<void> _createOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng chọn địa chỉ giao hàng'),
          backgroundColor: const Color(0xFFEE4D2D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() {
      _isCreatingOrder = true;
    });

    try {
      final orderItems = widget.cartItems.map((item) {
        return OrderItem(
          productId: item.productId,
          quantity: item.quantity,
          price: item.price,
          productName: item.productName,
          mainImageUrl: item.mainImageUrl,
        );
      }).toList();

      final request = CreateOrderRequest(
        items: orderItems,
        shippingAddressId: _selectedAddress!.addressId,
        paymentMethod: _paymentMethod,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        voucherId: _selectedVoucher?.voucherId,
      );

      await _orderService.createOrder(request);

      if (mounted) {
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await cartProvider.clearCart();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đặt hàng thành công!'),
            backgroundColor: const Color(0xFF4CAF50),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );

        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đặt hàng: $e'),
            backgroundColor: const Color(0xFFEE4D2D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingOrder = false;
        });
      }
    }
  }

  double get _voucherDiscount {
    return _selectedVoucher?.calculateDiscount(widget.totalAmount) ?? 0.0;
  }

  double get _finalTotal {
    return widget.totalAmount - _voucherDiscount;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Thanh Toán',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFEE4D2D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingAddresses
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFEE4D2D)),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildAddressSection(),
                  const SizedBox(height: 8),
                  _buildOrderItemsSection(),
                  const SizedBox(height: 8),
                  _buildVoucherSection(),
                  const SizedBox(height: 8),
                  _buildPaymentMethodSection(),
                  const SizedBox(height: 8),
                  _buildNoteSection(),
                  const SizedBox(height: 8),
                  _buildOrderSummary(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomSheet: _buildBottomBar(),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEE4D2D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFFEE4D2D),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Địa Chỉ Nhận Hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_selectedAddress != null)
            InkWell(
              onTap: _showAddressSelector,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              _selectedAddress!.recipientName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedAddress!.phoneNumber,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedAddress!.fullAddress,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Tính năng thêm địa chỉ sẽ được phát triển'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_location_alt, color: Color(0xFFFF9800)),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Thêm địa chỉ nhận hàng',
                        style: TextStyle(
                          color: Color(0xFFFF9800),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFFFF9800)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store, color: Color(0xFFEE4D2D), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Student Store',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
            ],
          ),
          const Divider(height: 24),
          ...widget.cartItems.map((item) => _buildOrderItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItemResponse item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: item.mainImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      item.mainImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        );
                      },
                    ),
                  )
                : Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '₫${item.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFEE4D2D),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    final shopId = widget.cartItems.isNotEmpty && widget.cartItems.first.shopId != null
        ? widget.cartItems.first.shopId!
        : '';

    if (shopId.isEmpty) {
      return const SizedBox.shrink();
    }

    return VoucherSelectorWidget(
      shopId: shopId,
      orderValue: widget.totalAmount,
      selectedVoucher: _selectedVoucher,
      onVoucherSelected: (voucher) {
        setState(() {
          _selectedVoucher = voucher;
        });
      },
    );
  }

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương Thức Thanh Toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPaymentMethodOption(
            'COD',
            'Thanh toán khi nhận hàng',
            Icons.payments_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String label, IconData icon) {
    final isSelected = _paymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEE4D2D).withOpacity(0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected ? const Color(0xFFEE4D2D) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFEE4D2D) : Colors.grey[600],
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? const Color(0xFFEE4D2D) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFEE4D2D),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tin Nhắn',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 2,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Lưu ý cho người bán...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                borderSide: const BorderSide(color: Color(0xFFEE4D2D)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng tiền hàng:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                '₫${widget.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí vận chuyển:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const Text(
                '₫0',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          if (_selectedVoucher != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Voucher:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  '-₫${_voucherDiscount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng thanh toán:',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₫${_finalTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFEE4D2D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tổng thanh toán:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₫${_finalTotal.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFEE4D2D),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _isCreatingOrder
                  ? Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _createOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEE4D2D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Đặt hàng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Địa Chỉ Của Tôi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _addresses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  final isSelected = _selectedAddress?.addressId == address.addressId;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedAddress = address;
                      });
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEE4D2D).withOpacity(0.05) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFEE4D2D) : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                address.recipientName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                address.phoneNumber,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFFEE4D2D),
                                  size: 20,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            address.fullAddress,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFEE4D2D)),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: const Text(
                                'Mặc định',
                                style: TextStyle(
                                  color: Color(0xFFEE4D2D),
                                  fontSize: 11,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}