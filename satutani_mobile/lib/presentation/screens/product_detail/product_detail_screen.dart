import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../data/mock/products_mock.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _currentImage = 0;
  bool _isWishlisted = false;
  bool _showFullDesc = false;

  late ProductModel product;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ProductModel) {
      product = args;
    } else {
      product = mockProducts.first; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = product.price * _quantity;
    final priceStr = product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detail Produk'),
        actions: [
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
          IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _isWishlisted ? Colors.red[300] : Colors.white,
            ),
            onPressed: () => setState(() => _isWishlisted = !_isWishlisted),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageCarousel(product),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: Text(product.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                            const SizedBox(width: 8),
                            Text('Rp $priceStr', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('/ ${product.unit}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.secondary, size: 16),
                            const SizedBox(width: 4),
                            Text('${product.rating.toStringAsFixed(1)} (${product.reviewCount} ulasan)', style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text('Stok: ${product.stock} ${product.unit}', style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (product.isAiPrice)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Harga dioptimalkan AI', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        if (product.isPreOrder) _buildPreOrderSection(product),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  _buildAboutSection(product),
                  const Divider(height: 1),
                  _buildFarmerSection(product),
                  const Divider(height: 1),
                  _buildBlockchainSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          _buildBottomBar(total),
        ],
      ),
    );
  }

  Widget _buildImageCarousel(ProductModel product) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: product.imageUrls.length,
            onPageChanged: (i) => setState(() => _currentImage = i),
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: product.imageUrls[index], fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.primaryLight, child: const Center(child: CircularProgressIndicator())),
                errorWidget: (context, url, error) => Container(color: AppColors.primaryLight, child: const Center(child: Icon(Icons.eco, size: 64, color: AppColors.primary))),
              );
            },
          ),
        ),
        if (product.imageUrls.length > 1)
          Positioned(
            bottom: 12, left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product.imageUrls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200), margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _currentImage ? 16 : 8, height: 8,
                  decoration: BoxDecoration(color: i == _currentImage ? AppColors.primary : Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreOrderSection(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B9A).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6A1B9A).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pending_actions_rounded, size: 16, color: Color(0xFF6A1B9A)),
              SizedBox(width: 6),
              Text('Tersedia secara Pre-Order', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A))),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Estimasi pengiriman akan dinegosiasikan dengan petani.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAboutSection(ProductModel product) {
    final desc = 'Produk segar langsung dari kebun dengan metode penanaman terbaik. Sangat cocok untuk kebutuhan harian keluarga dan usaha Anda. Pastikan menyimpannya di suhu optimal agar kesegaran tetap terjaga selama beberapa hari.';
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Deskripsi Produk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          Text(desc, maxLines: _showFullDesc ? null : 3, overflow: _showFullDesc ? null : TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _showFullDesc = !_showFullDesc),
            child: Text(_showFullDesc ? 'Sembunyikan' : 'Lihat Lebih Banyak', style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmerSection(ProductModel product) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Petani', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 26, backgroundColor: AppColors.primaryLight,
                child: Text(product.farmerName[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.farmerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Text('Jawa Barat', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(minimumSize: const Size(80, 36), padding: const EdgeInsets.symmetric(horizontal: 12)),
                child: const Text('Kunjungi', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Keterlacakan Produk (Blockchain)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withValues(alpha: 0.3))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Terverifikasi', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 36,
                  child: OutlinedButton.icon(
                    onPressed: () {}, icon: const Icon(Icons.link_rounded, size: 16),
                    label: const Text('Lihat Riwayat Lacak', style: TextStyle(fontSize: 12)), style: OutlinedButton.styleFrom(minimumSize: Size.zero),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double total) {
    final tFmt = total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Total Pembayaran', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                Text('Rp $tFmt', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
            const SizedBox(width: 16),
            Container(
              height: 40,
              decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  GestureDetector(onTap: () { if (_quantity > 1) setState(() => _quantity--); }, child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.remove_rounded, size: 16, color: AppColors.primary))),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: Text('$_quantity', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
                  GestureDetector(onTap: () => setState(() => _quantity++), child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.add_rounded, size: 16, color: AppColors.primary))),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 42)),
                child: const Text('Beli'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
