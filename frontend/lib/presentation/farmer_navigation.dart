import 'package:flutter/material.dart';
import 'screens/farmer/home/farmer_home_screen.dart';
import 'screens/farmer/products/farmer_products_screen.dart';
import 'screens/farmer/orders/farmer_orders_screen.dart';
import 'screens/farmer/revenue/revenue_screen.dart';
import 'screens/profile/profile_screen.dart';
import '../core/constants/colors.dart';

class FarmerNavigation extends StatefulWidget {
  const FarmerNavigation({super.key});
  @override
  State<FarmerNavigation> createState() => _FarmerNavigationState();
}

class _FarmerNavigationState extends State<FarmerNavigation> {
  int _idx = 0;

  final _screens = const [
    FarmerHomeScreen(),
    FarmerProductsScreen(),
    FarmerOrdersScreen(),
    RevenueScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), activeIcon: Icon(Icons.inventory_2_rounded), label: 'Produk'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long_rounded), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet_rounded), label: 'Pendapatan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
        ],
      ),
    );
  }
}
