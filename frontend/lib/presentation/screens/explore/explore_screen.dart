import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/product_service.dart';
import '../../../../data/models/product_model.dart';
import '../../../../data/cart_state.dart';

/// Halaman Jelajahi — didesain untuk pengguna 35+ (teks besar, target sentuh
/// lebar, tombol berlabel, kontras tinggi, satu kolom).
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _selectedCategory; // null = Semua
  late Future<List<ProductModel>> _productsFuture;
  Timer? _debounce;
  bool _argsHandled = false;

  static const _categories = [
    (null, '🧺', 'Semua'),
    ('vegetable', '🥬', 'Sayuran'),
    ('fruit', '🍎', 'Buah'),
    ('grain', '🌾', 'Biji-bijian'),
    ('spice', '🌶️', 'Rempah'),
    ('dairy', '🥚', 'Susu & Telur'),
    ('other', '🛒', 'Lainnya'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kategori awal bisa dikirim dari Beranda: pushNamed('/explore', arguments: 'fruit')
    if (!_argsHandled) {
      _argsHandled = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String && args.isNotEmpty) {
        _selectedCategory = args;
        _load();
      }
    }
  }

  void _load() {
    setState(() {
      _productsFuture = ProductService.getAllProducts(
        search: _query.isEmpty ? null : _query,
        category: _selectedCategory,
      );
    });
  }

  void _onSearchChanged(String val) {
    _query = val;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _load);
    setState(() {}); // update tombol clear
  }

  void _selectCategory(String? id) {
    if (_selectedCategory == id) return;
    _selectedCategory = id;
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  int get _cartCount =>
      globalCart.fold(0, (sum, item) => sum + item.quantity);

  void _addToCart(ProductModel p) {
    addToCart(p);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${p.name} masuk keranjang',
            style: const TextStyle(fontSize: 14)),
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
      appBar: AppBar(
        title: const Text('Jelajahi Produk'),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: cartNotifier,
            builder: (_, __, ___) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    iconSize: 26,
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.white),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (_cartCount > 0)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$_cartCount',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }
                if (snap.hasError) {
                  return _buildErrorState('${snap.error}');
                }
                final results = snap.data ?? [];
                if (results.isEmpty) return _buildEmptyState();
                return _buildResults(results);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Search besar (56px, font 16, tanpa autofocus) ─────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: SizedBox(
        height: 56,
        child: TextField(
          controller: _searchCtrl,
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Cari sayur, buah, beras...',
            hintStyle:
                const TextStyle(color: AppColors.textSecondary, fontSize: 16),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppColors.textSecondary, size: 26),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    iconSize: 24,
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textSecondary),
                    onPressed: () {
                      _searchCtrl.clear();
                      _query = '';
                      _load();
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF7F8FA),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          onChanged: _onSearchChanged,
        ),
      ),
    );
  }

  // ── Chip kategori besar, filter beneran via backend ───────────────────────

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 58,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final (id, emoji, label) = _categories[i];
          final selected = _selectedCategory == id;
          return GestureDetector(
            onTap: () => _selectCategory(id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 0 : 1.2,
                ),
              ),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 17)),
                  const SizedBox(width: 7),
                  Text(label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: selected ? Colors.white : AppColors.textPrimary,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Hasil: satu kolom, kartu besar ────────────────────────────────────────

  Widget _buildResults(List<ProductModel> products) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _load(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: products.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          if (i == 0) {
            return Text(
              '${products.length} produk ditemukan',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary),
            );
          }
          final p = products[i - 1];
          return _ProductRow(
            product: p,
            onTap: () => Navigator.pushNamed(context, '/product-detail',
                arguments: p),
            onAdd: () => _addToCart(p),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                  color: AppColors.primaryLight, shape: BoxShape.circle),
              child: const Center(
                  child: Text('🔍', style: TextStyle(fontSize: 46))),
            ),
            const SizedBox(height: 22),
            const Text('Produk tidak ditemukan',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Coba kata kunci lain atau pilih kategori berbeda',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 15, color: AppColors.textSecondary)),
            if (_query.isNotEmpty || _selectedCategory != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    _searchCtrl.clear();
                    _query = '';
                    _selectedCategory = null;
                    _load();
                  },
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(200, 48)),
                  child: const Text('Tampilkan Semua Produk',
                      style: TextStyle(fontSize: 15)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 52, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('Gagal memuat produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _load,
                style:
                    ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
                child:
                    const Text('Coba Lagi', style: TextStyle(fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu produk besar: foto 92px, teks besar, tombol "+ Tambah" berlabel.
class _ProductRow extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback onAdd;
  const _ProductRow(
      {required this.product, required this.onTap, required this.onAdd});

  String _rp(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    final p = product;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: p.imageUrls.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: p.imageUrls.first,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: AppColors.primaryLight),
                          errorWidget: (_, __, ___) => const _ImgFallback(),
                        )
                      : const _ImgFallback(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Row(children: [
                      const Icon(Icons.person_outline_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          p.farmerName.isNotEmpty ? p.farmerName : 'Petani',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded,
                          color: AppColors.secondary, size: 14),
                      const SizedBox(width: 2),
                      Text('${p.rating}',
                          style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
                    ]),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Rp ${_rp(p.price)}/${p.unit}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary),
                          ),
                        ),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton.icon(
                            onPressed: p.isAvailable ? onAdd : null,
                            icon: const Icon(Icons.add_rounded, size: 20),
                            label: Text(p.isAvailable ? 'Tambah' : 'Habis',
                                style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.border,
                              disabledForegroundColor:
                                  AppColors.textSecondary,
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
          child: Icon(Icons.eco_rounded, color: AppColors.primary, size: 34)),
    );
  }
}
