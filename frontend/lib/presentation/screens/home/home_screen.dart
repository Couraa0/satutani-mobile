import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/strings.dart';
import '../../../data/mock/products_mock.dart';
import '../../../data/mock/farmers_mock.dart';
import '../../widgets/section_header.dart';
import 'widgets/banner_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async => await Future.delayed(const Duration(milliseconds: 800)),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/explore'),
                      child: Container(
                        height: 52,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F8FA),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 22),
                            const SizedBox(width: 12),
                            Text('Cari produk segar...', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: const Icon(Icons.tune_rounded, color: AppColors.textPrimary, size: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  HeroBannerWidget(onExplore: () => Navigator.pushNamed(context, '/explore')),
                  const SizedBox(height: 16),
                  _buildCategories(context),
                  const SizedBox(height: 20),
                  SectionHeader(title: AppStrings.popularProducts, actionLabel: AppStrings.viewAll, onAction: () {}),
                  const SizedBox(height: 10),
                  _buildProducts(context),
                  const SizedBox(height: 20),
                  SectionHeader(title: AppStrings.nearbyFarmers, actionLabel: AppStrings.viewAll, onAction: () {}),
                  const SizedBox(height: 10),
                  _buildFarmers(context),
                  // Subscription CTA
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(children: [
                      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(AppStrings.subscriptionCta, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('Hemat hingga 20% dengan berlangganan', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ])),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, foregroundColor: AppColors.primary,
                          minimumSize: const Size(80, 36), padding: const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: const Text('Mulai', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Lokasi Anda', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                const Row(children: [
                  Icon(Icons.location_on_rounded, color: AppColors.primary, size: 15),
                  SizedBox(width: 4),
                  Text('Jakarta, DKI Jakarta', style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                  SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textPrimary, size: 16),
                ]),
              ])),
              Stack(clipBehavior: Clip.none, children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
                ),
                Positioned(top: -2, right: -2, child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                )),
              ]),
              const SizedBox(width: 10),
              const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=12'),
                backgroundColor: AppColors.primaryLight,
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final cats = [
      ('🥬', AppStrings.catSayuran),
      ('🍎', AppStrings.catBuah),
      ('🌾', AppStrings.catBeras),
      ('🌶️', AppStrings.catRempah),
      ('🐟', AppStrings.catIkan),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Text(AppStrings.categoryTitle, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
      const SizedBox(height: 10),
      SizedBox(
        height: 78,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: cats.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (_, i) => GestureDetector(
            onTap: () {},
            child: Column(children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14)),
                child: Center(child: Text(cats[i].$1, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(height: 4),
              Text(cats[i].$2, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ]),
          ),
        ),
      ),
    ]);
  }

  Widget _buildProducts(BuildContext context) {
    return SizedBox(
      height: 225,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mockProducts.take(6).length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final p = mockProducts[i];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: p),
            child: Container(
              width: 155,
              decoration: BoxDecoration(
                color: AppColors.surface, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 2))],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Stack(children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: p.imageUrls.first, height: 108, width: double.infinity, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(height: 108, color: AppColors.primaryLight),
                      errorWidget: (_, __, ___) => Container(height: 108, color: AppColors.primaryLight,
                        child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 36)),
                    ),
                  ),
                  if (p.isOrganic) Positioned(top: 7, left: 7, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(6)),
                    child: const Text('Organik', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  )),
                  Positioned(top: 7, right: 7, child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: p.isPreOrder ? const Color(0xFF6A1B9A) : p.isAvailable ? AppColors.success : AppColors.danger,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(p.isPreOrder ? 'Pre-Order' : p.isAvailable ? 'Tersedia' : 'Habis',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
                  )),
                ]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      const Icon(Icons.star_rounded, color: AppColors.secondary, size: 12),
                      const SizedBox(width: 2),
                      Text('${p.rating} (${p.reviewCount})', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ]),
                    const SizedBox(height: 2),
                    Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('Rp ${p.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}/${p.unit}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ]),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFarmers(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: mockFarmers.take(5).length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final f = mockFarmers[i];
          return GestureDetector(
            onTap: () {},
            child: Container(
              width: 165,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8)],
              ),
              child: Row(children: [
                CircleAvatar(radius: 24, backgroundImage: NetworkImage(f.avatarUrl),
                  onBackgroundImageError: (_, __) {}, backgroundColor: AppColors.primaryLight),
                const SizedBox(width: 10),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Row(children: [
                    Expanded(child: Text(f.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    if (f.isVerified) const Icon(Icons.verified_rounded, color: AppColors.info, size: 13),
                  ]),
                  Text(f.location, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.star_rounded, color: AppColors.secondary, size: 11),
                    const SizedBox(width: 2),
                    Text('${f.rating}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ]),
                ])),
              ]),
            ),
          );
        },
      ),
    );
  }
}
