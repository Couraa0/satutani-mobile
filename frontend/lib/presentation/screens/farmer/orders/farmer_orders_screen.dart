import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/mock/orders_mock.dart';
import '../../../../presentation/widgets/status_badge.dart';
import 'contact_courier_screen.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});
  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> with TickerProviderStateMixin {
  late TabController _tab;
  final _tabs = ['Semua', 'Menunggu', 'Dikonfirmasi', 'Dipanen', 'Dikirim', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  List<OrderModel> _ordersForTab(int i) {
    if (i == 0) return mockOrders;
    final status = OrderStatus.values[i - 1];
    return mockOrders.where((o) => o.status == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesanan'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true, tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: List.generate(_tabs.length, (i) {
          final list = _ordersForTab(i);
          if (list.isEmpty) return const Center(child: Text('Tidak ada pesanan', style: TextStyle(color: AppColors.textSecondary)));
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, j) => _FarmerOrderCard(order: list[j]),
          );
        }),
      ),
    );
  }
}

class _FarmerOrderCard extends StatelessWidget {
  final OrderModel order;
  const _FarmerOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          StatusBadge(status: order.status),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text('${order.consumerName} · ${order.consumerType}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ]),
        const SizedBox(height: 6),
        ...order.items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text('• ${item.productName} × ${item.quantity} ${item.unit}',
            style: const TextStyle(fontSize: 12)),
        )),
        const Divider(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Total: Rp ${order.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
          _ActionButtons(status: order.status, order: order),
        ]),
      ]),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final OrderStatus status;
  final OrderModel order;
  const _ActionButtons({required this.status, required this.order});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case OrderStatus.menunggu:
        return Row(children: [
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger),
              minimumSize: const Size(60, 34), padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: const Text('Tolak', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary,
              minimumSize: const Size(80, 34), padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: const Text('Konfirmasi', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ]);
      case OrderStatus.dikonfirmasi:
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, minimumSize: const Size(120, 34)),
          child: const Text('Tandai Dipanen', style: TextStyle(fontSize: 12, color: Colors.white)),
        );
      case OrderStatus.dipanen:
        return ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(
            builder: (_) => ContactCourierScreen(order: order),
          )),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.info, minimumSize: const Size(120, 34)),
          child: const Text('Hubungi Kurir', style: TextStyle(fontSize: 12, color: Colors.white)),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
