import '../models/product.dart';
import '../models/category.dart';

class MockData {
  // Mock categories


  // Mock products
  static List<Product> getProducts() {
    return [
      Product(
        id: '1',
        name: 'Bút bi Thiên Long',
        description: 'Bút bi cao cấp, mực xanh, viết êm trơn. Phù hợp cho học sinh, sinh viên. Thiết kế ergonomic giúp cầm nắm thoải mái.',
        price: 5000,
        imageUrl: '🖊️',
        category: 'Văn phòng phẩm',
        rating: 4.5,
        reviewCount: 234,
        stock: 500,
        images: ['🖊️', '✏️', '🖍️'],
      ),
      Product(
        id: '2',
        name: 'Vở kẻ ngang 200 trang',
        description: 'Vở kẻ ngang cao cấp, giấy trắng mịn, bìa cứng bền đẹp. Chất lượng giấy tốt, không lem mực.',
        price: 15000,
        imageUrl: '📓',
        category: 'Văn phòng phẩm',
        rating: 4.8,
        reviewCount: 456,
        stock: 300,
        images: ['📓', '📔', '📕'],
      ),
      Product(
        id: '3',
        name: 'Ba lô học sinh',
        description: 'Ba lô chống nước, nhiều ngăn tiện lợi. Thiết kế hiện đại, dây đeo êm ái. Phù hợp cho học sinh cấp 2, cấp 3.',
        price: 250000,
        imageUrl: '🎒',
        category: 'Túi & Ba lô',
        rating: 4.7,
        reviewCount: 189,
        stock: 50,
        images: ['🎒', '🎓', '👜'],
      ),
      Product(
        id: '4',
        name: 'Máy tính Casio FX-580VNX',
        description: 'Máy tính khoa học chính hãng, đa chức năng. Màn hình lớn, pin bền. Phù hợp cho học sinh THPT và sinh viên.',
        price: 450000,
        imageUrl: '🔢',
        category: 'Thiết bị điện tử',
        rating: 4.9,
        reviewCount: 678,
        stock: 80,
        images: ['🔢', '📱', '⌨️'],
      ),
      Product(
        id: '5',
        name: 'Bộ màu nước 24 màu',
        description: 'Bộ màu nước cao cấp, màu sắc rực rỡ, dễ pha trộn. Kèm cọ vẽ chất lượng. Phù hợp cho học sinh tiểu học.',
        price: 85000,
        imageUrl: '🎨',
        category: 'Đồ dùng mỹ thuật',
        rating: 4.6,
        reviewCount: 321,
        stock: 120,
        images: ['🎨', '🖌️', '🖍️'],
      ),
      Product(
        id: '6',
        name: 'Sách Toán 12',
        description: 'Sách giáo khoa Toán lớp 12, chương trình mới. Bìa cứng, in rõ nét. Nội dung đầy đủ theo chương trình của Bộ GD&ĐT.',
        price: 35000,
        imageUrl: '📐',
        category: 'Sách giáo khoa',
        rating: 4.4,
        reviewCount: 567,
        stock: 200,
        images: ['📐', '📏', '📊'],
      ),
      Product(
        id: '7',
        name: 'Thước kẻ 30cm',
        description: 'Thước nhựa trong suốt, có độ chia chính xác. Chất liệu bền, không gãy dễ dàng.',
        price: 8000,
        imageUrl: '📏',
        category: 'Dụng cụ học tập',
        rating: 4.3,
        reviewCount: 145,
        stock: 400,
        images: ['📏', '📐', '📊'],
      ),
      Product(
        id: '8',
        name: 'Bút chì 2B',
        description: 'Bút chì gỗ chất lượng cao, ruột chì đen đậm. Dễ gọt, không gãy ruột. Hộp 12 cây.',
        price: 25000,
        imageUrl: '✏️',
        category: 'Văn phòng phẩm',
        rating: 4.7,
        reviewCount: 289,
        stock: 350,
        images: ['✏️', '✒️', '🖊️'],
      ),
      Product(
        id: '9',
        name: 'Kéo cắt học sinh',
        description: 'Kéo inox chất lượng cao, cắt êm, sắc bén. Thiết kế an toàn cho học sinh. Có bao đựng bảo vệ.',
        price: 18000,
        imageUrl: '✂️',
        category: 'Dụng cụ học tập',
        rating: 4.5,
        reviewCount: 198,
        stock: 180,
        images: ['✂️', '📌', '📍'],
      ),
      Product(
        id: '10',
        name: 'Bộ compa toán học',
        description: 'Bộ compa 8 món đầy đủ, có hộp đựng. Chất liệu kim loại bền đẹp. Thích hợp cho học sinh THCS, THPT.',
        price: 45000,
        imageUrl: '📐',
        category: 'Dụng cụ học tập',
        rating: 4.6,
        reviewCount: 412,
        stock: 95,
        images: ['📐', '📏', '✏️'],
      ),
    ];
  }

  // Get featured products
  static List<Product> getFeaturedProducts() {
    return getProducts().where((p) => p.rating >= 4.7).toList();
  }

  // Get new products
  static List<Product> getNewProducts() {
    return getProducts().take(5).toList();
  }

  // Get products by category
  static List<Product> getProductsByCategory(String category) {
    return getProducts().where((p) => p.category == category).toList();
  }

  // Search products
  static List<Product> searchProducts(String query) {
    return getProducts()
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
