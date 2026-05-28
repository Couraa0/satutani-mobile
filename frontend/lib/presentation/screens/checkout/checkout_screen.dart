import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/currency_formatter.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _deliveryMethod = 'cold_chain';
  String _paymentMethod = 'qris';

  final double _subtotal = 43000;
  double get _shipping => _deliveryMethod == 'cold_chain' ? 25000 : 10000;
  double get _total => _subtotal + _shipping;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: const Text(AppStrings.checkoutTitle),
      ),
      body: Column(
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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Andi Pratama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text('Jl. Sudirman No. 45, Jakarta Pusat, DKI Jakarta 10220', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            TextButton(onPressed: () {}, child: const Text(AppStrings.changeAddress, style: TextStyle(color: AppColors.primaryGreen))),
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
            _compactItem('Beras Premium Cianjur', '2 kg', 28000),
            const Divider(height: 12),
            _compactItem('Bayam Organik Segar', '3 ikat', 15000),
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
          onPressed: () => _showPaymentSuccess(context),
          child: Text('${AppStrings.payNow}  •  ${CurrencyFormatter.format(_total)}'),
        ),
      ),
    );
  }

  void _showPaymentSuccess(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen, size: 64),
          const SizedBox(height: 12),
          const Text('Pembayaran Berhasil!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Pesanan Anda sedang diproses petani.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () { Navigator.pop(context); Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false); }, child: const Text('Kembali ke Home')),
        ]),
      ),
    );
  }
}
