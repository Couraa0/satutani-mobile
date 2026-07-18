class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:4000/api', // Ubah defaultValue ini ke URL backend Azure nantinya
  );
}
