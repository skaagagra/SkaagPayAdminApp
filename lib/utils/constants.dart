class AppConstants {
  // CONFIGURABLE BASE URL
  // static const String baseUrl = 'http://127.0.0.1:8000/api'; // Localhost
  static const String baseUrl = 'https://skaagpay-backend.vercel.app/api'; // Production
  // static const String baseUrl = 'http://192.168.1.3:8000/api'; // Your LAN IP (For Physical Device)
  // static const String baseUrl = 'https://skaagpay-backend.vercel.app/api'; // Production

  static const String adminLoginEndpoint = '/admin/login/';
  static const String adminDashboardEndpoint = '/admin/dashboard/';
  static const String adminTopUpsEndpoint = '/admin/topups/';
  static const String adminRechargesEndpoint = '/admin/recharges/';
}
