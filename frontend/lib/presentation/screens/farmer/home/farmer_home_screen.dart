import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/models/farmer_order.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/mock/orders_mock.dart' show OrderStatus;
import '../../../../presentation/widgets/status_badge.dart';
import '../../../providers/farmer_voice_provider.dart';
import '../../../widgets/voice_hub/audio_waveform_widget.dart';
import '../products/add_product_screen.dart';
import '../../chat/farmer_ai_chat_screen.dart';
import 'ai_price_check_screen.dart';
import 'market_forecast_screen.dart';

class FarmerHomeScreen extends ConsumerStatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  ConsumerState<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends ConsumerState<FarmerHomeScreen>
    with TickerProviderStateMixin {
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
    _headerAnimCtrl.forward();
  }

  @override
  void dispose() {
    _headerAnimCtrl.dispose();
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(farmerVoiceProvider.notifier).loadDashboardData(),
        color: AppColors.primary,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Sliver App Bar with Voice Assistant Hero Banner ────────────────
            SliverAppBar(
              pinned: true,
              expandedHeight: 220,
              backgroundColor: AppColors.primary,
              elevation: 0,
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
                  if (voiceState.notificationMessage != null) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade400),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                voiceState.notificationMessage!,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Live Voice Audio Response Box (TTS Mirror Output) ────────
                  if (voiceState.speechResponse.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00441b), Color(0xFF005C25)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.volume_up_rounded, color: Colors.amberAccent, size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'Respon Suara AI (TTS Audio)',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                AudioWaveformWidget(state: voiceState.voiceState, height: 20, primaryColor: Colors.amberAccent),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              voiceState.speechResponse,
                              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Quick Voice Command Shortcuts Bar ──────────────────────
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Pintasan Suara Cepat', icon: Icons.record_voice_over_rounded),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _VoiceShortcutChip(
                          label: '➕ Tambah Wortel 70kg',
                          onTap: () => ref
                              .read(farmerVoiceProvider.notifier)
                              .processSpeech("Tolong saya ingin memasukan wortel 70 kg ke produk saya."),
                        ),
                        _VoiceShortcutChip(
                          label: '➕ Tambah Cabai 35kg',
                          onTap: () => ref
                              .read(farmerVoiceProvider.notifier)
                              .processSpeech("Tolong tambahkan cabai merah 35 kg harga 38000"),
                        ),
                        _VoiceShortcutChip(
                          label: '📊 Cek Penjualan Minggu Ini',
                          onTap: () => ref
                              .read(farmerVoiceProvider.notifier)
                              .processSpeech("Cek riwayat penjualan saya minggu ini"),
                        ),
                        _VoiceShortcutChip(
                          label: '🐛 Konsultasi Hama',
                          onTap: () => ref
                              .read(farmerVoiceProvider.notifier)
                              .processSpeech("Hama apa yang perlu diwaspadai musim ini?"),
                        ),
                      ],
                    ),
                  ),

                  // ── Fitur AI & Akses Cepat ───────────────────────────────────────
                  const SizedBox(height: 20),
                  _SectionTitle(title: 'Fitur AI & Akses Cepat', icon: Icons.psychology_rounded),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.psychology_rounded,
                            label: 'Cek Harga AI',
                            color: AppColors.info,
                            bgColor: const Color(0xFFE3F2FD),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AiPriceCheckScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.analytics_rounded,
                            label: 'Prediksi Pasar',
                            color: AppColors.secondary,
                            bgColor: AppColors.secondaryLight,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MarketForecastScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.smart_toy_rounded,
                            label: 'AI Chat Bot',
                            color: AppColors.primary,
                            bgColor: AppColors.primaryLight,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const FarmerAiChatScreen()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickAction(
                            icon: Icons.add_box_rounded,
                            label: 'Tambah Manual',
                            color: Colors.teal,
                            bgColor: const Color(0xFFE0F2F1),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddProductScreen()),
                            ).then((_) => ref.read(farmerVoiceProvider.notifier).loadDashboardData()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Overview Metrics Card ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: _RevenueCard(revenue: isLoading ? null : todayRevenue, activeOrders: activeOrdersCount),
                  ),

                  // ── Real-Time Visual Mirror: Products (Voice Management) ──
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: 'Mirror Stok Produk (${products.length})',
                    icon: Icons.inventory_2_rounded,
                    subtitle: 'Ter-update otomatis via Suara',
                  ),
                  const SizedBox(height: 12),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  else if (products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Belum ada produk. Katakan perintah suara untuk menambah!', textAlign: TextAlign.center),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemBuilder: (context, idx) {
                        final p = products[idx];
                        return _ProductMirrorCard(product: p);
                      },
                    ),

                  // ── Real-Time Visual Mirror: Orders History ──────────────
                  const SizedBox(height: 24),
                  _SectionTitle(
                    title: 'Histori Transaksi & Pesanan',
                    icon: Icons.receipt_long_rounded,
                    actionLabel: 'Lihat Semua',
                  ),
                  const SizedBox(height: 12),

                  if (orders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      child: Text('Belum ada riwayat pesanan.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    ...orders.take(3).map((o) => _OrderCard(order: o)),

                  const SizedBox(height: 110), // Spacing for central Floating Voice Hub
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceShortcutChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _VoiceShortcutChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        backgroundColor: AppColors.primaryLight,
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
        onPressed: onTap,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final String? actionLabel;

  const _SectionTitle({required this.title, required this.icon, this.subtitle, this.actionLabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              if (subtitle != null)
                Text(subtitle!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
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
  final int activeOrders;

  const _RevenueCard({this.revenue, required this.activeOrders});

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
                Row(children: const [
                  Icon(Icons.payments_rounded, color: Colors.white70, size: 16),
                  SizedBox(width: 6),
                  Text('Pendapatan Selesai', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ]),
                const SizedBox(height: 6),
                revenue == null
                    ? const SizedBox(height: 28, width: 100, child: LinearProgressIndicator(color: Colors.white30, backgroundColor: Colors.transparent))
                    : Text(
                        'Rp ${_fmt(revenue!)}',
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                      ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text('📦 $activeOrders Pesanan Aktif Berjalan', style: const TextStyle(color: Colors.white, fontSize: 11)),
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

class _ProductMirrorCard extends StatelessWidget {
  final ProductModel product;

  const _ProductMirrorCard({required this.product});

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: AppColors.border.withOpacity(0.7)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              product.imageUrls.isNotEmpty ? product.imageUrls.first : 'assets/images/product_sayur.jpg',
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 56,
                color: AppColors.primaryLight,
                child: const Icon(Icons.eco_rounded, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp ${_fmt(product.price)} / ${product.unit}',
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6)),
                      child: Text('Stok: ${product.stock} ${product.unit}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                    const SizedBox(width: 8),
                    if (product.isAiPrice)
                      const Text('⚡ Harga Suara AI', style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final FarmerOrder order;
  const _OrderCard({required this.order});

  String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
          Text('${order.productName} · Rp ${_fmt(order.total)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ])),
        const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      ]),
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
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
    _scale = Tween<double>(begin: 1, end: 0.93).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
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
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.color.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(color: widget.color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 3)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: widget.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(widget.icon, color: widget.color, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: widget.color),
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
