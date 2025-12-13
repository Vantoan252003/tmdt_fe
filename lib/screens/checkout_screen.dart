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
        // Auto-select default address
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
          SnackBar(content: Text('Lỗi khi tải địa chỉ: $e')),
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
        const SnackBar(content: Text('Vui lòng chọn địa chỉ giao hàng')),
      );
      return;
    }

    setState(() {
      _isCreatingOrder = true;
    });

    try {
      // Prepare order items
      final orderItems = widget.cartItems.map((item) {
        return OrderItem(
          productId: item.productId,
          quantity: item.quantity,
          price: item.price,
          productName: item.productName,
          mainImageUrl: item.mainImageUrl,
        );
      }).toList();

      // Create order request
      final request = CreateOrderRequest(

        items: orderItems,
        shippingAddressId: _selectedAddress!.addressId,
        paymentMethod: _paymentMethod,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        voucherId: _selectedVoucher?.voucherId,
      );

      // Debug: Print full request body
      print('Create Order Request Body: ${request.toJson()}');

      // Call API to create order
      await _orderService.createOrder(request);

      if (mounted) {
        // Clear cart after successful order
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await cartProvider.clearCart();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt hàng thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back to home or orders screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đặt hàng: $e'),
            backgroundColor: AppTheme.errorColor,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thanh toán',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      body: _isLoadingAddresses
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAddressSection(),
                  const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
                  _buildOrderItemsSection(),
                  const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
                  _buildVoucherSection(),
                  const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
                  _buildPaymentMethodSection(),
                  const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
                  _buildNoteSection(),
                  const Divider(height: 1, thickness: 8, color: Color(0xFFF5F5F5)),
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
              const Icon(Icons.location_on, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Địa chỉ giao hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_addresses.isNotEmpty)
                TextButton(
                  onPressed: _showAddressSelector,
                  child: const Text('Thay đổi'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_selectedAddress != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _selectedAddress!.recipientName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedAddress!.phoneNumber,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
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
                    ),
                  ),
                  if (_selectedAddress!.isDefault)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Mặc định',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bạn chưa có địa chỉ giao hàng',
                      style: TextStyle(color: Colors.orange[900]),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to add address screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng thêm địa chỉ sẽ được phát triển')),
                      );
                    },
                    child: const Text('Thêm'),
                  ),
                ],
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
          const Text(
            'Sản phẩm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.cartItems.map((item) => _buildOrderItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItemResponse item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: item.mainImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.mainImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, color: Colors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.image_not_supported, color: Colors.grey),
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
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.price.toStringAsFixed(0)}₫',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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

  Widget _buildPaymentMethodSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Phương thức thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodOption('COD', 'Thanh toán khi nhận hàng', Icons.money),
          // You can add more payment methods here
          // _buildPaymentMethodOption('BANK', 'Chuyển khoản ngân hàng', Icons.account_balance),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption(String value, String label, IconData icon) {
    return InkWell(
      onTap: () {
        setState(() {
          _paymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _paymentMethod == value ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _paymentMethod == value ? AppTheme.primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: _paymentMethod == value ? AppTheme.primaryColor : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: _paymentMethod == value ? FontWeight.bold : FontWeight.normal,
                  color: _paymentMethod == value ? AppTheme.primaryColor : Colors.black87,
                ),
              ),
            ),
            if (_paymentMethod == value)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
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
            'Ghi chú',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Nhập ghi chú cho đơn hàng (không bắt buộc)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherSection() {
    // Get shopId from first cart item
    final shopId = widget.cartItems.isNotEmpty && widget.cartItems.first.shopId != null
        ? widget.cartItems.first.shopId!
        : '';

    if (shopId.isEmpty) {
      print ( "Shop ID $shopId");
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

  double get _voucherDiscount {
    return _selectedVoucher?.calculateDiscount(widget.totalAmount) ?? 0.0;
  }

  double get _finalTotal {
    return widget.totalAmount - _voucherDiscount;
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tóm tắt đơn hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tạm tính:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              Text(
                '${widget.totalAmount.toStringAsFixed(0)}₫',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí vận chuyển:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const Text(
                'Miễn phí',
                style: TextStyle(fontSize: 14, color: Colors.green),
              ),
            ],
          ),
          if (_selectedVoucher != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Voucher giảm giá:',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  '-${_voucherDiscount.toStringAsFixed(0)}₫',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.w600,
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
                'Tổng cộng:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_finalTotal.toStringAsFixed(0)}₫',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
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
      padding: const EdgeInsets.all(16),
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
        child: _isCreatingOrder
            ? Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : GradientButton(
                text: 'Đặt hàng',
                onPressed: () => _createOrder(),
              ),
      ),
    );
  }

  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  const Text(
                    'Chọn địa chỉ giao hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  final isSelected = _selectedAddress?.addressId == address.addressId;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedAddress = address;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
                          width: 2,
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
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                address.phoneNumber,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppTheme.primaryColor,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            address.fullAddress,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                          if (address.isDefault)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Mặc định',
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 12,
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
