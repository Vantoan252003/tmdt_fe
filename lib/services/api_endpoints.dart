class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://157.66.100.248:8081/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';
  
  // Product endpoints
  static const String products = '$baseUrl/products';
  static String productDetail(String id) => '$baseUrl/products/$id';
  static String productsByCategory(String categoryId) => '$baseUrl/products/category/$categoryId';
  static String productsByShop(String shopId) => '$baseUrl/products/shop/$shopId';
  static String searchProducts = '$baseUrl/products/search';
  
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
  static const String userProfile = '$baseUrl/user/profile';
 
  
  // Wishlist endpoints
  static const String wishlist = '$baseUrl/wishlist';
  static String addToWishlist = '$baseUrl/wishlist/add';
  static String removeFromWishlist(String productId) => '$baseUrl/wishlist/remove/$productId';
  
  // Review endpoints
  static String productReviews(String productId) => '$baseUrl/products/$productId/reviews';
  static const String createReview = '$baseUrl/reviews/create';

  // Address endpoints
  static const String addresses = '$baseUrl/addresses';
  static String addressById(String id) => '$baseUrl/addresses/$id';
  static String setDefaultAddress(String id) => '$baseUrl/addresses/$id/default';

  // Location endpoints
  static const String cities = '$baseUrl/locations/cities';
  static String districtsByCity(String city) => '$baseUrl/locations/cities/$city/districts';

  // Payment endpoints
  static const String paymentMethods = '$baseUrl/payment/methods';
  static const String processPayment = '$baseUrl/payment/process';


}
