import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../data/mock/products_mock.dart';

class CartItem {
  final ProductModel product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

final List<CartItem> globalCart = [
  CartItem(product: mockProducts[0], quantity: 2),
  CartItem(product: mockProducts[1], quantity: 3),
];

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> get cart => globalCart;

  double get subtotal => cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  double get shipping => cart.isEmpty ? 0 : 10000;
  double get total => subtotal + shipping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${AppStrings.cartTitle} (${cart.length} item)'),
      ),
      body: cart.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) => _buildCartItem(index),
                  ),
                ),
                _buildSummary(),
              ],
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined, size: 72, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('Keranjang masih kosong', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Mulai Belanja')),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = cart[index];
    final String priceStr = item.product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: item.product.imageUrls.isNotEmpty
                ? Image.network(item.product.imageUrls.first, width: 64, height: 64, fit: BoxFit.cover)
                : Container(width: 64, height: 64, color: AppColors.primaryLight, child: const Icon(Icons.eco, color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text('Rp $priceStr / ${item.product.unit}',
                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(item.product.farmerName,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => cart.removeAt(index)),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
              ),
              const SizedBox(height: 8),
              _CartStepper(
                quantity: item.quantity,
                onDecrement: () => setState(() {
                  if (item.quantity > 1) {
                    item.quantity--;
                  } else {
                    cart.removeAt(index);
                  }
                }),
                onIncrement: () => setState(() => item.quantity++),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    final subFmt = subtotal.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    final shipFmt = shipping.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    final totFmt = total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _summaryRow('Subtotal', 'Rp $subFmt'),
            const SizedBox(height: 4),
            _summaryRow('Ongkos Kirim', 'Rp $shipFmt'),
            const Divider(height: 16),
            _summaryRow('Total', 'Rp $totFmt', isBold: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/checkout'),
              child: const Text('Lanjut Pembayaran'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? AppColors.textPrimary : AppColors.textSecondary)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: isBold ? AppColors.primary : AppColors.textPrimary)),
      ],
    );
  }
}

class _CartStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _CartStepper({required this.quantity, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(onTap: onDecrement, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.remove_rounded, size: 14, color: AppColors.primary))),
          Text('$quantity', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          GestureDetector(onTap: onIncrement, child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.add_rounded, size: 14, color: AppColors.primary))),
        ],
      ),
    );
  }
}
