import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart';
import 'screens/orders/orders_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/cart/cart_screen.dart';
import '../core/constants/colors.dart';

class ConsumerNavigation extends StatefulWidget {
  const ConsumerNavigation({super.key});

  /// Index tab aktif. Layar anak (mis. Beranda) bisa mengubah nilai ini untuk
  /// berpindah tab, contoh: `ConsumerNavigation.tabIndex.value = 1` → Jelajahi.
  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);

  @override
  State<ConsumerNavigation> createState() => _ConsumerNavigationState();
}

class _ConsumerNavigationState extends State<ConsumerNavigation>
    with SingleTickerProviderStateMixin {
  int _idx = 0;
  late AnimationController _fabAnimCtrl;
  late Animation<double> _fabAnim;

  final _screens = const [
    HomeScreen(),
    ExploreScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    ConsumerNavigation.tabIndex.addListener(_onTabChanged);
    // Animasi mengambang FAB chatbot — sama seperti sisi Penjual.
    _fabAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _fabAnim = Tween<double>(begin: 0.0, end: 6.0).animate(
      CurvedAnimation(parent: _fabAnimCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    ConsumerNavigation.tabIndex.removeListener(_onTabChanged);
    _fabAnimCtrl.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (mounted) setState(() => _idx = ConsumerNavigation.tabIndex.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(index: _idx, children: _screens),
          // Floating AI Chat Button
          Positioned(
            bottom: 24,
            right: 16,
            child: AnimatedBuilder(
              animation: _fabAnim,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -_fabAnim.value),
                  child: child,
                );
              },
              child: const _AiChatFab(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Beranda', index: 0, currentIndex: _idx, onTap: _select),
                _NavItem(icon: Icons.search_outlined, activeIcon: Icons.search_rounded, label: 'Jelajahi', index: 1, currentIndex: _idx, onTap: _select),
                _NavItem(icon: Icons.shopping_cart_outlined, activeIcon: Icons.shopping_cart_rounded, label: 'Keranjang', index: 2, currentIndex: _idx, onTap: _select),
                _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Pesanan', index: 3, currentIndex: _idx, onTap: _select),
                _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil', index: 4, currentIndex: _idx, onTap: _select),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _select(int i) => ConsumerNavigation.tabIndex.value = i;
}

/// FAB chatbot AI — desain, logo, dan animasi sama dengan sisi Penjual.
class _AiChatFab extends StatefulWidget {
  const _AiChatFab();

  @override
  State<_AiChatFab> createState() => _AiChatFabState();
}

class _AiChatFabState extends State<_AiChatFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _ctrl.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _ctrl.reverse();
    Navigator.pushNamed(context, '/chat');
  }

  void _onTapCancel() {
    _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00441b).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: AppColors.primaryLight, width: 3),
          ),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Custom Image Bot Icon
              ClipOval(
                child: Image.asset(
                  'assets/images/tanibot.png',
                  width: 58,
                  height: 58,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback jika gambar belum ditambahkan
                    return Container(
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.smart_toy_rounded,
                          color: AppColors.primary, size: 30),
                    );
                  },
                ),
              ),
              // Status Indicator Online
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ADE80).withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            ],
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
        padding:
            EdgeInsets.symmetric(horizontal: isActive ? 16 : 12, vertical: 8),
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
              size: 24,
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
