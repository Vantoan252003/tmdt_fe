class Address {
  final String addressId;
  final String userId;
  final String recipientName;
  final String phoneNumber;
  final String addressLine;
  final String ward;
  final String district;
  final String city;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Address({
    required this.addressId,
    required this.userId,
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine,
    required this.ward,
    required this.district,
    required this.city,
    required this.isDefault,
    this.latitude,
    this.longitude,
    this.formattedAddress,
    this.createdAt,
    this.updatedAt,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['addressId'] ?? '',
      userId: json['userId'] ?? '',
      recipientName: json['recipientName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      addressLine: json['addressLine'] ?? '',
      ward: json['ward'] ?? '',
      district: json['district'] ?? '',
      city: json['city'] ?? '',
      isDefault: json['isDefault'] ?? false,
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      formattedAddress: json['formattedAddress'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressId': addressId,
      'userId': userId,
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'addressLine': addressLine,
      'ward': ward,
      'district': district,
      'city': city,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get fullAddress {
    return '$addressLine, $ward, $district, $city';
  }
}

class Province {
  final int code;
  final String name;
  final String divisionType;
  final String codename;
  final int phoneCode;

  Province({
    required this.code,
    required this.name,
    required this.divisionType,
    required this.codename,
    required this.phoneCode,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: json['code'] ?? 0,
      name: json['name'] ?? '',
      divisionType: json['division_type'] ?? '',
      codename: json['codename'] ?? '',
      phoneCode: json['phone_code'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'division_type': divisionType,
      'codename': codename,
      'phone_code': phoneCode,
    };
  }
}

class District {
  final int code;
  final String name;
  final String divisionType;
  final String codename;
  final String provinceCode;

  District({
    required this.code,
    required this.name,
    required this.divisionType,
    required this.codename,
    required this.provinceCode,
  });

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      code: json['code'] ?? 0,
      name: json['name'] ?? '',
      divisionType: json['division_type'] ?? '',
      codename: json['codename'] ?? '',
      provinceCode: json['province_code'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'division_type': divisionType,
      'codename': codename,
      'province_code': provinceCode,
    };
  }
}

class AddressRequest {
  final String recipientName;
  final String phoneNumber;
  final String addressLine;
  final String ward;
  final String district;
  final String city;
  final bool isDefault;
  final double? latitude;
  final double? longitude;
  final String? formattedAddress;

  AddressRequest({
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine,
    required this.ward,
    required this.district,
    required this.city,
    this.isDefault = false,
    this.latitude,
    this.longitude,
    this.formattedAddress,
  });

  Map<String, dynamic> toJson() {
    return {
      'recipientName': recipientName,
      'phoneNumber': phoneNumber,
      'addressLine': addressLine,
      'ward': ward,
      'district': district,
      'city': city,
      'isDefault': isDefault,
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
    };
  }
}