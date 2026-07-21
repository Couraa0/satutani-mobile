import 'package:flutter/material.dart';
import 'screens/farmer/home/farmer_home_screen.dart';
import 'screens/farmer/products/farmer_products_screen.dart';
import 'screens/farmer/orders/farmer_orders_screen.dart';
import 'screens/farmer/revenue/revenue_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'widgets/voice_hub/floating_voice_hub.dart';
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
      body: Stack(
        children: [
          IndexedStack(index: _idx, children: _screens),

          // Central Floating Voice Hub (Voice-First Microphone Assistant)
          const Positioned(
            bottom: 24,
            right: 0,
            left: 0,
            child: Center(
              child: FloatingVoiceHub(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Beranda',
                  index: 0,
                  currentIndex: _idx,
                  onTap: (i) => setState(() => _idx = i),
                ),
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  label: 'Produk',
                  index: 1,
                  currentIndex: _idx,
                  onTap: (i) => setState(() => _idx = i),
                ),
                const SizedBox(width: 48), // Center spacing for Floating Voice Hub
                _NavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Pesanan',
                  index: 2,
                  currentIndex: _idx,
                  onTap: (i) => setState(() => _idx = i),
                ),
                _NavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet_rounded,
                  label: 'Dompet',
                  index: 3,
                  currentIndex: _idx,
                  onTap: (i) => setState(() => _idx = i),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(horizontal: isActive ? 14 : 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
