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

  AddressRequest({
    required this.recipientName,
    required this.phoneNumber,
    required this.addressLine,
    required this.ward,
    required this.district,
    required this.city,
    this.isDefault = false,
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
    };
  }
}