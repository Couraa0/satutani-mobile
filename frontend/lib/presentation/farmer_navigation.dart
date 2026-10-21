import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B2A14).withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
            child: Row(
              children: [
                _NavItem(
                  icon: Iconsax.home_2_copy,
                  activeIcon: Iconsax.home_2,
                  label: 'Beranda',
                  index: 0,
                  currentIndex: _idx,
                  onTap: (i) => setState(() => _idx = i),
                ),
                _NavItem(
                  icon: Iconsax.box_copy,
                  activeIcon: Iconsax.box,
                  label: 'Produk',
                  index: 1,
                  currentIndex: _idx,
                  onTap: (i) => setState(() => _idx = i),
                ),
                _NavItem(
                  icon: Iconsax.receipt_2_copy,
                  activeIcon: Iconsax.receipt_2,
                  label: 'Pesanan',
                  index: 2,
                  currentIndex: _idx,
                  onTap: (i) => setState(() => _idx = i),
                ),
                _NavItem(
                  icon: Iconsax.wallet_3_copy,
                  activeIcon: Iconsax.wallet_3,
                  label: 'Dompet',
                  index: 3,
                  currentIndex: _idx,
                  onTap: (i) => setState(() => _idx = i),
                ),
                _NavItem(
                  icon: Iconsax.profile_circle_copy,
                  activeIcon: Iconsax.profile_circle,
                  label: 'Profil',
                  index: 4,
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
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: isActive ? 52 : 40,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryLight : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
