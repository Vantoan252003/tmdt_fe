import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final List<Address> _addresses = [];
  final AddressService _addressService = AddressService();
  bool _isLoading = false;
  Address? _defaultAddress;

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  Address? get defaultAddress => _defaultAddress;

  Future<void> loadAddresses() async {
    _isLoading = true;
    notifyListeners();

    try {
      final addresses = await _addressService.getUserAddresses();
      _addresses.clear();
      _addresses.addAll(addresses);

      // Find default address
      _defaultAddress = addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => addresses.isNotEmpty ? addresses.first : Address(
          addressId: '',
          userId: '',
          recipientName: '',
          phoneNumber: '',
          addressLine: '',
          ward: '',
          district: '',
          city: '',
          isDefault: false,
        ),
      );
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAddress(AddressRequest request) async {
    try {
      final newAddress = await _addressService.createAddress(request);
      _addresses.add(newAddress);

      // If this is the default address, update default
      if (request.isDefault) {
        _defaultAddress = newAddress;
        // Update other addresses to not be default
        for (var address in _addresses) {
          if (address.addressId != newAddress.addressId) {
            address = Address(
              addressId: address.addressId,
              userId: address.userId,
              recipientName: address.recipientName,
              phoneNumber: address.phoneNumber,
              addressLine: address.addressLine,
              ward: address.ward,
              district: address.district,
              city: address.city,
              isDefault: false,
              latitude: address.latitude,
              longitude: address.longitude,
              formattedAddress: address.formattedAddress,
              createdAt: address.createdAt,
              updatedAt: address.updatedAt,
            );
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding address: $e');
      rethrow;
    }
  }

  Future<void> updateAddress(String addressId, AddressRequest request) async {
    try {
      final updatedAddress = await _addressService.updateAddress(addressId, request);

      final index = _addresses.indexWhere((addr) => addr.addressId == addressId);
      if (index != -1) {
        _addresses[index] = updatedAddress;

        // If this is now the default address, update default
        if (request.isDefault) {
          _defaultAddress = updatedAddress;
          // Update other addresses to not be default
          for (var i = 0; i < _addresses.length; i++) {
            if (_addresses[i].addressId != addressId) {
              _addresses[i] = Address(
                addressId: _addresses[i].addressId,
                userId: _addresses[i].userId,
                recipientName: _addresses[i].recipientName,
                phoneNumber: _addresses[i].phoneNumber,
                addressLine: _addresses[i].addressLine,
                ward: _addresses[i].ward,
                district: _addresses[i].district,
                city: _addresses[i].city,
                isDefault: false,
                latitude: _addresses[i].latitude,
                longitude: _addresses[i].longitude,
                formattedAddress: _addresses[i].formattedAddress,
                createdAt: _addresses[i].createdAt,
                updatedAt: _addresses[i].updatedAt,
              );
            }
          }
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating address: $e');
      rethrow;
    }
  }

  Future<void> deleteAddress(String addressId) async {
    try {
      await _addressService.deleteAddress(addressId);
      _addresses.removeWhere((addr) => addr.addressId == addressId);

      // If deleted address was default, set another as default or null
      if (_defaultAddress?.addressId == addressId) {
        _defaultAddress = _addresses.isNotEmpty ? _addresses.first : null;
        if (_defaultAddress != null) {
          await setDefaultAddress(_defaultAddress!.addressId);
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting address: $e');
      rethrow;
    }
  }

  Future<void> setDefaultAddress(String addressId) async {
    try {
      final updatedAddress = await _addressService.setDefaultAddress(addressId);

      // Update local state
      for (var i = 0; i < _addresses.length; i++) {
        _addresses[i] = Address(
          addressId: _addresses[i].addressId,
          userId: _addresses[i].userId,
          recipientName: _addresses[i].recipientName,
          phoneNumber: _addresses[i].phoneNumber,
          addressLine: _addresses[i].addressLine,
          ward: _addresses[i].ward,
          district: _addresses[i].district,
          city: _addresses[i].city,
          isDefault: _addresses[i].addressId == addressId,
          latitude: _addresses[i].latitude,
          longitude: _addresses[i].longitude,
          formattedAddress: _addresses[i].formattedAddress,
          createdAt: _addresses[i].createdAt,
          updatedAt: _addresses[i].updatedAt,
        );
      }

      _defaultAddress = updatedAddress;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting default address: $e');
      rethrow;
    }
  }
}