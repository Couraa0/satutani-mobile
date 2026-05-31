import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/product_service.dart';
import '../../../../data/models/farmer_order.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/mock/orders_mock.dart' show OrderStatus;
import '../../../../presentation/widgets/kpi_card.dart';
import '../../../../presentation/widgets/section_header.dart';
import '../../../../presentation/widgets/status_badge.dart';
import '../products/add_product_screen.dart';
import 'ai_price_check_screen.dart';
import 'market_forecast_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  Map<String, dynamic>? _profile;
  List<FarmerOrder> _orders = [];
  List<ProductModel> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      UserService.getMyProfile(),
      OrderService.getFarmerOrders().then(FarmerOrder.listFromJson).catchError((_) => <FarmerOrder>[]),
      ProductService.getFarmerProducts().catchError((_) => <ProductModel>[]),
    ]);
    if (!mounted) return;
    setState(() {
      _profile = results[0] as Map<String, dynamic>?;
      _orders = results[1] as List<FarmerOrder>;
      _products = results[2] as List<ProductModel>;
      _loading = false;
    });
  }

  // ── Derived metrics ────────────────────────────────────────────────────────
  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  double get _todayRevenue => _orders
      .where((o) => o.status == OrderStatus.selesai && _isToday(o.createdAt))
      .fold(0.0, (s, o) => s + o.total);

  int get _activeOrders => _orders
      .where((o) =>
          o.status != OrderStatus.selesai && o.status != OrderStatus.dibatalkan)
      .length;

  int get _waitingOrders =>
      _orders.where((o) => o.status == OrderStatus.menunggu).length;

  int get _lowStock =>
      _products.where((p) => p.isAvailable && p.stock <= 10).length;

  double? get _rating {
    final fp = _profile?['farmer_profiles'];
    final map = fp is List ? (fp.isNotEmpty ? fp.first : null) : fp;
    if (map is Map && map['rating'] != null) {
      final r = map['rating'];
      return r is num ? r.toDouble() : double.tryParse(r.toString());
    }
    return null;
  }

  static String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  String get _greetingName {
    final name = (_profile?['name'] as String?)?.trim();
    if (name != null && name.isNotEmpty) return name;
    final email = AuthService.currentUser?.email;
    if (email != null && email.isNotEmpty) return email.split('@').first;
    return 'Petani';
  }

  String get _todayString {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final recent = _orders.take(3).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Halo, $_greetingName! 👋', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(_todayString, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
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
                        KpiCard(
                          icon: Icons.payments_outlined,
                          label: 'Pendapatan Hari Ini',
                          value: _loading ? '...' : 'Rp ${_fmt(_todayRevenue)}',
                        ),
                        const SizedBox(width: 12),
                        KpiCard(
                          icon: Icons.receipt_long_rounded,
                          label: 'Pesanan Aktif',
                          value: _loading ? '...' : '$_activeOrders',
                          iconColor: AppColors.info,
                          trend: _waitingOrders > 0 ? '$_waitingOrders menunggu konfirmasi' : null,
                        ),
                        const SizedBox(width: 12),
                        KpiCard(
                          icon: Icons.inventory_2_outlined,
                          label: 'Stok Hampir Habis',
                          value: _loading ? '...' : '$_lowStock produk',
                          iconColor: AppColors.warning,
                          trend: _lowStock > 0 ? 'Segera restok!' : null,
                          trendPositive: false,
                        ),
                        const SizedBox(width: 12),
                        KpiCard(
                          icon: Icons.star_rounded,
                          label: 'Rating',
                          value: _loading
                              ? '...'
                              : (_rating != null ? '${_rating!.toStringAsFixed(1)} ⭐' : '-'),
                          iconColor: AppColors.secondary,
                        ),
                      ]),
                    ),
                  ),
                  // Quick actions
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Aksi Cepat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    childAspectRatio: 0.95, mainAxisSpacing: 10, crossAxisSpacing: 10,
                    children: [
                      _QuickAction(icon: Icons.add_box_outlined, label: AppStrings.addProduct, color: AppColors.primary, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())).then((_) => _load());
                      }),
                      _QuickAction(icon: Icons.psychology_outlined, label: AppStrings.aiPricing, color: AppColors.info, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const AiPriceCheckScreen()));
                      }),
                      _QuickAction(icon: Icons.analytics_outlined, label: AppStrings.marketForecast, color: AppColors.secondary, onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketForecastScreen()));
                      }),
                    ],
                  ),
                  // Recent orders
                  const SizedBox(height: 24),
                  SectionHeader(title: 'Pesanan Terbaru', actionLabel: AppStrings.viewAll, onAction: () {}),
                  const SizedBox(height: 12),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (recent.isEmpty)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text('Belum ada pesanan masuk', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ...recent.map((o) => _OrderCard(order: o)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color), maxLines: 2, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final FarmerOrder order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final totalFmt = _FarmerHomeScreenState._fmt(order.total);
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
            Flexible(child: Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            StatusBadge(status: order.status, fontSize: 10),
          ]),
          const SizedBox(height: 4),
          Text(order.consumerName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('${order.productName} · Rp $totalFmt',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ]),
    );
  }
}
