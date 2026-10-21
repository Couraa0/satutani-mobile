import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'screens/farmer/home/farmer_home_screen.dart';
import 'screens/farmer/products/farmer_products_screen.dart';
import 'screens/farmer/orders/farmer_orders_screen.dart';
import 'screens/farmer/revenue/revenue_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/app_nav_bar.dart';
import 'widgets/voice_hub/floating_voice_hub.dart';

class FarmerNavigation extends StatefulWidget {
  const FarmerNavigation({super.key});

  @override
  State<FarmerNavigation> createState() => _FarmerNavigationState();
}

class _FarmerNavigationState extends State<FarmerNavigation> {
  int _idx = 0;

  late final _screens = [
    FarmerHomeScreen(onOpenTab: (i) => setState(() => _idx = i)),
    const FarmerProductsScreen(),
    const FarmerOrdersScreen(),
    const RevenueScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _idx, children: _screens),

          // Floating Voice Assistant Hub in Bottom Right Corner
          const Positioned(
            bottom: 24,
            right: 16,
            child: FloatingVoiceHub(),
          ),
        ],
      ),
      bottomNavigationBar: AppNavBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          AppNavItem(icon: Iconsax.home_2_copy, activeIcon: Iconsax.home_2, label: 'Beranda'),
          AppNavItem(icon: Iconsax.box_copy, activeIcon: Iconsax.box, label: 'Produk'),
          AppNavItem(icon: Iconsax.receipt_2_copy, activeIcon: Iconsax.receipt_2, label: 'Pesanan'),
          AppNavItem(icon: Iconsax.wallet_3_copy, activeIcon: Iconsax.wallet_3, label: 'Dompet'),
          AppNavItem(icon: Iconsax.profile_circle_copy, activeIcon: Iconsax.profile_circle, label: 'Profil'),
        ],
      ),
    );
  }
}
