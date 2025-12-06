class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://192.168.1.253:8080/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';
  
  // Product endpoints
  static const String products = '$baseUrl/products';
  static String productDetail(String id) => '$baseUrl/products/$id';
  static const String searchProducts = '$baseUrl/products/search';
  static const String featuredProducts = '$baseUrl/products/featured';
  static const String newProducts = '$baseUrl/products/new';
  static String productsByCategory(String categoryId) => '$baseUrl/products/category/$categoryId';
  
  // Category endpoints
  static const String categories = '$baseUrl/categories';
  static String categoryDetail(String id) => '$baseUrl/categories/$id';
  
  // Cart endpoints
  static const String cart = '$baseUrl/cart';
  static String addToCart = '$baseUrl/cart/add';
  static String updateCartItem(String cartItemId) => '$baseUrl/cart/items/$cartItemId';
  static String removeFromCart(String cartItemId) => '$baseUrl/cart/items/$cartItemId';
  static const String clearCart = '$baseUrl/cart/clear';
  
  // Order endpoints
  static const String orders = '$baseUrl/orders';
  static String orderDetail(String id) => '$baseUrl/orders/$id';
  static const String createOrder = '$baseUrl/orders/create';
  static String cancelOrder(String id) => '$baseUrl/orders/$id/cancel';
  
  // User endpoints
  static const String profile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/profile/update';
  static const String changePassword = '$baseUrl/user/password/change';
  static const String addresses = '$baseUrl/user/addresses';
  
  // Wishlist endpoints
  static const String wishlist = '$baseUrl/wishlist';
  static String addToWishlist = '$baseUrl/wishlist/add';
  static String removeFromWishlist(String productId) => '$baseUrl/wishlist/remove/$productId';
  
  // Review endpoints
  static String productReviews(String productId) => '$baseUrl/products/$productId/reviews';
  static const String createReview = '$baseUrl/reviews/create';
  
  // Payment endpoints
  static const String paymentMethods = '$baseUrl/payment/methods';
  static const String processPayment = '$baseUrl/payment/process';
}
