import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/order_service.dart';
import '../../../../data/models/farmer_order.dart';
import '../../../../data/mock/orders_mock.dart' show OrderStatus;
import '../../../../presentation/widgets/status_badge.dart';
import '../../../widgets/seller_ui.dart';
import 'contact_courier_screen.dart';

const _monthsShort = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

class FarmerOrdersScreen extends StatefulWidget {
  const FarmerOrdersScreen({super.key});
  @override
  State<FarmerOrdersScreen> createState() => _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState extends State<FarmerOrdersScreen> {
  final _tabs = ['Semua', 'Menunggu', 'Dikonfirmasi', 'Dipanen', 'Dikirim', 'Selesai'];
  int _tab = 0;

  late Future<List<FarmerOrder>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<FarmerOrder>> _load() async {
    final raw = await OrderService.getFarmerOrders();
    return FarmerOrder.listFromJson(raw);
  }

  void _reload() => setState(() {
        _future = _load();
      });

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
      backgroundColor: sellerCanvas,
      body: FutureBuilder<List<FarmerOrder>>(
        future: _future,
        builder: (context, snap) {
          final loading = snap.connectionState == ConnectionState.waiting;
          final all = snap.data ?? [];
          final needAction = all.where((o) => o.status == OrderStatus.menunggu).length;
          final list = _ordersForTab(all, _tab);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SellerPageHeader(
                title: 'Pesanan',
                subtitle: loading
                    ? 'Memuat pesanan…'
                    : needAction > 0
                        ? '$needAction pesanan menunggu konfirmasi Anda'
                        : 'Semua pesanan sudah ditangani',
                trailing: IconButton(
                  onPressed: _reload,
                  tooltip: 'Muat ulang',
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _tabs.length,
                  itemBuilder: (_, i) => SellerFilterPill(
                    label: _tabs[i],
                    count: loading ? null : _ordersForTab(all, i).length,
                    selected: _tab == i,
                    onTap: () => setState(() => _tab = i),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Builder(builder: (_) {
                  if (loading) {
                    return const SellerSkeletonList(itemHeight: 190, count: 3);
                  }
                  if (snap.hasError) {
                    return SellerErrorState(message: '${snap.error}', onRetry: _reload);
                  }
                  if (list.isEmpty) {
                    return Center(
                      child: SellerEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Tidak ada pesanan',
                        subtitle: _tab == 0
                            ? 'Pesanan dari pembeli akan muncul di sini.'
                            : 'Belum ada pesanan berstatus "${_tabs[_tab]}".',
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => _reload(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, j) => _FarmerOrderCard(
                        key: ValueKey(list[j].id),
                        order: list[j],
                        onChangeStatus: _changeStatus,
                      )
                          .animate(delay: (50 * j.clamp(0, 6)).ms)
                          .fadeIn(duration: 320.ms)
                          .slideY(begin: 0.08, curve: Curves.easeOutCubic),
                    ),
                  );
                }),
              ),
            ],
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
  const _FarmerOrderCard({super.key, required this.order, required this.onChangeStatus});

  String get _shortId {
    final id = order.id;
    return (id.length > 8 ? id.substring(0, 8) : id).toUpperCase();
  }

  String get _date {
    final d = order.createdAt;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_monthsShort[d.month - 1]} · $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final initial = order.consumerName.isNotEmpty ? order.consumerName[0].toUpperCase() : '?';
    final hasActions = order.status != OrderStatus.selesai && order.status != OrderStatus.dibatalkan;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: sellerCard(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Pembeli + status
        Row(children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: AppColors.primaryLight,
            child: Text(initial, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.consumerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
              const SizedBox(height: 1),
              Text('#$_shortId · $_date',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
            ]),
          ),
          StatusBadge(status: order.status),
        ]),
        const SizedBox(height: 12),
        OrderProgressBar(status: order.status),
        const SizedBox(height: 12),

        // Ringkasan produk
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: sellerCanvas, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            SellerProductImage(
              url: order.productImageUrl.isNotEmpty ? order.productImageUrl : null,
              name: order.productName,
              width: 46,
              height: 46,
              radius: 11,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(order.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text('${order.quantity.toStringAsFixed(0)} ${order.unit} × ${rupiah(order.pricePerUnit)}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text('Total', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              Text(rupiah(order.total),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary)),
            ]),
          ]),
        ),

        if (order.consumerPhone.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Iconsax.call, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(order.consumerPhone, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ]),
        ],

        if (hasActions) ...[
          const SizedBox(height: 12),
          _ActionButtons(order: order, onChangeStatus: onChangeStatus),
        ],
      ]),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final FarmerOrder order;
  final Future<void> Function(FarmerOrder order, String backendStatus)
      onChangeStatus;
  const _ActionButtons({required this.order, required this.onChangeStatus});

  static final _shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));

  Widget _primary(String label, IconData icon, VoidCallback onPressed, {Color color = AppColors.primary}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17, color: Colors.white),
      label: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(0, 42),
        shape: _shape,
        elevation: 0,
      ),
    );
  }

  Widget _secondary(String label, IconData icon, VoidCallback onPressed, {Color color = AppColors.textPrimary}) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17, color: color),
      label: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.35)),
        minimumSize: const Size(0, 42),
        shape: _shape,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (order.status) {
      case OrderStatus.menunggu:
        return Row(children: [
          Expanded(
            child: _secondary('Tolak', Iconsax.close_circle, () => onChangeStatus(order, 'cancelled'),
                color: AppColors.danger),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _primary('Konfirmasi', Iconsax.tick_circle, () => onChangeStatus(order, 'confirmed')),
          ),
        ]);
      case OrderStatus.dikonfirmasi:
        return SizedBox(
          width: double.infinity,
          child: _primary('Tandai Dipanen', Icons.agriculture_rounded, () => onChangeStatus(order, 'harvesting')),
        );
      case OrderStatus.dipanen:
        return Row(children: [
          Expanded(
            child: _secondary(
              'Kurir',
              Iconsax.truck_fast,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ContactCourierScreen(order: order)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _primary('Tandai Dikirim', Iconsax.send_2, () => onChangeStatus(order, 'shipped'),
                color: AppColors.info),
          ),
        ]);
      case OrderStatus.dikirim:
        return SizedBox(
          width: double.infinity,
          child: _primary('Tandai Selesai', Iconsax.task_square, () => onChangeStatus(order, 'completed')),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
