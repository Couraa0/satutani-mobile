import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'presentation/consumer_navigation.dart';
import 'presentation/farmer_navigation.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/screens/auth/role_select_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/auth/new_password_screen.dart';
import 'presentation/screens/auth/otp_screen.dart';
import 'presentation/screens/auth/otp_success_screen.dart';
import 'presentation/screens/product_detail/product_detail_screen.dart';
import 'presentation/screens/cart/cart_screen.dart';
import 'presentation/screens/checkout/checkout_screen.dart';
import 'presentation/screens/orders/orders_screen.dart';
import 'presentation/screens/orders/order_tracking_screen.dart';
import 'presentation/screens/chat/chat_screen.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    DevicePreview(
      enabled: true, // Always show the preview frame for testing
      builder: (context) => const SatuTaniApp(),
    ),
  );
}

class SatuTaniApp extends StatelessWidget {
  const SatuTaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'SatuTani',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/splash',
      routes: {
        '/splash':      (_) => const SplashScreen(),
        '/onboarding':  (_) => const OnboardingScreen(),
        '/role-select': (_) => const RoleSelectScreen(),
        '/login':       (_) => const LoginScreen(),
        '/forgot-password': (_) => const ForgotPasswordScreen(),
        '/new-password':    (_) => const NewPasswordScreen(),
        '/otp-verify':      (_) => const OtpScreen(),
        '/otp-success':     (_) => const OtpSuccessScreen(),
        // Consumer
        '/':            (_) => const ConsumerNavigation(),
        '/cart':        (_) => const CartScreen(),
        '/checkout':    (_) => const CheckoutScreen(),
        '/orders':      (_) => const OrdersScreen(),
        '/order-tracking': (_) => const OrderTrackingScreen(),
        '/chat':        (_) => const ChatScreen(),
        // Farmer
        '/farmer-home': (_) => const FarmerNavigation(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product-detail') {
          return MaterialPageRoute(
            builder: (_) => const ProductDetailScreen(),
            settings: settings,
          );
        }
        if (settings.name == '/register') {
          final args = settings.arguments as Map<String, dynamic>?;
          final role = args?['role'] as String? ?? 'consumer';
          return MaterialPageRoute(
            builder: (_) => RegisterScreen(role: role),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
