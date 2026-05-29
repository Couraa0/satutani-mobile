import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/mock/products_mock.dart';
import 'add_product_screen.dart';

class FarmerProductsScreen extends StatefulWidget {
  const FarmerProductsScreen({super.key});
  @override
  State<FarmerProductsScreen> createState() => _FarmerProductsScreenState();
}

class _FarmerProductsScreenState extends State<FarmerProductsScreen> {
  String _filter = 'Semua';

  List<ProductModel> get _filtered => mockProducts.where((p) {
    if (_filter == 'Aktif') return p.status == ProductStatus.tersedia;
    if (_filter == 'Habis') return p.status == ProductStatus.habis;
    if (_filter == 'Pre-Order') return p.status == ProductStatus.preOrder;
    return true;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Produk Saya')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Produk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(f, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500,
                      color: sel ? Colors.white : AppColors.textPrimary)),
                  ),
                );
              }).toList(),
            ),
          ),
          // Product list
          Expanded(
            child: _filtered.isEmpty
                ? const Center(child: Text('Tidak ada produk', style: TextStyle(color: AppColors.textSecondary)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _FarmerProductCard(product: _filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FarmerProductCard extends StatefulWidget {
  final ProductModel product;
  const _FarmerProductCard({required this.product});
  @override
  State<_FarmerProductCard> createState() => _FarmerProductCardState();
}

class _FarmerProductCardState extends State<_FarmerProductCard> {
  bool _active = true;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
          child: Image.network(p.imageUrls.first, width: 85, height: 85, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 85, height: 85, color: AppColors.primaryLight,
              child: const Icon(Icons.eco_rounded, color: AppColors.primary))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text('Rp ${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}/${p.unit}',
            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          // Stock bar
          Row(children: [
            Expanded(child: LinearProgressIndicator(
              value: p.stock > 0 ? (p.stock / 100).clamp(0.0, 1.0) : 0,
              backgroundColor: AppColors.border, color: p.stock > 20 ? AppColors.success : AppColors.warning,
              borderRadius: BorderRadius.circular(4), minHeight: 5,
            )),
            const SizedBox(width: 6),
            Text('${p.stock}${p.unit}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ]),
        ])),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Switch.adaptive(value: _active, activeColor: AppColors.primary,
            onChanged: (v) => setState(() => _active = v)),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary, size: 20),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'), dense: true, contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'dup', child: ListTile(leading: Icon(Icons.copy_outlined), title: Text('Duplikat'), dense: true, contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'del', child: ListTile(leading: Icon(Icons.delete_outline_rounded, color: AppColors.danger), title: Text('Hapus', style: TextStyle(color: AppColors.danger)), dense: true, contentPadding: EdgeInsets.zero)),
            ],
          ),
        ]),
      ]),
    );
  }
}
