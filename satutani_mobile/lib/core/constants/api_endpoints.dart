class ApiEndpoints {
  static const String baseUrl = 'https://satutani.vercel.app/api';

  // Products
  static const String products = '/products';
  static String productDetail(String id) => '/products/$id';
  static String productTraceability(String id) => '/products/$id/traceability';

  // Farmers
  static const String farmers = '/farmers';

  // Categories
  static const String categories = '/categories';

  // Orders
  static const String orders = '/orders';
  static String orderDetail(String id) => '/orders/$id';
  static String orderTracking(String id) => '/orders/$id/tracking';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Chat
  static const String chatMessage = '/chat/message';
}
