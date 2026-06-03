import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/user_service.dart';
import '../../../../core/services/order_service.dart';
import '../../../../core/services/product_service.dart';
import '../../../../data/models/farmer_order.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/mock/orders_mock.dart' show OrderStatus;
import '../../../../presentation/widgets/status_badge.dart';
import '../products/add_product_screen.dart';
import 'ai_price_check_screen.dart';
import 'market_forecast_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});
 
  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  List<FarmerOrder> _orders = [];
  List<ProductModel> _products = [];
  bool _loading = true;

  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut);
    _load();
  }

  @override
  void dispose() {
    _headerAnimCtrl.dispose();
    super.dispose();
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
      _orders  = results[1] as List<FarmerOrder>;
      _products = results[2] as List<ProductModel>;
      _loading  = false;
    });
    _headerAnimCtrl.forward();
  }

  // ── Derived metrics ───────────────────────────────────────────────────────
  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  double get _todayRevenue => _orders
      .where((o) => o.status == OrderStatus.selesai && _isToday(o.createdAt))
      .fold(0.0, (s, o) => s + o.total);

  int get _activeOrders => _orders
      .where((o) => o.status != OrderStatus.selesai && o.status != OrderStatus.dibatalkan)
      .length;

  int get _waitingOrders => _orders.where((o) => o.status == OrderStatus.menunggu).length;

  int get _lowStock => _products.where((p) => p.isAvailable && p.stock <= 10).length;

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
    const days   = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String get _greetingTime {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi ☀️';
    if (hour < 15) return 'Selamat Siang 🌤️';
    if (hour < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    final recent = _orders.take(3).toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Gradient Header ──────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: AppColors.primary,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Banner image
                    Image.asset(
                      'assets/images/farmer_banner.png',
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xDD00441b),
                            Color(0xAA005C25),
                            Color(0x44002D12),
                          ],
                        ),
                      ),
                    ),
                    // Content
                    SafeArea(
                      child: FadeTransition(
                        opacity: _headerFade,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _greetingTime,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.85),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Halo, $_greetingName! 👋',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _todayString,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(children: [
                                    _HeaderIconBtn(
                                      icon: Icons.notifications_none_rounded,
                                      badge: _waitingOrders > 0,
                                      badgeCount: _waitingOrders,
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 38,
                                      height: 38,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                                      ),
                                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                                    ),
                                  ]),
                                ],
                              ),
                              const Spacer(),
                              // Mini stats bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Row(
                                  children: [
                                    _MiniStat(label: 'Pesanan Aktif', value: _loading ? '-' : '$_activeOrders', icon: Icons.shopping_bag_outlined),
                                    _divider(),
                                    _MiniStat(label: 'Stok Rendah', value: _loading ? '-' : '$_lowStock', icon: Icons.inventory_2_outlined),
                                    _divider(),
                                    _MiniStat(
                                      label: 'Rating',
                                      value: _loading ? '-' : (_rating != null ? _rating!.toStringAsFixed(1) : '-'),
                                      icon: Icons.star_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Revenue Card ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _RevenueCard(revenue: _loading ? null : _todayRevenue),
                  ),

                  // ── Aksi Cepat ───────────────────────────────────────────
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Aksi Cepat', icon: Icons.bolt_rounded),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(child: _QuickAction(
                          icon: Icons.add_box_rounded,
                          label: 'Tambah Produk',
                          color: AppColors.primary,
                          bgColor: AppColors.primaryLight,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen())).then((_) => _load()),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _QuickAction(
                          icon: Icons.psychology_rounded,
                          label: 'Cek Harga AI',
                          color: AppColors.info,
                          bgColor: const Color(0xFFE3F2FD),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiPriceCheckScreen())),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: _QuickAction(
                          icon: Icons.analytics_rounded,
                          label: 'Prediksi Pasar',
                          color: AppColors.secondary,
                          bgColor: AppColors.secondaryLight,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketForecastScreen())),
                        )),
                      ],
                    ),
                  ),

                  // ── Insight Banner ───────────────────────────────────────
                  if (_lowStock > 0) ...[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _InsightBanner(
                        icon: Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        bgColor: const Color(0xFFFFF3E0),
                        message: '$_lowStock produk Anda hampir habis. Segera restok agar tidak melewatkan pesanan!',
                      ),
                    ),
                  ],

                  if (_waitingOrders > 0) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _InsightBanner(
                        icon: Icons.notifications_active_rounded,
                        color: AppColors.info,
                        bgColor: const Color(0xFFE3F2FD),
                        message: '$_waitingOrders pesanan menunggu konfirmasi Anda. Segera tindak lanjuti!',
                      ),
                    ),
                  ],

                  // ── Pesanan Terbaru ──────────────────────────────────────
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Pesanan Terbaru', icon: Icons.receipt_long_rounded, actionLabel: 'Lihat Semua'),
                  const SizedBox(height: 12),

                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    )
                  else if (recent.isEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: _EmptyState(
                        icon: Icons.receipt_long_outlined,
                        message: 'Belum ada pesanan masuk.\nAyo promosikan produkmu!',
                      ),
                    )
                  else
                    ...recent.map((o) => _OrderCard(order: o)),

                  const SizedBox(height: 100), // ruang untuk FAB
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1, height: 28,
    color: Colors.white.withOpacity(0.3),
    margin: const EdgeInsets.symmetric(horizontal: 12),
  );
}

// ── Sub Widgets ──────────────────────────────────────────────────────────────

class _HeaderIconBtn extends StatelessWidget {
  final IconData icon;
  final bool badge;
  final int badgeCount;
  const _HeaderIconBtn({required this.icon, this.badge = false, this.badgeCount = 0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        if (badge)
          Positioned(
            top: 4, right: 4,
            child: Container(
              width: 14, height: 14,
              decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
              child: Center(
                child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionLabel;
  const _SectionTitle({required this.title, required this.icon, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const Spacer(),
          if (actionLabel != null)
            Text(actionLabel!, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  final double? revenue;
  const _RevenueCard({this.revenue});

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF005C25), Color(0xFF00441b)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00441b).withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.payments_rounded, color: Colors.white70, size: 16),
                  const SizedBox(width: 6),
                  const Text('Pendapatan Hari Ini', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
                const SizedBox(height: 6),
                revenue == null
                    ? const SizedBox(height: 28, width: 100, child: LinearProgressIndicator(color: Colors.white30, backgroundColor: Colors.transparent))
                    : Text(
                        'Rp ${_fmt(revenue!)}',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text('🌱 Terus semangat bertani!', style: TextStyle(color: Colors.white, fontSize: 11)),
                ),
              ],
            ),
          ),
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.bgColor, required this.onTap});

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1, end: 0.93).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) { _ctrl.reverse(); widget.onTap(); },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: widget.color.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: widget.color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(widget.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: widget.color), maxLines: 2, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String message;
  const _InsightBanner({required this.icon, required this.color, required this.bgColor, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 36),
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
        ],
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
      ),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.shopping_bag_rounded, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(child: Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            StatusBadge(status: order.status, fontSize: 10),
          ]),
          const SizedBox(height: 3),
          Text(order.consumerName, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text('${order.productName} · Rp $totalFmt', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ]),
    );
  }
}
