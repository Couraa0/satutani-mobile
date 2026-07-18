import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/order_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/user_service.dart';
import '../../widgets/address_sheet.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/cart_state.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _deliveryMethod = 'cold_chain';
  String _paymentMethod = 'qris';
  bool _isLoading = false;

  List<CartItem> get _cart => globalCart;

  double get _subtotal =>
      _cart.fold(0, (sum, item) => sum + item.product.price * item.quantity);
  double get _shipping =>
      _cart.isEmpty ? 0 : (_deliveryMethod == 'cold_chain' ? 25000 : 10000);
  double get _total => _subtotal + _shipping;

  String get _userName {
    final user = auth.currentUser;
    final meta = user?.userMetadata;
    return (meta?['name'] as String?)?.trim().isNotEmpty == true
        ? meta!['name'] as String
        : (user?.email ?? 'Pengguna');
  }

  String _address = '';

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final profile = await UserService.getMyProfile();
    if (mounted) {
      setState(() => _address = (profile?['address'] as String?) ?? '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.checkoutTitle),
      ),
      body: _cart.isEmpty
          ? _buildEmpty()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAddressSection(),
                        const SizedBox(height: 16),
                        _buildProductSummary(),
                        const SizedBox(height: 16),
                        _buildDeliverySection(),
                        const SizedBox(height: 16),
                        _buildPaymentSection(),
                        const SizedBox(height: 16),
                        _buildPriceSummary(),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(),
              ],
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart_outlined,
              size: 72, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text('Keranjang masih kosong',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali')),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _buildAddressSection() {
    return _buildSection(
      AppStrings.deliveryAddress,
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.primaryGreen, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(
                    _address.isNotEmpty
                        ? _address
                        : 'Atur alamat pengiriman di profil',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                final changed = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
                    child: AddressSheet(current: _address),
                  ),
                );
                if (changed == true) _loadAddress();
              },
              child: const Text(AppStrings.changeAddress, style: TextStyle(color: AppColors.primaryGreen)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSummary() {
    return _buildSection(
      'Ringkasan Produk',
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
        child: Column(
          children: [
            for (int i = 0; i < _cart.length; i++) ...[
              if (i > 0) const Divider(height: 12),
              _compactItem(
                _cart[i].product.name,
                '${_cart[i].quantity} ${_cart[i].product.unit}',
                _cart[i].product.price * _cart[i].quantity,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _compactItem(String name, String qty, double price) {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          Text(qty, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Text(CurrencyFormatter.format(price), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 13)),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return _buildSection(
      AppStrings.deliveryMethod,
      Column(
        children: [
          _deliveryOption('cold_chain', '❄️ ${AppStrings.coldChain}', 'Kontrol suhu real-time, cocok untuk sayur & buah', 'Rp 25.000'),
          const SizedBox(height: 8),
          _deliveryOption('regular', '📦 ${AppStrings.regular}', 'Pengiriman standar 1-2 hari', 'Rp 10.000'),
        ],
      ),
    );
  }

  Widget _deliveryOption(String value, String title, String subtitle, String price) {
    final selected = _deliveryMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _deliveryMethod = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.borderColor, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.borderColor, width: selected ? 6 : 1.5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ])),
            Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _buildSection(
      AppStrings.paymentMethod,
      Column(
        children: [
          _paymentOption('qris', 'QRIS', Icons.qr_code_rounded),
          const SizedBox(height: 8),
          _paymentOption('transfer', 'Transfer Bank', Icons.account_balance_rounded),
        ],
      ),
    );
  }

  Widget _paymentOption(String value, String label, IconData icon) {
    final selected = _paymentMethod == value;
    return GestureDetector(
      onTap: () => setState(() => _paymentMethod = value),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreen.withValues(alpha: 0.06) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.borderColor, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.borderColor, width: selected ? 6 : 1.5),
              ),
            ),
            const SizedBox(width: 10),
            Icon(icon, color: AppColors.primaryGreen, size: 22),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary() {
    return _buildSection(
      AppStrings.priceSummary,
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderColor)),
        child: Column(
          children: [
            _priceRow(AppStrings.subtotal, _subtotal),
            const SizedBox(height: 6),
            _priceRow(AppStrings.shipping, _shipping),
            const Divider(height: 16),
            _priceRow(AppStrings.total, _total, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: bold ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(CurrencyFormatter.format(amount), style: TextStyle(fontSize: 13, color: bold ? AppColors.primaryGreen : AppColors.textPrimary, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -3))]),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _placeOrder,
          child: _isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text('${AppStrings.payNow}  •  ${CurrencyFormatter.format(_total)}'),
        ),
      ),
    );
  }

  /// Karena 1 baris Order di backend = 1 produk, satu checkout dikirim sebagai
  /// beberapa order (satu per item keranjang). Ongkir dibebankan ke order pertama.
  Future<void> _placeOrder() async {
    if (_cart.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      for (int i = 0; i < _cart.length; i++) {
        final item = _cart[i];
        final productId = item.product.id.isNotEmpty ? item.product.id : null;
        final farmerId =
            item.product.farmerId.isNotEmpty ? item.product.farmerId : null;

        await OrderService.createOrder({
          'productId': productId,
          'productName': item.product.name,
          'productImageUrl':
              item.product.imageUrls.isNotEmpty ? item.product.imageUrls.first : '',
          'farmerName': item.product.farmerName,
          'farmerId': farmerId,
          'quantity': item.quantity,
          'unit': item.product.unit,
          'pricePerUnit': item.product.price,
          'shippingCost': i == 0 ? _shipping : 0,
          'deliveryMethod': _deliveryMethod,
        });
      }

      clearCart();
      if (mounted) _showPaymentSuccess(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPaymentSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 64),
          const SizedBox(height: 12),
          const Text('Pesanan Berhasil!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pesanan Anda sedang diproses petani.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(context, '/orders', (_) => false);
            },
            child: const Text('Lihat Pesanan'),
          ),
        ]),
      ),
    );
  }
}
