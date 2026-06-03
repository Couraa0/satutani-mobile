import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/consumer_order.dart';
import '../../../data/mock/orders_mock.dart' show OrderStatus, OrderStatusExt;

class OrderTrackingScreen extends StatelessWidget {
  final ConsumerOrder? order;
  const OrderTrackingScreen({super.key, this.order});

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  String _qty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  /// 0 = dikonfirmasi, 1 = dipanen/disiapkan, 2 = dikirim, 3 = diterima.
  int get _activeStep {
    switch (order?.status) {
      case OrderStatus.dipanen:
        return 1;
      case OrderStatus.dikirim:
        return 2;
      case OrderStatus.selesai:
        return 3;
      case OrderStatus.dikonfirmasi:
      default:
        return 0;
    }
  }

  String get _statusTitle {
    switch (order?.status) {
      case OrderStatus.menunggu:
        return 'Menunggu Konfirmasi';
      case OrderStatus.dipanen:
        return 'Sedang Disiapkan';
      case OrderStatus.dikirim:
        return 'Dalam Pengiriman';
      case OrderStatus.selesai:
        return 'Pesanan Selesai';
      case OrderStatus.dibatalkan:
        return 'Pesanan Dibatalkan';
      case OrderStatus.dikonfirmasi:
      default:
        return 'Pesanan Dikonfirmasi';
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmerName = order?.farmerName ?? 'Petani';

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lacak Pesanan',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [
          // Background - Map Placeholder
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.45,
            child: _buildMapBackground(context, farmerName),
          ),

          // Foreground Sliding Panel-like UI
          Positioned(
            top: MediaQuery.of(context).size.height * 0.38,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -5)),
                  ]),
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 12, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Drag handle indicator
                      Container(
                        width: 48,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildTrackingStatusCard(context),
                            if (order != null) ...[
                              const SizedBox(height: 24),
                              _buildOrderDetailCard(),
                            ],
                            if (order?.deliveryMethod == 'cold_chain') ...[
                              const SizedBox(height: 24),
                              _buildColdChainCard(),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === Map Background Components ===

  Widget _buildMapBackground(BuildContext context, String farmerName) {
    return Container(
      decoration: const BoxDecoration(color: Color(0xFFE5EAD2)),
      child: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: Opacity(
                opacity: 0.3,
                child: CustomPaint(painter: _GridPainter()),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 80,
            right: 80,
            height: 100,
            child: CustomPaint(painter: _RoutePainter()),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.10,
            left: 40,
            child: SafeArea(
                child: _buildMapMarker(Icons.storefront_rounded,
                    label: farmerName)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            right: 40,
            child: SafeArea(
                child: _buildMapMarker(Icons.person_rounded,
                    isPrimary: true, label: "Lokasi Anda")),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMarker(IconData icon, {bool isPrimary = false, String? label}) {
    return Column(
      children: [
        if (label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.only(bottom: 6),
            constraints: const BoxConstraints(maxWidth: 140),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)
              ],
            ),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
          ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.black87,
            shape: BoxShape.circle,
            border: Border.all(
                color: isPrimary ? AppColors.primary : Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Icon(icon,
              color: isPrimary ? AppColors.primary : Colors.white, size: 22),
        ),
      ],
    );
  }

  // === Front Panel Cards ===

  Widget _buildTrackingStatusCard(BuildContext context) {
    final subtitle = order != null
        ? '#${order!.id}'
        : 'Tiba antara 09:12 - 09:43';
    final isCancelled = order?.status == OrderStatus.dibatalkan;

    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8)),
            BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ]),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_statusTitle,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500)),
                if (!isCancelled) ...[
                  const SizedBox(height: 28),
                  _buildHorizontalStepper(),
                ],
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
                color: isCancelled ? AppColors.danger : AppColors.primary,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    isCancelled
                        ? Icons.cancel_outlined
                        : Icons.access_time_rounded,
                    color: Colors.white,
                    size: 20),
                const SizedBox(width: 8),
                Text(
                    order != null
                        ? (isCancelled
                            ? 'Pesanan dibatalkan'
                            : 'Status: ${order!.status.label}')
                        : '8 menit lagi pesanan tiba',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHorizontalStepper() {
    final active = _activeStep;
    return Row(
      children: [
        _buildStepIcon(Icons.storefront_rounded, active >= 0),
        _buildConnector(active >= 1),
        _buildStepIcon(Icons.shopping_basket_rounded, active >= 1),
        _buildConnector(active >= 2),
        _buildStepIcon(Icons.local_shipping_rounded, active >= 2),
        _buildConnector(active >= 3),
        _buildStepIcon(Icons.home_rounded, active >= 3),
      ],
    );
  }

  Widget _buildStepIcon(IconData icon, bool isActive) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFFE5E7EB),
            width: isActive ? 0 : 2),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ]
            : null,
      ),
      child: Icon(icon,
          size: 20,
          color: isActive ? Colors.white : const Color(0xFF9CA3AF)),
    );
  }

  Widget _buildConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 3,
        color: isActive ? AppColors.primary : const Color(0xFFE5E7EB),
      ),
    );
  }

  // === Order Detail (real data) ===

  Widget _buildOrderDetailCard() {
    final o = order!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Detail Pesanan',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: o.productImageUrl.isNotEmpty
                      ? Image.network(o.productImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imgFallback())
                      : _imgFallback(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                        '${_qty(o.quantity)} ${o.unit} × Rp ${_fmt(o.pricePerUnit)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: Color(0xFFF0F0F0)),
          _priceRow('Subtotal', o.subtotal, _fmt),
          const SizedBox(height: 8),
          _priceRow('Ongkir', o.shippingCost, _fmt),
          const Divider(height: 28, color: Color(0xFFF0F0F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15)),
              Text('Rp ${_fmt(o.total)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, double value, String Function(double) fmt) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
        Text('Rp ${fmt(value)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _imgFallback() => Container(
        color: AppColors.background,
        child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
      );

  Widget _buildColdChainCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.ac_unit_rounded, color: AppColors.info, size: 18),
              SizedBox(width: 8),
              Text('Monitor Suhu Cold-Chain',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.info,
                      fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _sensorCard(
                      '🌡️', 'Suhu Penyimpanan', '4°C', AppColors.info)),
              const SizedBox(width: 12),
              Expanded(
                  child: _sensorCard(
                      '💧', 'Kelembapan', '85%', AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sensorCard(String emoji, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// Custom Painters for Background
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height * 0.3),
        Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.5, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.7),
        Offset(size.width, size.height * 0.6), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(
        size.width * 0.4, size.height * 0.8, size.width, size.height * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
