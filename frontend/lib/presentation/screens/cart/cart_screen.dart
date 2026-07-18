import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/colors.dart';
import '../../../data/cart_state.dart';
import '../../consumer_navigation.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> get cart => globalCart;

  double get subtotal =>
      cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  int get totalQty => cart.fold(0, (sum, item) => sum + item.quantity);

  static String _rp(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  void _goShopping() {
    // Dari tab: pindah ke tab Jelajahi. Dari halaman push ('/cart'): tutup dulu.
    if (Navigator.canPop(context)) Navigator.pop(context);
    ConsumerNavigation.tabIndex.value = 1;
  }

  void _removeWithUndo(int index) {
    final removed = cart[index];
    removeFromCart(index);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${removed.product.name} dihapus dari keranjang'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Urungkan',
            onPressed: () =>
                addToCart(removed.product, quantity: removed.quantity),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    // Dibungkus ValueListenableBuilder agar tab Keranjang ikut update saat
    // produk ditambahkan dari layar lain (CartScreen hidup di IndexedStack).
    return ValueListenableBuilder<int>(
      valueListenable: cartNotifier,
      builder: (context, _, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(cart.isEmpty
                ? 'Keranjang Saya'
                : 'Keranjang Saya (${cart.length} produk)'),
          ),
          body: cart.isEmpty
              ? _buildEmpty()
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        itemCount: cart.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _buildCartItem(index),
                      ),
                    ),
                    _buildSummary(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                  color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Center(
                  child: Text('🛒', style: TextStyle(fontSize: 52))),
            ),
            const SizedBox(height: 24),
            const Text('Keranjang masih kosong',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text(
              'Yuk, jelajahi produk segar\nlangsung dari petani',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14.5,
                  color: AppColors.textSecondary,
                  height: 1.45),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _goShopping,
                icon: const Icon(Icons.storefront_rounded, size: 20),
                label: const Text('Mulai Belanja',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        )
            .animate()
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.06, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = cart[index];
    final p = item.product;
    final lineTotal = p.price * item.quantity;

    return Dismissible(
      key: ValueKey('${p.id}-$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeWithUndo(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text('Hapus',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 76,
                height: 76,
                child: p.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: p.imageUrls.first,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.primaryLight),
                        errorWidget: (_, __, ___) => const _ImgFallback(),
                      )
                    : const _ImgFallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(p.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
                                height: 1.25)),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _removeWithUndo(index),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.delete_outline_rounded,
                              color: AppColors.danger, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (p.farmerName.isNotEmpty)
                    Row(children: [
                      const Icon(Icons.storefront_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(p.farmerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textSecondary)),
                      ),
                    ]),
                  const SizedBox(height: 4),
                  Text('Rp ${_rp(p.price)}/${p.unit}',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _CartStepper(
                        quantity: item.quantity,
                        onDecrement: () => item.quantity == 1
                            ? _removeWithUndo(index)
                            : decrementQty(index),
                        onIncrement: () => incrementQty(index),
                      ),
                      const Spacer(),
                      Text('Rp ${_rp(lineTotal)}',
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal ($totalQty item)',
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.textSecondary)),
                Text('Rp ${_rp(subtotal)}',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Icon(Icons.local_shipping_outlined,
                    size: 14, color: AppColors.textSecondary),
                SizedBox(width: 6),
                Text('Ongkos kirim dihitung saat checkout',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            const Divider(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        fontSize: 15.5, fontWeight: FontWeight.w800)),
                Text('Rp ${_rp(subtotal)}',
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/checkout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Checkout ($totalQty item)',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _CartStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CartStepper(
      {required this.quantity,
      required this.onDecrement,
      required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(
            icon: quantity == 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            color: quantity == 1 ? AppColors.danger : AppColors.primary,
            onTap: onDecrement,
          ),
          SizedBox(
            width: 34,
            child: Center(
              child: Text('$quantity',
                  style: const TextStyle(
                      fontSize: 14.5, fontWeight: FontWeight.w800)),
            ),
          ),
          _btn(
            icon: Icons.add_rounded,
            color: AppColors.primary,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _btn(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 19, color: color),
        ),
      ),
    );
  }
}

class _ImgFallback extends StatelessWidget {
  const _ImgFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
          child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 30)),
    );
  }
}
