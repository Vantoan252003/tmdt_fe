import 'package:flutter/material.dart';
import '../models/voucher.dart';
import '../services/voucher_service.dart';
import '../utils/app_theme.dart';

class VoucherSelectorWidget extends StatefulWidget {
  final String shopId;
  final double orderValue;
  final Voucher? selectedVoucher;
  final Function(Voucher?) onVoucherSelected;

  const VoucherSelectorWidget({
    super.key,
    required this.shopId,
    required this.orderValue,
    this.selectedVoucher,
    required this.onVoucherSelected,
  });

  @override
  State<VoucherSelectorWidget> createState() => _VoucherSelectorWidgetState();
}

class _VoucherSelectorWidgetState extends State<VoucherSelectorWidget> {
  final VoucherService _voucherService = VoucherService();
  List<Voucher> _vouchers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  Future<void> _loadVouchers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vouchers = await _voucherService.getAvailableVouchers(widget.shopId);
      if (mounted) {
        setState(() {
          _vouchers = vouchers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải voucher: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showVoucherSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
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
                  const Text(
                    'Chọn voucher',
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

            // Voucher list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                  : _vouchers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.discount_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Không có voucher khả dụng',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _vouchers.length,
                          itemBuilder: (context, index) {
                            final voucher = _vouchers[index];
                            final isSelected = widget.selectedVoucher?.voucherId == voucher.voucherId;
                            final canApply = voucher.canApplyToOrder(widget.orderValue);
                            
                            return _buildVoucherCard(voucher, isSelected, canApply);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherCard(Voucher voucher, bool isSelected, bool canApply) {
    return InkWell(
      onTap: canApply
          ? () {
              widget.onVoucherSelected(isSelected ? null : voucher);
              Navigator.pop(context);
            }
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: canApply
              ? (isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (canApply ? Colors.grey[300]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: canApply
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Voucher icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: canApply ? AppTheme.primaryGradient : null,
                color: canApply ? null : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.discount,
                color: canApply ? Colors.white : Colors.grey[500],
                size: 28,
              ),
            ),
            const SizedBox(width: 12),

            // Voucher info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    voucher.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: canApply ? AppTheme.textPrimary : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Discount value
                  Text(
                    voucher.discountText,
                    style: TextStyle(
                      fontSize: 14,
                      color: canApply ? AppTheme.primaryColor : Colors.grey[500],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Conditions
                  Text(
                    voucher.minOrderText,
                    style: TextStyle(
                      fontSize: 12,
                      color: canApply ? AppTheme.textSecondary : Colors.grey[400],
                    ),
                  ),

                  // Max discount (if applicable)
                  if (voucher.maxDiscountText != null)
                    Text(
                      voucher.maxDiscountText!,
                      style: TextStyle(
                        fontSize: 12,
                        color: canApply ? AppTheme.textSecondary : Colors.grey[400],
                      ),
                    ),

                  // Code
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: canApply
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: canApply ? AppTheme.primaryColor : Colors.grey[400]!,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Text(
                      voucher.code,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: canApply ? AppTheme.primaryColor : Colors.grey[500],
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),

                  // Not applicable message
                  if (!canApply)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Không đủ điều kiện áp dụng',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.red[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Selection indicator
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.discount, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'Voucher giảm giá',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Voucher selector button
          InkWell(
            onTap: _showVoucherSelector,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: widget.selectedVoucher != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      widget.selectedVoucher!.code,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    widget.selectedVoucher!.discountText,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Tiết kiệm: -${widget.selectedVoucher!.calculateDiscount(widget.orderValue).toStringAsFixed(0)}đ',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.successColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Chọn hoặc nhập mã voucher',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
