class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://192.168.31.23:8080/api';
  
  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String logout = '$baseUrl/auth/logout';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String facebookLogin = '$baseUrl/auth/facebook';
  
  // Product endpoints
  static const String products = '$baseUrl/products';
  static String productDetail(String id) => '$baseUrl/products/$id';
  static String productsByCategory(String categoryId) => '$baseUrl/products/category/$categoryId';
  static String productsByShop(String shopId) => '$baseUrl/products/shop/$shopId';
  static String shopDetails(String shopId) => '$baseUrl/products/shop/$shopId/details';
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
  static const String myOrders = '$baseUrl/orders/my-orders';
  static const String myOrdersWithDeliveryStatus = '$baseUrl/orders/my-orders-with-delivery-status';
  static String cancelOrder(String id) => '$baseUrl/orders/$id/cancel';
  
  // User endpoints
  static const String profile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/profile/update';
  static const String changePassword = '$baseUrl/user/password/change';
  static const String userProfile = '$baseUrl/user/profile';
  static const String uploadAvatar = '$baseUrl/user/upload-avatar';
 
  
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

  // Voucher endpoints
  static String availableVouchers(String shopId) => '$baseUrl/vouchers/available?shopId=$shopId';

  // Banner endpoints
  static const String banners = '$baseUrl/banners';

  // Shop Review endpoints
  static String canReviewShop(String shopId) => '$baseUrl/shop-reviews/shop/$shopId/can-review';
  static String createShopReview(String shopId) => '$baseUrl/shop-reviews/shop/$shopId';
  static String shopReviews(String shopId) => '$baseUrl/shop-reviews/shop/$shopId';

  // Chat endpoints
  // Note: Use http:// for STOMP client - it will handle ws:// conversion with SockJS
  static const String chatWebSocket = 'http://192.168.31.101:8080/ws';
  static const String conversations = '$baseUrl/chat/conversations';
  static String conversationMessages(String conversationId) => '$baseUrl/chat/conversations/$conversationId/messages';
  static const String sendMessage = '$baseUrl/chat/send';
  static const String sendImage = '$baseUrl/chat/send-image';
  static String markAsRead(String conversationId) => '$baseUrl/chat/conversations/$conversationId/mark-read';
  static const String startConversation = '$baseUrl/chat/conversations/start';

  static const String registerFCMToken = '$baseUrl/fcm-tokens/register';
  static const String deactivateFCMToken = '$baseUrl/fcm-tokens/deactivate';
}
