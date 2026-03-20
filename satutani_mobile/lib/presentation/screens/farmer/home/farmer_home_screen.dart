import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../data/mock/orders_mock.dart';
import '../../../../data/mock/products_mock.dart';
import '../../../../presentation/widgets/kpi_card.dart';
import '../../../../presentation/widgets/section_header.dart';
import '../../../../presentation/widgets/status_badge.dart';
import '../products/add_product_screen.dart';

class FarmerHomeScreen extends StatelessWidget {
  const FarmerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            pinned: true, expandedHeight: 120,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Halo, Pak Budi! 👋', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Senin, 16 Mar 2026', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                      ]),
                      Row(children: [
                        Stack(children: [
                          IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26), onPressed: () {}),
                          Positioned(top: 8, right: 8, child: Container(width: 8, height: 8,
                            decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle))),
                        ]),
                        const CircleAvatar(backgroundColor: Colors.white24, radius: 18,
                          child: Icon(Icons.person_rounded, color: Colors.white, size: 20)),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Cards
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(children: [
                      const KpiCard(icon: Icons.payments_outlined, label: 'Pendapatan Hari Ini', value: 'Rp 450.000', trend: '+12% dari kemarin', trendPositive: true),
                      const SizedBox(width: 12),
                      const KpiCard(icon: Icons.receipt_long_rounded, label: 'Pesanan Aktif', value: '8', trend: '3 menunggu konfirmasi', trendPositive: true, iconColor: AppColors.info),
                      const SizedBox(width: 12),
                      const KpiCard(icon: Icons.inventory_2_outlined, label: 'Stok Hampir Habis', value: '3 produk', trend: 'Segera restok!', trendPositive: false, iconColor: AppColors.warning),
                      const SizedBox(width: 12),
                      const KpiCard(icon: Icons.star_rounded, label: 'Rating', value: '4.9 ⭐', trend: '+0.2 bulan ini', trendPositive: true, iconColor: AppColors.secondary),
                    ]),
                  ),
                ),
                // Panen alert
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Text('🌾', style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Panen Tomat dalam 3 hari!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      SizedBox(height: 2),
                      Text('Siapkan jadwal dan kurir untuk panen berikutnya.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ])),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.warning),
                  ]),
                ),
                // Quick actions
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  childAspectRatio: 2.4, mainAxisSpacing: 10, crossAxisSpacing: 10,
                  children: [
                    _QuickAction(icon: Icons.add_box_outlined, label: AppStrings.addProduct, color: AppColors.primary, onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
                    }),
                    _QuickAction(icon: Icons.psychology_outlined, label: AppStrings.aiPricing, color: AppColors.info, onTap: () {}),
                    _QuickAction(icon: Icons.analytics_outlined, label: AppStrings.marketForecast, color: AppColors.secondary, onTap: () {}),
                    _QuickAction(icon: Icons.account_balance_outlined, label: AppStrings.applyKur, color: AppColors.success, onTap: () {}),
                  ],
                ),
                // Recent orders
                const SizedBox(height: 24),
                SectionHeader(title: 'Pesanan Terbaru', actionLabel: AppStrings.viewAll, onAction: () {}),
                const SizedBox(height: 12),
                ...mockOrders.take(3).map((o) => _OrderCard(order: o)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color), maxLines: 2)),
        ]),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(width: 8),
            StatusBadge(status: order.status, fontSize: 10),
          ]),
          const SizedBox(height: 4),
          Text(order.consumerName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('${order.items.length} produk · Rp ${order.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ])),
        Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ]),
    );
  }
}
