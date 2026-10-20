import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/product_service.dart';
import '../../../../data/models/product_model.dart';
import '../../../widgets/seller_ui.dart';
import 'add_product_screen.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});
  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  static const _filters = ['Semua', 'Aktif', 'Habis', 'Pre-Order'];
  String _filter = 'Semua';
  late Future<List<ProductModel>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = ProductService.getFarmerProducts();
    });
  }

  bool _matches(ProductModel p, String filter) {
    if (filter == 'Aktif') return p.isAvailable;
    if (filter == 'Habis') return !p.isAvailable;
    if (filter == 'Pre-Order') return p.isPreOrder;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerCanvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (result == true) {
            _loadProducts();
          }
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const StadiumBorder(),
        icon: const Icon(Iconsax.box_add_copy, color: Colors.white),
        label: const Text('Tambah Produk',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      body: FutureBuilder<List<ProductModel>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          final loading = snapshot.connectionState == ConnectionState.waiting;
          final products = snapshot.data ?? [];
          final activeCount = products.where((p) => p.isAvailable).length;
          final filtered = products.where((p) => _matches(p, _filter)).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SellerPageHeader(
                title: 'Produk Saya',
                subtitle: loading ? 'Memuat produk…' : '${products.length} produk · $activeCount aktif dijual',
                trailing: IconButton(
                  onPressed: _loadProducts,
                  tooltip: 'Muat ulang',
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.textPrimary),
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: _filters
                      .map((f) => SellerFilterPill(
                            label: f,
                            count: loading ? null : products.where((p) => _matches(p, f)).length,
                            selected: _filter == f,
                            onTap: () => setState(() => _filter = f),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Builder(builder: (_) {
                  if (loading) {
                    return const SellerSkeletonList();
                  }
                  if (snapshot.hasError) {
                    return SellerErrorState(message: '${snapshot.error}', onRetry: _loadProducts);
                  }
                  if (filtered.isEmpty) {
                    return Center(
                      child: SellerEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: _filter == 'Semua' ? 'Belum ada produk' : 'Tidak ada produk "$_filter"',
                        subtitle: _filter == 'Semua'
                            ? 'Ketuk Tambah Produk atau gunakan perintah suara.'
                            : 'Coba pilih filter lain.',
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async => _loadProducts(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _FarmerProductCard(
                        key: ValueKey(filtered[i].id),
                        product: filtered[i],
                        onChanged: _loadProducts,
                      )
                          .animate(delay: (40 * i.clamp(0, 8)).ms)
                          .fadeIn(duration: 320.ms)
                          .slideX(begin: 0.06, curve: Curves.easeOutCubic),
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

class _FarmerProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onChanged;
  const _FarmerProductCard({super.key, required this.product, required this.onChanged});
  @override
  State<_FarmerProductCard> createState() => _FarmerProductCardState();
}

class _FarmerProductCardState extends State<_FarmerProductCard> {
  bool _active = true;

  @override
  void initState() {
    super.initState();
    _active = widget.product.isAvailable;
  }

  void _toggleActive() async {
    try {
      setState(() => _active = !_active);
      await ProductService.updateProduct(widget.product.id, {
        'isAvailable': _active,
      });
      widget.onChanged();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
      setState(() => _active = !_active);
    }
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${widget.product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ProductService.deleteProduct(widget.product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Produk berhasil dihapus'),
                      backgroundColor: AppColors.success),
                );
                widget.onChanged();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child:
                const Text('Hapus', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  void _handleEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProductScreen(product: widget.product),
      ),
    ).then((result) {
      if (result == true) widget.onChanged();
    });
  }

  void _handleDuplicate() async {
    try {
      await ProductService.duplicateProduct(widget.product.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Produk berhasil diduplikat'),
            backgroundColor: AppColors.success),
      );
      widget.onChanged();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, {Color? color}) {
    return PopupMenuItem(
      value: value,
      height: 42,
      child: Row(children: [
        Icon(icon, size: 19, color: color ?? AppColors.textPrimary),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: color ?? AppColors.textPrimary)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final lowStock = p.stock <= 10;
    final stockColor = p.stock <= 0
        ? AppColors.danger
        : lowStock
            ? AppColors.warning
            : AppColors.primaryMid;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _active ? 1 : 0.7,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: sellerCard(),
        child: Row(children: [
          SellerProductImage(
            url: p.imageUrls.isNotEmpty ? p.imageUrls.first : null,
            name: p.name,
            width: 84,
            height: 84,
            radius: 14,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(p.name,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
                if (p.isPreOrder)
                  Container(
                    margin: const EdgeInsets.only(left: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.preOrderPurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('Pre-Order',
                        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.preOrderPurple)),
                  ),
              ]),
              const SizedBox(height: 3),
              Text.rich(TextSpan(children: [
                TextSpan(
                  text: rupiah(p.price),
                  style: const TextStyle(fontSize: 13.5, color: AppColors.primary, fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: ' /${p.unit}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ])),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: p.stock > 0 ? (p.stock / 100).clamp(0.04, 1.0) : 0,
                      backgroundColor: const Color(0xFFEDF1EC),
                      color: stockColor,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${p.stock.toStringAsFixed(0)} ${p.unit}',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: stockColor)),
              ]),
            ]),
          ),
          const SizedBox(width: 4),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Transform.scale(
              scale: 0.82,
              child: Switch.adaptive(
                value: _active,
                activeColor: AppColors.primary,
                onChanged: (_) => _toggleActive(),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'Opsi produk',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              icon: const Icon(Iconsax.more, color: AppColors.textSecondary, size: 20),
              onSelected: (v) {
                if (v == 'edit') _handleEdit();
                if (v == 'dup') _handleDuplicate();
                if (v == 'del') _showDeleteConfirm();
              },
              itemBuilder: (_) => [
                _menuItem('edit', Iconsax.edit_2, 'Edit'),
                _menuItem('dup', Iconsax.copy, 'Duplikat'),
                _menuItem('del', Iconsax.trash, 'Hapus', color: AppColors.danger),
              ],
            ),
          ]),
        ]),
      ),
    );
  }
}

// Edit Product Screen
class EditProductScreen extends StatefulWidget {
  final ProductModel product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  final _formKey = GlobalKey<FormState>();

  late String _selectedCategory;
  late String _selectedUnit;
  late int _stock;
  bool _isLoading = false;

  static const _categories = [
    'Sayuran',
    'Buah',
    'Beras & Biji',
    'Rempah',
    'Umbi',
    'Kacang-kacangan',
    'Lainnya',
  ];

  static const _units = ['kg', 'gram', 'ikat', 'buah', 'liter', 'karung'];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.name);
    _descCtrl = TextEditingController(text: widget.product.description);
    _priceCtrl = TextEditingController(text: widget.product.price.toString());
    _selectedUnit = widget.product.unit;
    _stock = widget.product.stock.toInt();
    _selectedCategory = _categories.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final categoryMap = {
          'Sayuran': 'vegetable',
          'Buah': 'fruit',
          'Beras & Biji': 'grain',
          'Rempah': 'spice',
          'Umbi': 'other',
          'Kacang-kacangan': 'other',
          'Lainnya': 'other',
        };

        final productData = {
          'name': _nameCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'price': double.parse(_priceCtrl.text),
          'unit': _selectedUnit,
          'stock': _stock,
          'category': categoryMap[_selectedCategory],
        };

        await ProductService.updateProduct(widget.product.id, productData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil diupdate'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Produk'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Nama Produk',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                hintText: 'Nama produk',
                filled: true,
                fillColor: AppColors.surface,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            const Text('Deskripsi',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Deskripsi produk',
                filled: true,
                fillColor: AppColors.surface,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Harga',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '0',
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Harga wajib diisi' : null,
                    ),
                  ])),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text('Satuan',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      items: _units
                          .map(
                              (u) => DropdownMenuItem(value: u, child: Text(u)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _selectedUnit = v ?? 'kg'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ])),
            ]),
            const SizedBox(height: 16),
            const Text('Stok',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: '$_stock',
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () =>
                    setState(() => _stock = (_stock - 1).clamp(0, 999)),
                icon: const Icon(Icons.remove),
              ),
              IconButton(
                onPressed: () => setState(() => _stock++),
                icon: const Icon(Icons.add),
              ),
            ]),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(_isLoading ? 'Menyimpan...' : 'Update Produk'),
            ),
          ],
        ),
      ),
    );
  }
}
