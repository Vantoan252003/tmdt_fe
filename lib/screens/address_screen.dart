import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/gradient_button.dart';
import '../providers/address_provider.dart';
import '../providers/location_provider.dart';
import '../models/address.dart';
import 'package:provider/provider.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAddresses();
    });
  }

  Future<void> _loadAddresses() async {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    await addressProvider.loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Địa chỉ giao hàng',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showAddAddressDialog(context),
            icon: const Icon(
              Icons.add,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      body: Consumer<AddressProvider>(
        builder: (context, addressProvider, child) {
          if (addressProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            );
          }

          if (addressProvider.addresses.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _loadAddresses,
            color: AppTheme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: addressProvider.addresses.length,
              itemBuilder: (context, index) {
                return _buildAddressCard(context, addressProvider.addresses[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có địa chỉ giao hàng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm địa chỉ giao hàng để thuận tiện hơn',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            text: 'Thêm địa chỉ',
            onPressed: () => _showAddAddressDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    address.recipientName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (address.isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Mặc định',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditAddressDialog(context, address);
                        break;
                      case 'delete':
                        _showDeleteAddressDialog(context, address);
                        break;
                      case 'set_default':
                        _setDefaultAddress(address.addressId);
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      const PopupMenuItem<String>(
                        value: 'set_default',
                        child: Row(
                          children: [
                            Icon(Icons.star, size: 20),
                            SizedBox(width: 8),
                            Text('Đặt làm mặc định'),
                          ],
                        ),
                      ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.errorColor, size: 20),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: AppTheme.errorColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              address.phoneNumber,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              address.fullAddress,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddressFormDialog();
      },
    );
  }

  void _showEditAddressDialog(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddressFormDialog(address: address);
      },
    );
  }

  void _showDeleteAddressDialog(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa địa chỉ'),
          content: Text('Bạn có chắc muốn xóa địa chỉ của "${address.recipientName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAddress(address.addressId);
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _setDefaultAddress(String addressId) async {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    try {
      await addressProvider.setDefaultAddress(addressId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đặt địa chỉ mặc định')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    try {
      await addressProvider.deleteAddress(addressId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa địa chỉ')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}

class AddressFormDialog extends StatefulWidget {
  final Address? address;

  const AddressFormDialog({super.key, this.address});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _recipientNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _wardController = TextEditingController();

  String? _selectedCity;
  String? _selectedDistrict;
  bool _isDefault = false;
  bool _isLoading = false;
  bool _isLoadingLocations = false;
  bool _isLoadingDistricts = false;

  List<String> _availableCities = [];
  List<String> _availableDistricts = [];

  @override
  void initState() {
    super.initState();
    _loadLocationData();
  }

  Future<void> _loadLocationData() async {
    setState(() {
      _isLoadingLocations = true;
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      await locationProvider.loadCities();
      _availableCities = locationProvider.cities;

      // Load existing address data after cities are loaded
      if (widget.address != null) {
        _recipientNameController.text = widget.address!.recipientName;
        _phoneController.text = widget.address!.phoneNumber;
        _addressLineController.text = widget.address!.addressLine;
        _wardController.text = widget.address!.ward;
        _selectedCity = widget.address!.city;
        _selectedDistrict = widget.address!.district;
        _isDefault = widget.address!.isDefault;

        // Update available districts when editing
        if (_selectedCity != null && _availableCities.contains(_selectedCity)) {
          await _loadDistrictsForCity(_selectedCity!);
        }
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLocations = false;
        });
      }
    }
  }

  Future<void> _loadDistrictsForCity(String city) async {
    setState(() {
      _isLoadingDistricts = true;
    });

    try {
      final locationProvider = Provider.of<LocationProvider>(context, listen: false);
      final districts = await locationProvider.getDistrictsForCity(city);
      setState(() {
        _availableDistricts = districts;
        _isLoadingDistricts = false;
      });
    } catch (e) {
      setState(() {
        _availableDistricts = [];
        _isLoadingDistricts = false;
      });
    }
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _phoneController.dispose();
    _addressLineController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.address == null ? Icons.add_location : Icons.edit_location,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.address == null ? 'Thêm địa chỉ mới' : 'Chỉnh sửa địa chỉ',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Thông tin người nhận'),
                      const SizedBox(height: 16),
                      _buildRecipientInfo(),
                      const SizedBox(height: 24),

                      _buildSectionTitle('Địa chỉ giao hàng'),
                      const SizedBox(height: 16),
                      _buildAddressInfo(),
                      const SizedBox(height: 16),

                      _buildDefaultAddressOption(),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hủy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveAddress,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Lưu địa chỉ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildRecipientInfo() {
    return Column(
      children: [
        _buildTextField(
          controller: _recipientNameController,
          label: 'Tên người nhận',
          hint: 'Nhập họ và tên',
          icon: Icons.person,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập tên người nhận';
            }
            if (value.length < 2) {
              return 'Tên phải có ít nhất 2 ký tự';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'Số điện thoại',
          hint: 'Nhập số điện thoại',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập số điện thoại';
            }
            if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
              return 'Số điện thoại phải có 10-11 chữ số';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressInfo() {
    return Column(
      children: [
        _buildTextField(
          controller: _addressLineController,
          label: 'Địa chỉ cụ thể',
          hint: 'Số nhà, tên đường, khu vực',
          icon: Icons.home,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập địa chỉ cụ thể';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          value: _selectedCity,
          label: 'Tỉnh/Thành phố',
          hint: _isLoadingLocations ? 'Đang tải...' : 'Chọn tỉnh/thành phố',
          icon: Icons.location_city,
          items: _availableCities,
          onChanged: (value) {
            setState(() {
              _selectedCity = value;
              _selectedDistrict = null; // Reset district when city changes
              _availableDistricts = [];
            });
            if (value != null) {
              _loadDistrictsForCity(value);
            }
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng chọn tỉnh/thành phố';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          value: _selectedDistrict,
          label: 'Quận/Huyện',
          hint: _isLoadingDistricts
              ? 'Đang tải...'
              : _availableDistricts.isEmpty
                  ? 'Chọn quận/huyện'
                  : 'Chọn quận/huyện (tùy chọn)',
          icon: Icons.location_on,
          items: _availableDistricts,
          onChanged: (value) {
            setState(() {
              _selectedDistrict = value;
            });
          },
          validator: null, // Optional field
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _wardController,
          label: 'Phường/Xã',
          hint: 'Nhập phường/xã',
          icon: Icons.place,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập phường/xã';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDefaultAddressOption() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: CheckboxListTile(
        title: const Text(
          'Đặt làm địa chỉ mặc định',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        subtitle: const Text(
          'Địa chỉ này sẽ được chọn mặc định cho các đơn hàng',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        value: _isDefault,
        onChanged: (value) {
          setState(() {
            _isDefault = value ?? false;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.errorColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      dropdownColor: Colors.white,
      icon: Icon(
        Icons.arrow_drop_down,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final request = AddressRequest(
        recipientName: _recipientNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        addressLine: _addressLineController.text.trim(),
        ward: _wardController.text.trim(),
        district: _selectedDistrict ?? _wardController.text.trim(), // Fallback to ward if district not selected
        city: _selectedCity ?? '',
        isDefault: _isDefault,
      );

      if (widget.address == null) {
        // Add new address
        await addressProvider.addAddress(request);
      } else {
        // Update existing address
        await addressProvider.updateAddress(widget.address!.addressId, request);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.address == null ? 'Đã thêm địa chỉ mới' : 'Đã cập nhật địa chỉ'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}