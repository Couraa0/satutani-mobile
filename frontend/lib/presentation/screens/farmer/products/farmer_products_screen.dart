import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/product_service.dart';
import '../../../../data/models/product_model.dart';
import 'add_product_screen.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});
  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
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

  List<ProductModel> _filterProducts(List<ProductModel> products) {
    return products.where((p) {
      if (_filter == 'Aktif') return p.isAvailable;
      if (_filter == 'Habis') return !p.isAvailable;
      if (_filter == 'Pre-Order') return p.isPreOrder;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Produk Saya'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
      ),
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
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Produk',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              children: ['Semua', 'Aktif', 'Habis', 'Pre-Order'].map((f) {
                final sel = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(f,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: sel ? Colors.white : AppColors.textPrimary)),
                  ),
                );
              }).toList(),
            ),
          ),
          // Product list
          Expanded(
            child: FutureBuilder<List<ProductModel>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadProducts,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data ?? [];
                final filtered = _filterProducts(products);

                if (filtered.isEmpty) {
                  return const Center(
                      child: Text('Tidak ada produk',
                          style: TextStyle(color: AppColors.textSecondary)));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _FarmerProductCard(
                    product: filtered[i],
                    onChanged: _loadProducts,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmerProductCard extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onChanged;
  const _FarmerProductCard({required this.product, required this.onChanged});
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

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius:
              const BorderRadius.horizontal(left: Radius.circular(14)),
          child: Image.network(
              p.imageUrls.isNotEmpty
                  ? p.imageUrls.first
                  : 'https://via.placeholder.com/85',
              width: 85,
              height: 85,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                  width: 85,
                  height: 85,
                  color: AppColors.primaryLight,
                  child:
                      const Icon(Icons.eco_rounded, color: AppColors.primary))),
        ),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(
              'Rp ${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}/${p.unit}',
              style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          // Stock bar
          Row(children: [
            Expanded(
                child: LinearProgressIndicator(
              value: p.stock > 0 ? (p.stock / 100).clamp(0.0, 1.0) : 0,
              backgroundColor: AppColors.border,
              color: p.stock > 20 ? AppColors.success : AppColors.warning,
              borderRadius: BorderRadius.circular(4),
              minHeight: 5,
            )),
            const SizedBox(width: 6),
            Text('${p.stock.toStringAsFixed(0)}${p.unit}',
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ])),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Switch.adaptive(
              value: _active,
              activeColor: AppColors.primary,
              onChanged: (_) => _toggleActive()),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary, size: 20),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    _handleEdit();
                  },
                ),
              ),
              PopupMenuItem(
                value: 'dup',
                child: ListTile(
                  leading: const Icon(Icons.copy_outlined),
                  title: const Text('Duplikat'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    _handleDuplicate();
                  },
                ),
              ),
              PopupMenuItem(
                value: 'del',
                child: ListTile(
                  leading: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.danger),
                  title: const Text('Hapus',
                      style: TextStyle(color: AppColors.danger)),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirm();
                  },
                ),
              ),
            ],
          ),
        ]),
      ]),
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
