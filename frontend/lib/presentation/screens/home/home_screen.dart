import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/supabase_config.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../data/cart_state.dart';
import '../../../data/models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<ProductModel>> _productsFuture;
  Map<String, dynamic>? _profile;

  final _bannerCtrl = PageController(viewportFraction: 0.93);
  int _bannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService.getAllProducts(limit: 20);
    _loadProfile();
  }

  @override
  void dispose() {
    _bannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (SupabaseConfig.url.isEmpty || !AuthService.isLoggedIn) return;
    try {
      final data = await db
          .from('profiles')
          .select('name, city, province, avatar_url')
          .eq('id', AuthService.currentUser!.id)
          .single();
      if (mounted) setState(() => _profile = data);
    } catch (_) {
      // Biarkan fallback greeting tanpa nama.
    }
  }

  Future<void> _refresh() async {
    final f = ProductService.getAllProducts(limit: 20);
    setState(() => _productsFuture = f);
    try {
      await f;
    } catch (_) {}
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi';
    if (h < 15) return 'Selamat siang';
    if (h < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  String get _firstName {
    final name = (_profile?['name'] as String?)?.trim() ?? '';
    if (name.isEmpty) return '';
    return name.split(' ').first;
  }

  static String _rp(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  void _addToCart(ProductModel p) {
    addToCart(p);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.name} ditambahkan ke keranjang'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chat'),
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.smart_toy_rounded, color: Colors.white),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snap) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildCategories(context)),
                SliverToBoxAdapter(child: _buildBanner()),
                ..._buildProductSlivers(context, snap),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Header hijau: greeting + lokasi + search ──────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final name = _firstName;
    final city = (_profile?['city'] as String?) ?? 'Jakarta';
    final province = (_profile?['province'] as String?) ?? 'DKI Jakarta';
    final avatarUrl = (_profile?['avatar_url'] as String?) ?? '';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isEmpty ? '$_greeting 👋' : '$_greeting, $name 👋',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '$city, $province',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _HeaderIconButton(
                    icon: Icons.notifications_outlined,
                    showDot: true,
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? CachedNetworkImageProvider(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? Text(
                            name.isEmpty ? '🙂' : name[0].toUpperCase(),
                            style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/explore'),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded,
                          color: AppColors.textSecondary, size: 22),
                      SizedBox(width: 10),
                      Text('Cari produk segar...',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Kategori pill ─────────────────────────────────────────────────────────

  Widget _buildCategories(BuildContext context) {
    // (emoji, label, id kategori di DB — dipakai filter di halaman Jelajahi)
    final cats = [
      ('🥬', 'Sayuran', 'vegetable'),
      ('🍎', 'Buah', 'fruit'),
      ('🌾', 'Biji-bijian', 'grain'),
      ('🌶️', 'Rempah', 'spice'),
      ('🥚', 'Susu & Telur', 'dairy'),
    ];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/explore',
                arguments: cats[i].$3),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Text(cats[i].$1, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text(cats[i].$2,
                      style: const TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Banner promo carousel ─────────────────────────────────────────────────

  Widget _buildBanner() {
    final banners = [
      (
        const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        '🥬',
        'Segar Langsung\ndari Petani',
        'Tanpa perantara, harga adil untuk semua',
      ),
      (
        const LinearGradient(colors: [Color(0xFFF5A623), Color(0xFFE08600)]),
        '🚚',
        'Cold Chain\nSampai Rumah',
        'Suhu terjaga, kesegaran terjamin',
      ),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        children: [
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: _bannerCtrl,
              itemCount: banners.length,
              onPageChanged: (i) => setState(() => _bannerIndex = i),
              itemBuilder: (_, i) {
                final b = banners[i];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: b.$1,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(b.$3,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    height: 1.25,
                                    fontWeight: FontWeight.w800)),
                            const SizedBox(height: 6),
                            Text(b.$4,
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 11.5)),
                          ],
                        ),
                      ),
                      Text(b.$2, style: const TextStyle(fontSize: 52)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _bannerIndex ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _bannerIndex
                      ? AppColors.primary
                      : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Produk (loading / error / data) ───────────────────────────────────────

  List<Widget> _buildProductSlivers(
      BuildContext context, AsyncSnapshot<List<ProductModel>> snap) {
    if (snap.connectionState == ConnectionState.waiting) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
                child: CircularProgressIndicator(color: AppColors.primary)),
          ),
        ),
      ];
    }
    if (snap.hasError) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
            child: Column(
              children: [
                const Icon(Icons.wifi_off_rounded,
                    size: 42, color: AppColors.textSecondary),
                const SizedBox(height: 12),
                const Text('Gagal memuat produk',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text('${snap.error}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _refresh,
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(140, 42)),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      ];
    }

    final products = snap.data ?? [];
    if (products.isEmpty) {
      return const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(
              child: Text('Belum ada produk tersedia',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
          ),
        ),
      ];
    }

    final fresh = products.take(6).toList();
    return [
      SliverToBoxAdapter(
        child: _sectionHeader('Panen Segar Hari Ini',
            onSeeAll: () => Navigator.pushNamed(context, '/explore')),
      ),
      SliverToBoxAdapter(
        child: SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: fresh.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 150,
              child: _ProductCard(
                product: fresh[i],
                onTap: () => Navigator.pushNamed(context, '/product-detail',
                    arguments: fresh[i]),
                onAdd: () => _addToCart(fresh[i]),
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(child: _sectionHeader('Untuk Kamu')),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, i) => _ProductCard(
              product: products[i],
              onTap: () => Navigator.pushNamed(context, '/product-detail',
                  arguments: products[i]),
              onAdd: () => _addToCart(products[i]),
            ),
            childCount: products.length,
          ),
        ),
      ),
      SliverToBoxAdapter(child: _buildSubscriptionCta()),
      const SliverToBoxAdapter(child: SizedBox(height: 20)),
    ];
  }

  Widget _sectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800)),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('Lihat Semua',
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCta() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        const Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Langganan Sayur Mingguan',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14)),
            SizedBox(height: 4),
            Text('Hemat hingga 20% dengan berlangganan',
                style: TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            minimumSize: const Size(80, 36),
            padding: const EdgeInsets.symmetric(horizontal: 14),
          ),
          child: const Text('Mulai',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ── Widgets kecil ─────────────────────────────────────────────────────────────

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final bool showDot;
  final VoidCallback onTap;
  const _HeaderIconButton(
      {required this.icon, this.showDot = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(clipBehavior: Clip.none, children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
        if (showDot)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                  color: AppColors.secondary, shape: BoxShape.circle),
            ),
          ),
      ]),
    );
  }
}

/// Kartu produk (dipakai list horizontal & grid) — data real dari backend.
class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const _ProductCard(
      {required this.product, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final p = product;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Gambar + badge status
          Expanded(
            child: Stack(children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(15)),
                  child: p.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: p.imageUrls.first,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.primaryLight),
                          errorWidget: (_, __, ___) => const _ImgFallback(),
                        )
                      : const _ImgFallback(),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: p.isPreOrder
                        ? AppColors.preOrderPurple
                        : p.isAvailable
                            ? AppColors.success
                            : AppColors.danger,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p.isPreOrder
                        ? 'Pre-Order'
                        : p.isAvailable
                            ? 'Tersedia'
                            : 'Habis',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ]),
          ),
          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.secondary, size: 12),
                  const SizedBox(width: 2),
                  Text('${p.rating} (${p.reviewCount})',
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.textSecondary)),
                ]),
                const SizedBox(height: 3),
                Text(p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Row(children: [
                  Expanded(
                    child: Text(
                      'Rp ${_HomeScreenState._rp(p.price)}/${p.unit}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary),
                    ),
                  ),
                  GestureDetector(
                    onTap: p.isAvailable ? onAdd : null,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: p.isAvailable
                            ? AppColors.primary
                            : AppColors.border,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.add_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _ImgFallback extends StatelessWidget {
  const _ImgFallback();
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryLight,
      child: const Center(
          child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 36)),
    );
  }
}
