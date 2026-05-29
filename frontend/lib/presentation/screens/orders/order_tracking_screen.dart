import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/mock/orders_mock.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // using mock data for demo
    final order = mockOrders.first;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Lacak Pesanan', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
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
            child: _buildMapBackground(context, order),
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -5)),
                ]
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
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
                        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildTrackingStatusCard(context, order),
                            const SizedBox(height: 24),
                            _buildColdChainCard(),
                            const SizedBox(height: 24),
                            _buildAdditionalItemsSection(order),
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

  Widget _buildMapBackground(BuildContext context, OrderModel order) {
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
            child: SafeArea(child: _buildMapMarker(Icons.storefront_rounded, label: order.farmerName)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.18,
            right: 40,
            child: SafeArea(child: _buildMapMarker(Icons.person_rounded, isPrimary: true, label: "Lokasi Anda")),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
            ),
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isPrimary ? Colors.white : Colors.black87,
            shape: BoxShape.circle,
            border: Border.all(color: isPrimary ? AppColors.primary : Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
          ),
          child: Icon(icon, color: isPrimary ? AppColors.primary : Colors.white, size: 22),
        ),
      ],
    );
  }

  // === Front Panel Cards ===

  Widget _buildTrackingStatusCard(BuildContext context, OrderModel order) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pesanan Diproses', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Text('Tiba antara 09:12 - 09:43', style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 28),
                _buildHorizontalStepper(),
                const SizedBox(height: 28),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 16),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tampilkan detail pesanan', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.grey[700]),
                    ],
                  ),
                )
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.access_time_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('8 menit lagi pesanan tiba', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHorizontalStepper() {
    return Row(
      children: [
        _buildStepIcon(Icons.storefront_rounded, true),
        _buildConnector(true),
        _buildStepIcon(Icons.shopping_basket_rounded, true),
        _buildConnector(false),
        _buildStepIcon(Icons.local_shipping_rounded, false),
        _buildConnector(false),
        _buildStepIcon(Icons.home_rounded, false),
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
          width: isActive ? 0 : 2
        ),
        boxShadow: isActive ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))] : null,
      ),
      child: Icon(icon, size: 20, color: isActive ? Colors.white : const Color(0xFF9CA3AF)),
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

  // === Additional Content Items ===

  Widget _buildAdditionalItemsSection(OrderModel order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Beli lagi dari toko ini', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                SizedBox(height: 4),
                Text('Tanpa minimum pesanan.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            Icon(Icons.arrow_forward_rounded, color: Colors.grey[400], size: 20),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 148, 
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final items = [
                {'name': 'Sayur Pakcoy', 'price': 'Rp 14.000', 'rating': '4.8'},
                {'name': 'Tomat Ceri', 'price': 'Rp 22.000', 'rating': '4.9'},
                {'name': 'Cabai Merah', 'price': 'Rp 8.000', 'rating': '4.7'},
                {'name': 'Wortel Manis', 'price': 'Rp 12.000', 'rating': '4.6'},
              ];
              final item = items[index];
              return Container(
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 70,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                      ),
                      child: const Center(
                        child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 32),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                                const SizedBox(width: 4),
                                Text(item['rating']!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ],
                            ),
                            Text(item['name']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            Text(item['price']!, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }

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
              Text('Monitor Suhu Cold-Chain', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.info, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _sensorCard('🌡️', 'Suhu Penyimpanan', '4°C', AppColors.info)),
              const SizedBox(width: 12),
              Expanded(child: _sensorCard('💧', 'Kelembapan', '85%', AppColors.primary)),
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
        color: Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
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
      
    // Draw some typical map lines
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.4), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.5, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.6), paint);
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
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.8, size.width, size.height * 0.6);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
