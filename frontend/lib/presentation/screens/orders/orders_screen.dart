import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/services/order_service.dart';
import '../../../data/models/consumer_order.dart';
import '../../../data/mock/orders_mock.dart' show OrderStatus;
import '../../widgets/status_badge.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<ConsumerOrder>> _future;

  static const _aktif = [
    OrderStatus.menunggu,
    OrderStatus.dikonfirmasi,
    OrderStatus.dipanen,
    OrderStatus.dikirim,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _future = _load();
  }

  Future<List<ConsumerOrder>> _load() async {
    final raw = await OrderService.getMyOrders();
    final list = ConsumerOrder.listFromJson(raw);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  void _reload() => setState(() {
        _future = _load();
      });

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Selesai'),
            Tab(text: 'Dibatalkan'),
          ],
        ),
      ),
      body: FutureBuilder<List<ConsumerOrder>>(
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
            controller: _tabController,
            children: [
              _buildOrderList(all, _aktif),
              _buildOrderList(all, const [OrderStatus.selesai]),
              _buildOrderList(all, const [OrderStatus.dibatalkan]),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<ConsumerOrder> all, List<OrderStatus> statuses) {
    final list = all.where((o) => statuses.contains(o.status)).toList();
    return RefreshIndicator(
      onRefresh: () async => _reload(),
      child: list.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Text('Tidak ada pesanan',
                      style: TextStyle(color: AppColors.textSecondary)),
                ),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) => _OrderCard(
                order: list[index],
                onTrack: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderTrackingScreen(order: list[index]),
                  ),
                ),
              ),
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final ConsumerOrder order;
  final VoidCallback onTrack;
  const _OrderCard({required this.order, required this.onTrack});

  String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  String _qty(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    return v.toString();
  }

  bool get _canTrack =>
      order.status != OrderStatus.dibatalkan &&
      order.status != OrderStatus.menunggu;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Store & Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.storefront_outlined,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(order.farmerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: AppColors.textPrimary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(status: order.status),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          // Item
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: order.productImageUrl.isNotEmpty
                      ? Image.network(
                          order.productImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const _ImgFallback(),
                        )
                      : const _ImgFallback(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${_qty(order.quantity)} ${order.unit}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                    const SizedBox(height: 2),
                    Text('#${order.id}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.border),
          // Footer: Total & Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Pesanan',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 2),
                  Text('Rp ${_fmt(order.total)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              if (_canTrack)
                ElevatedButton(
                  onPressed: onTrack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Lacak',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImgFallback extends StatelessWidget {
  const _ImgFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: const Icon(Icons.inventory_2_outlined, color: AppColors.primary),
    );
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
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
        ]),
      ),
    );
  }
}
