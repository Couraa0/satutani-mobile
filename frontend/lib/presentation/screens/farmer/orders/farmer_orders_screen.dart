import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/order_service.dart';
import '../../../../data/models/farmer_order.dart';
import '../../../../data/mock/orders_mock.dart' show OrderStatus;
import '../../../../presentation/widgets/status_badge.dart';
import 'contact_courier_screen.dart';

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});
  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tab;
  final _tabs = ['Semua', 'Menunggu', 'Dikonfirmasi', 'Dipanen', 'Dikirim', 'Selesai'];

  late Future<List<FarmerOrder>> _future;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: _tabs.length, vsync: this);
    _future = _load();
  }

  Future<List<FarmerOrder>> _load() async {
    final raw = await OrderService.getFarmerOrders();
    return FarmerOrder.listFromJson(raw);
  }

  void _reload() => setState(() {
        _future = _load();
      });

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  List<FarmerOrder> _ordersForTab(List<FarmerOrder> all, int i) {
    if (i == 0) return all;
    final status = OrderStatus.values[i - 1];
    return all.where((o) => o.status == status).toList();
  }

  Future<void> _changeStatus(FarmerOrder order, String backendStatus) async {
    try {
      await OrderService.updateOrderStatus(order.id, backendStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status pesanan diperbarui')),
      );
      _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesanan'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: FutureBuilder<List<FarmerOrder>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _ErrorState(message: '${snap.error}', onRetry: _reload);
          }
          final all = snap.data ?? [];
          return TabBarView(
            controller: _tab,
            children: List.generate(_tabs.length, (i) {
              final list = _ordersForTab(all, i);
              if (list.isEmpty) {
                return const Center(
                  child: Text('Tidak ada pesanan',
                      style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, j) => _FarmerOrderCard(
                    order: list[j],
                    onChangeStatus: _changeStatus,
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _FarmerOrderCard extends StatelessWidget {
  final FarmerOrder order;
  final Future<void> Function(FarmerOrder order, String backendStatus)
      onChangeStatus;
  const _FarmerOrderCard({required this.order, required this.onChangeStatus});

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
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
          Expanded(
            child: Text(
              order.consumerPhone.isNotEmpty
                  ? '${order.consumerName} · ${order.consumerPhone}'
                  : order.consumerName,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
        ]),
        const SizedBox(height: 6),
        Text('• ${order.productName} × ${_fmt(order.quantity)} ${order.unit}',
            style: const TextStyle(fontSize: 12)),
        const Divider(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text('Total: Rp ${_fmt(order.total)}',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.primary)),
          ),
          _ActionButtons(order: order, onChangeStatus: onChangeStatus),
        ]),
      ]),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final FarmerOrder order;
  final Future<void> Function(FarmerOrder order, String backendStatus)
      onChangeStatus;
  const _ActionButtons({required this.order, required this.onChangeStatus});

  @override
  Widget build(BuildContext context) {
    switch (order.status) {
      case OrderStatus.menunggu:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          OutlinedButton(
            onPressed: () => onChangeStatus(order, 'cancelled'),
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                minimumSize: const Size(56, 34),
                padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: const Text('Tolak', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => onChangeStatus(order, 'confirmed'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(80, 34),
                padding: const EdgeInsets.symmetric(horizontal: 12)),
            child: const Text('Konfirmasi', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ]);
      case OrderStatus.dikonfirmasi:
        return ElevatedButton(
          onPressed: () => onChangeStatus(order, 'harvesting'),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success, minimumSize: const Size(120, 34)),
          child: const Text('Tandai Dipanen', style: TextStyle(fontSize: 12, color: Colors.white)),
        );
      case OrderStatus.dipanen:
        return Row(mainAxisSize: MainAxisSize.min, children: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ContactCourierScreen(order: order)),
            ),
            style: TextButton.styleFrom(
                minimumSize: const Size(40, 34),
                padding: const EdgeInsets.symmetric(horizontal: 8)),
            child: const Text('Kurir', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 4),
          ElevatedButton(
            onPressed: () => onChangeStatus(order, 'shipped'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.info, minimumSize: const Size(100, 34)),
            child: const Text('Tandai Dikirim', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ]);
      case OrderStatus.dikirim:
        return ElevatedButton(
          onPressed: () => onChangeStatus(order, 'completed'),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, minimumSize: const Size(120, 34)),
          child: const Text('Tandai Selesai', style: TextStyle(fontSize: 12, color: Colors.white)),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ]),
      ),
    );
  }
}
