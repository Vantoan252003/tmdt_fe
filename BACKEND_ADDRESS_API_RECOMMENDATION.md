# ĐỀ XUẤT CẬP NHẬT BACKEND API CHO ĐỊA CHỈ

## 📍 Tình huống hiện tại

Hiện tại, khi lưu địa chỉ, Flutter app chỉ gửi các thông tin cơ bản:
- `recipientName`: Tên người nhận
- `phoneNumber`: Số điện thoại
- `addressLine`: Địa chỉ cụ thể (số nhà, tên đường)
- `ward`: Phường/Xã
- `district`: Quận/Huyện
- `city`: Tỉnh/Thành phố
- `isDefault`: Có phải địa chỉ mặc định không

**Vấn đề**: Không có thông tin tọa độ GPS (latitude, longitude) để:
- Tính toán khoảng cách giao hàng chính xác
- Hiển thị vị trí trên bản đồ
- Tối ưu route giao hàng

## 🎯 ĐỀ XUẤT BỔ SUNG

### 1. Cập nhật Model Backend

Thêm 2 trường mới vào Address entity/model:

```java
@Entity
@Table(name = "addresses")
public class Address {
    // ... các trường hiện tại ...
    
    @Column(name = "latitude")
    private Double latitude;  // Vĩ độ (Ví dụ: 21.028511)
    
    @Column(name = "longitude") 
    private Double longitude;  // Kinh độ (Ví dụ: 105.804817)
    
    @Column(name = "formatted_address", length = 500)
    private String formattedAddress;  // Địa chỉ đầy đủ từ Google Maps
    
    // Getters và Setters
}
```

### 2. Cập nhật DTO (Data Transfer Object)

```java
public class AddressRequest {
    private String recipientName;
    private String phoneNumber;
    private String addressLine;
    private String ward;
    private String district;
    private String city;
    private Boolean isDefault;
    
    // ===== CÁC TRƯỜNG MỚI =====
    private Double latitude;        // Tọa độ vĩ độ từ Google Maps
    private Double longitude;       // Tọa độ kinh độ từ Google Maps
    private String formattedAddress; // Địa chỉ được format đầy đủ từ Google
    
    // Getters và Setters
}

public class AddressResponse {
    private String addressId;
    private String recipientName;
    private String phoneNumber;
    private String addressLine;
    private String ward;
    private String district;
    private String city;
    private String fullAddress;
    private Boolean isDefault;
    
    // ===== CÁC TRƯỜNG MỚI =====
    private Double latitude;         // Tọa độ vĩ độ
    private Double longitude;        // Tọa độ kinh độ
    private String formattedAddress; // Địa chỉ đầy đủ từ Google Maps
    
    // Getters và Setters
}
```

### 3. Cập nhật Database Migration

**SQL Migration Script:**

```sql
-- Thêm cột latitude, longitude, formatted_address vào bảng addresses
ALTER TABLE addresses 
ADD COLUMN latitude DOUBLE PRECISION,
ADD COLUMN longitude DOUBLE PRECISION,
ADD COLUMN formatted_address VARCHAR(500);

-- Tạo index cho việc tìm kiếm theo tọa độ (optional nhưng recommended)
CREATE INDEX idx_addresses_location ON addresses(latitude, longitude);
```

### 4. Validation Rules

Trong backend, thêm validation cho các trường mới:

```java
@NotNull(message = "Latitude is required")
@DecimalMin(value = "-90.0", message = "Latitude must be >= -90")
@DecimalMax(value = "90.0", message = "Latitude must be <= 90")
private Double latitude;

@NotNull(message = "Longitude is required")
@DecimalMin(value = "-180.0", message = "Longitude must be >= -180")
@DecimalMax(value = "180.0", message = "Longitude must be <= 180")
private Double longitude;

@Size(max = 500, message = "Formatted address must not exceed 500 characters")
private String formattedAddress;
```

## 📤 DỮ LIỆU GỬI TỪ FLUTTER LÊN BACKEND

Khi user lưu địa chỉ, Flutter app sẽ gửi JSON payload như sau:

```json
{
  "recipientName": "Nguyễn Văn Toàn",
  "phoneNumber": "0123456789",
  "addressLine": "123 Đường Láng",
  "ward": "Thành Công",
  "district": "Ba Đình",
  "city": "Hà Nội",
  "isDefault": true,
  "latitude": 21.028511,
  "longitude": 105.804817,
  "formattedAddress": "123 Đường Láng, Thành Công, Ba Đình, Hà Nội, Việt Nam"
}
```

## 🔄 FLOW HOẠT ĐỘNG

### Khi thêm/sửa địa chỉ:

1. **User chọn vị trí trên bản đồ** hoặc tìm kiếm địa chỉ
2. **Google Maps API** trả về:
   - `latitude`: Tọa độ vĩ độ
   - `longitude`: Tọa độ kinh độ
   - `addressLine`: Số nhà + Tên đường
   - `ward`: Phường/Xã
   - `district`: Quận/Huyện
   - `city`: Tỉnh/Thành phố
   - `formattedAddress`: Địa chỉ đầy đủ theo format chuẩn của Google

3. **Flutter app** gửi tất cả thông tin này lên backend
4. **Backend** lưu vào database
5. **Backend** trả về response bao gồm cả latitude/longitude để Flutter có thể hiển thị lại trên bản đồ

## 💡 LỢI ÍCH CỦA VIỆC LƯU TỌA ĐỘ

### 1. Tính toán khoảng cách giao hàng
```java
// Backend có thể tính khoảng cách giữa shop và địa chỉ giao hàng
public double calculateDistance(Double lat1, Double lon1, Double lat2, Double lon2) {
    // Haversine formula
    // Trả về khoảng cách theo km
}

// Sử dụng để:
// - Tính phí ship
// - Kiểm tra có giao được không
// - Ước tính thời gian giao hàng
```

### 2. Tối ưu route giao hàng
- Shipper có thể xem các đơn hàng gần nhau
- Sắp xếp đơn hàng theo thứ tự địa lý
- Tối ưu hóa chi phí vận chuyển

### 3. Hiển thị bản đồ
- Admin dashboard có thể hiển thị các địa chỉ trên bản đồ
- Tracking đơn hàng realtime
- Phân tích khu vực có nhiều đơn hàng

### 4. Geocoding ngược
- Nếu có latitude/longitude, backend có thể tự động lấy địa chỉ
- Không cần phụ thuộc vào user nhập chính xác

## ⚠️ LƯU Ý QUAN TRỌNG

### 1. Validation
- Kiểm tra latitude nằm trong khoảng [-90, 90]
- Kiểm tra longitude nằm trong khoảng [-180, 180]
- Với Việt Nam:
  - Latitude: ~8.5 đến ~23.5
  - Longitude: ~102 đến ~110

### 2. Nullable Fields
- Các trường `latitude`, `longitude` có thể nullable cho backward compatibility
- Các địa chỉ cũ không có tọa độ vẫn hoạt động bình thường
- Chỉ yêu cầu bắt buộc đối với địa chỉ mới (từ sau khi update)

### 3. Privacy
- Tọa độ GPS là thông tin nhạy cảm
- Chỉ lưu tọa độ khi user đồng ý
- Không share tọa độ chính xác với bên thứ 3

## 📊 VÍ DỤ API ENDPOINTS

### POST /api/addresses
**Request:**
```json
{
  "recipientName": "Nguyễn Văn A",
  "phoneNumber": "0987654321",
  "addressLine": "456 Nguyễn Trãi",
  "ward": "Thanh Xuân Trung",
  "district": "Thanh Xuân",
  "city": "Hà Nội",
  "isDefault": false,
  "latitude": 20.997410,
  "longitude": 105.801390,
  "formattedAddress": "456 Nguyễn Trãi, Thanh Xuân Trung, Thanh Xuân, Hà Nội"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Address created successfully",
  "data": {
    "addressId": "addr_123xyz",
    "recipientName": "Nguyễn Văn A",
    "phoneNumber": "0987654321",
    "addressLine": "456 Nguyễn Trãi",
    "ward": "Thanh Xuân Trung",
    "district": "Thanh Xuân",
    "city": "Hà Nội",
    "fullAddress": "456 Nguyễn Trãi, Thanh Xuân Trung, Thanh Xuân, Hà Nội",
    "isDefault": false,
    "latitude": 20.997410,
    "longitude": 105.801390,
    "formattedAddress": "456 Nguyễn Trãi, Thanh Xuân Trung, Thanh Xuân, Hà Nội",
    "createdAt": "2025-12-17T10:30:00Z",
    "updatedAt": "2025-12-17T10:30:00Z"
  }
}
```

### GET /api/addresses/my-addresses
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "addressId": "addr_123xyz",
      "recipientName": "Nguyễn Văn A",
      "phoneNumber": "0987654321",
      "fullAddress": "456 Nguyễn Trãi, Thanh Xuân Trung, Thanh Xuân, Hà Nội",
      "isDefault": true,
      "latitude": 20.997410,
      "longitude": 105.801390
    }
  ]
}
```

## 🚀 CẬP NHẬT FLUTTER CODE

Sau khi backend đã update, cần sửa `AddressRequest` trong Flutter:

```dart
class AddressRequest {
  final String recipientName;
  final String phoneNumber;
  final String addressLine;
  final String ward;
  final String district;
  final String city;
  final bool isDefault;
  
  // === THÊM MỚI ===
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
    required this.isDefault,
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
      'latitude': latitude,        // GỬI LÊN BACKEND
      'longitude': longitude,      // GỬI LÊN BACKEND
      'formattedAddress': formattedAddress, // GỬI LÊN BACKEND
    };
  }
}
```

Và update code lưu địa chỉ:

```dart
Future<void> _saveAddress() async {
  // ... validation ...
  
  final request = AddressRequest(
    recipientName: _recipientNameController.text.trim(),
    phoneNumber: _phoneController.text.trim(),
    addressLine: _addressLine,
    ward: _ward,
    district: _district,
    city: _city,
    isDefault: _isDefault,
    // === GỬI TỌA ĐỘ LÊN BACKEND ===
    latitude: _latitude,      // Từ Google Maps
    longitude: _longitude,    // Từ Google Maps  
    formattedAddress: _fullAddress, // Địa chỉ đầy đủ
  );
  
  await addressProvider.addAddress(request);
}
```

## ✅ CHECKLIST TRIỂN KHAI

- [ ] 1. Cập nhật database: thêm cột `latitude`, `longitude`, `formatted_address`
- [ ] 2. Cập nhật Entity/Model trong backend
- [ ] 3. Cập nhật DTO (AddressRequest, AddressResponse)
- [ ] 4. Cập nhật Service layer để xử lý lưu/đọc tọa độ
- [ ] 5. Cập nhật Controller/API endpoints
- [ ] 6. Thêm validation cho latitude/longitude
- [ ] 7. Test API với Postman
- [ ] 8. Cập nhật Flutter model (AddressRequest, Address)
- [ ] 9. Test end-to-end flow

## 📝 KẾT LUẬN

Việc lưu `latitude`, `longitude`, và `formattedAddress` vào backend là **RẤT QUAN TRỌNG** để:
1. ✅ Tính phí ship chính xác
2. ✅ Tối ưu route giao hàng
3. ✅ Hiển thị bản đồ trong admin dashboard
4. ✅ Tracking đơn hàng realtime
5. ✅ Phân tích dữ liệu khách hàng theo khu vực

**Đề xuất**: Backend nên bắt buộc có `latitude` và `longitude` cho tất cả địa chỉ mới. Các địa chỉ cũ có thể nullable để đảm bảo backward compatibility.
