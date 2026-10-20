import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models/farmer_order.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/mock/orders_mock.dart' show OrderStatus;
import '../../../../presentation/widgets/status_badge.dart';
import '../../../widgets/seller_ui.dart';
import '../../../providers/farmer_voice_provider.dart';
import '../../../widgets/voice_hub/audio_waveform_widget.dart';
import '../products/add_product_screen.dart';
import '../../chat/farmer_ai_chat_screen.dart';
import 'ai_price_check_screen.dart';
import 'market_forecast_screen.dart';

class FarmerHomeScreen extends ConsumerStatefulWidget {
  /// Pindah ke tab lain di FarmerNavigation (1 Produk, 2 Pesanan, 3 Pendapatan).
  final ValueChanged<int>? onOpenTab;

  const FarmerHomeScreen({super.key, this.onOpenTab});

  @override
  ConsumerState<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends ConsumerState<FarmerHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimCtrl;
  late Animation<double> _headerFade;

  // Bar ringkas yang muncul saat header menciut (header terbuka tetap seperti semula).
  final _scrollCtrl = ScrollController();
  final _collapsed = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _headerAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _headerFade = CurvedAnimation(parent: _headerAnimCtrl, curve: Curves.easeOut);
    _headerAnimCtrl.forward();
    _scrollCtrl.addListener(() {
      final c = _scrollCtrl.offset > 120; // expandedHeight 220 - toolbar ≈ 164
      if (c != _collapsed.value) _collapsed.value = c;
    });
  }

  @override
  void dispose() {
    _headerAnimCtrl.dispose();
    _scrollCtrl.dispose();
    _collapsed.dispose();
    super.dispose();
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

    final voiceState = ref.watch(farmerVoiceProvider);
    final products = voiceState.products;
    final orders = voiceState.orders;
    final isLoading = voiceState.isLoadingData;

    final todayRevenue = orders
        .where((o) => o.status == OrderStatus.selesai)
        .fold(0.0, (s, o) => s + o.total);

    final activeOrdersCount = orders
        .where((o) => o.status != OrderStatus.selesai && o.status != OrderStatus.dibatalkan)
        .length;

    final completedCount = orders.where((o) => o.status == OrderStatus.selesai).length;

    return Scaffold(
      backgroundColor: sellerCanvas,
      body: RefreshIndicator(
        onRefresh: () => ref.read(farmerVoiceProvider.notifier).loadDashboardData(),
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Sliver App Bar with Voice Assistant Hero Banner ────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 220,
              backgroundColor: AppColors.primary,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 16,
              title: ValueListenableBuilder<bool>(
                valueListenable: _collapsed,
                builder: (_, collapsed, __) => IgnorePointer(
                  ignoring: !collapsed,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: collapsed ? 1 : 0,
                    child: AnimatedSlide(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      offset: collapsed ? Offset.zero : const Offset(0, 0.4),
                      child: _CollapsedHeaderBar(
                        revenue: todayRevenue,
                        activeOrders: activeOrdersCount,
                        onTap: () => _scrollCtrl.animateTo(
                          0,
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/farmer_banner.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.primaryDark),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xDD00441b),
                            Color(0xAA005C25),
                            Color(0x77002D12),
                          ],
                        ),
                      ),
                    ),
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
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Voice AI Dashboard 🎙️',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.graphic_eq_rounded, color: Colors.greenAccent, size: 16),
                                        SizedBox(width: 4),
                                        Text(
                                          'Hands-Free',
                                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),

                              // Hero Voice Assistant Card Banner
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Semua Aksi via Perintah Suara',
                                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Misal: "Tolong saya ingin memasukan wortel 70 kg"',
                                            style: TextStyle(color: Colors.white70, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const AudioWaveformWidget(state: VoiceState.speaking, height: 24),
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
                  // ── Voice Confirmation / Notification Banner ─────────────────
                  if (voiceState.notificationMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: sellerCard(radius: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, color: AppColors.primary, size: 16),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                voiceState.notificationMessage!,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Live Voice Audio Response Box (TTS Mirror Output) ────────
                  if (voiceState.speechResponse.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.volume_up_rounded, color: Colors.amberAccent, size: 18),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'Respon Asisten Suara',
                                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                AudioWaveformWidget(state: voiceState.voiceState, height: 20, primaryColor: Colors.amberAccent),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              voiceState.speechResponse,
                              style: const TextStyle(color: Colors.white, fontSize: 13.5, height: 1.45, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Ringkasan Pendapatan ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _SummaryCard(
                      revenue: isLoading ? null : todayRevenue,
                      activeOrders: activeOrdersCount,
                      productCount: products.length,
                      completedCount: completedCount,
                      orders: orders,
                      onTap: () => widget.onOpenTab?.call(3),
                    ),
                  ),

                  // ── Fitur AI & Akses Cepat ───────────────────────────────────
                  const SizedBox(height: 28),
                  const SellerSectionTitle(title: 'Fitur AI & Akses Cepat', subtitle: 'Bantu tentukan harga & kelola stok'),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Iconsax.tag_2_copy,
                            label: 'Cek Harga AI',
                            color: const Color(0xFF1E6FD9),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AiPriceCheckScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Iconsax.status_up_copy,
                            label: 'Prediksi Pasar',
                            color: const Color(0xFFE08A00),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MarketForecastScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Iconsax.messages_2_copy,
                            label: 'AI Chat Bot',
                            color: AppColors.primaryMid,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FarmerAiChatScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Iconsax.box_add_copy,
                            label: 'Tambah Manual',
                            color: const Color(0xFF00897B),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddProductScreen()),
                            ).then((_) => ref.read(farmerVoiceProvider.notifier).loadDashboardData()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Pintasan Suara ───────────────────────────────────────────
                  const SizedBox(height: 28),
                  const SellerSectionTitle(title: 'Pintasan Suara', subtitle: 'Ketuk untuk menjalankan perintah'),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 42,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _VoiceShortcutChip(
                          icon: Iconsax.add_square,
                          label: 'Tambah Wortel 70kg',
                          onTap: () => ref
                              .read(farmerVoiceProvider.notifier)
                              .processSpeech("Tolong saya ingin memasukan wortel 70 kg ke produk saya."),
                        ),
                        _VoiceShortcutChip(
                          icon: Iconsax.add_square,
                          label: 'Tambah Cabai 35kg',
                          onTap: () => ref
                              .read(farmerVoiceProvider.notifier)
                              .processSpeech("Tolong tambahkan cabai merah 35 kg harga 38000"),
                        ),
                        _VoiceShortcutChip(
                          icon: Iconsax.chart_2,
                          label: 'Cek Penjualan Minggu Ini',
                          onTap: () => ref
                              .read(farmerVoiceProvider.notifier)
                              .processSpeech("Cek riwayat penjualan saya minggu ini"),
                        ),
                        _VoiceShortcutChip(
                          icon: Iconsax.danger,
                          label: 'Konsultasi Hama',
                          onTap: () => ref
                              .read(farmerVoiceProvider.notifier)
                              .processSpeech("Hama apa yang perlu diwaspadai musim ini?"),
                        ),
                      ],
                    ),
                  ),

                  // ── Stok Produk (mirror real-time) ───────────────────────────
                  const SizedBox(height: 28),
                  SellerSectionTitle(
                    title: 'Stok Produk (${products.length})',
                    subtitle: 'Ter-update otomatis via suara',
                    actionLabel: 'Kelola',
                    onAction: () => widget.onOpenTab?.call(1),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const SizedBox(
                      height: 206,
                      child: SellerSkeletonList(count: 1, itemHeight: 196, padding: EdgeInsets.symmetric(horizontal: 16)),
                    )
                  else if (products.isEmpty)
                    const Center(
                      child: SellerEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: 'Belum ada produk',
                        subtitle: 'Ucapkan perintah suara atau ketuk Tambah Manual untuk mulai berjualan.',
                      ),
                    )
                  else
                    SizedBox(
                      height: 206,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                        itemCount: products.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _ProductMirrorCard(product: products[i]),
                      ),
                    ),

                  // ── Pesanan Terbaru ──────────────────────────────────────────
                  const SizedBox(height: 18),
                  SellerSectionTitle(
                    title: 'Pesanan Terbaru',
                    actionLabel: 'Lihat Semua',
                    onAction: () => widget.onOpenTab?.call(2),
                  ),
                  const SizedBox(height: 12),
                  if (orders.isEmpty)
                    const Center(
                      child: SellerEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Belum ada pesanan',
                        subtitle: 'Pesanan dari pembeli akan muncul di sini.',
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: sellerCard(),
                        child: Column(
                          children: [
                            for (final (i, o) in orders.take(3).indexed) ...[
                              if (i > 0) const Divider(height: 1, indent: 70, endIndent: 16, color: Color(0xFFEFF2EE)),
                              _OrderRow(order: o, onTap: () => widget.onOpenTab?.call(2)),
                            ],
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 110), // Spacing for Floating Voice Hub
                ].animate(interval: 45.ms).fadeIn(duration: 380.ms).slideY(begin: 0.08, curve: Curves.easeOutCubic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceShortcutChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _VoiceShortcutChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFE3E8E1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Iconsax.microphone_2_copy, color: AppColors.primary, size: 15),
                ),
                const SizedBox(width: 8),
                Icon(icon, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double? revenue;
  final int activeOrders;
  final int productCount;
  final int completedCount;
  final List<FarmerOrder> orders;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.orders,
    this.revenue,
    required this.activeOrders,
    required this.productCount,
    required this.completedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0A6B32), AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 22, offset: const Offset(0, 10)),
          ],
        ),
        child: Stack(
          children: [
            // Ornamen lingkaran lembut
            Positioned(
              right: -40,
              top: -50,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            Positioned(
              right: 30,
              bottom: -70,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.04)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text('Pendapatan Selesai',
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                      const Text('Detail',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                  const SizedBox(height: 10),
                  revenue == null
                      ? const SizedBox(
                          height: 34,
                          width: 120,
                          child: Center(
                            child: LinearProgressIndicator(color: Colors.white38, backgroundColor: Colors.transparent),
                          ),
                        )
                      : CountUpRupiah(
                          value: revenue!,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.8),
                        ),
                  const SizedBox(height: 4),
                  _Sparkline(orders: orders),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Row(
                      children: [
                        _MiniStat(value: '$activeOrders', label: 'Pesanan Aktif'),
                        _divider(),
                        _MiniStat(value: '$completedCount', label: 'Selesai'),
                        _divider(),
                        _MiniStat(value: '$productCount', label: 'Produk'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 28, color: Colors.white.withValues(alpha: 0.15));
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  const _MiniStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
          const SizedBox(height: 1),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class _ProductMirrorCard extends StatelessWidget {
  final ProductModel product;

  const _ProductMirrorCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final lowStock = product.stock <= 10;
    return Container(
      width: 152,
      decoration: sellerCard(radius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(6),
                child: SellerProductImage(
                  url: product.imageUrls.isNotEmpty ? product.imageUrls.first : null,
                  name: product.name,
                  width: 140,
                  height: 96,
                  radius: 14,
                ),
              ),
              if (product.isAiPrice)
                Positioned(
                  left: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.bolt_rounded, size: 12, color: Color(0xFFE08A00)),
                      Text('Harga AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFFE08A00))),
                    ]),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                      text: rupiah(product.price),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    TextSpan(
                      text: ' /${product.unit}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    ),
                  ]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: lowStock ? AppColors.statusMenungguBg : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${lowStock ? 'Stok menipis · ' : 'Stok '}${product.stock.toStringAsFixed(0)} ${product.unit}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: lowStock ? AppColors.statusMenungguText : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  final FarmerOrder order;
  final VoidCallback onTap;
  const _OrderRow({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initial = order.consumerName.isNotEmpty ? order.consumerName[0].toUpperCase() : '?';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: AppColors.primaryLight,
            child: Text(initial, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                order.consumerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                '${order.productName} · ${order.quantity.toStringAsFixed(0)} ${order.unit}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              OrderProgressBar(status: order.status),
            ]),
          ),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(rupiah(order.total),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            StatusBadge(status: order.status, fontSize: 10),
          ]),
        ]),
      ),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

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
    _scale = Tween<double>(begin: 1, end: 0.94).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 98,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: sellerCard(radius: 18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.color.withValues(alpha: 0.20), widget.color.withValues(alpha: 0.07)],
                  ),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(widget.icon, color: widget.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                widget.label,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.2),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sparkline pendapatan selesai 7 hari terakhir di kartu ringkasan.
class _Sparkline extends StatelessWidget {
  final List<FarmerOrder> orders;
  const _Sparkline({required this.orders});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      final d = DateTime(today.year, today.month, today.day - (6 - i));
      return orders
          .where((o) =>
              o.status == OrderStatus.selesai &&
              o.createdAt.year == d.year &&
              o.createdAt.month == d.month &&
              o.createdAt.day == d.day)
          .fold(0.0, (s, o) => s + o.total);
    });
    final max = days.fold(0.0, (m, v) => v > m ? v : m);
    if (max <= 0) return const SizedBox(height: 8); // belum ada penjualan 7 hari: garis datar tidak bermakna
    return SizedBox(
      height: 38,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: max <= 0 ? 1 : max * 1.15,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (var i = 0; i < days.length; i++) FlSpot(i.toDouble(), days[i])],
              isCurved: true,
              preventCurveOverShooting: true,
              color: const Color(0xFFB8F5C8),
              barWidth: 2.2,
              dotData: FlDotData(
                show: true,
                checkToShowDot: (spot, _) => spot.x == days.length - 1,
                getDotPainter: (_, __, ___, ____) =>
                    FlDotCirclePainter(radius: 3.2, color: Colors.white, strokeWidth: 2, strokeColor: const Color(0xFFB8F5C8)),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Isi bar hijau yang tetap terlihat (pinned) saat Beranda discroll.
class _CollapsedHeaderBar extends StatelessWidget {
  final double revenue;
  final int activeOrders;
  final VoidCallback onTap;

  const _CollapsedHeaderBar({required this.revenue, required this.activeOrders, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Voice AI Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                ),
                const SizedBox(height: 1),
                Text(
                  '${rupiah(revenue)} · $activeOrders pesanan aktif',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.graphic_eq_rounded, color: Colors.greenAccent, size: 14),
              SizedBox(width: 4),
              Text('Hands-Free', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
            ]),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70, size: 22),
        ],
      ),
    );
  }
}
