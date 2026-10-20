import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/colors.dart';
import '../../data/mock/orders_mock.dart' show OrderStatus;

// Elemen UI bersama untuk tampilan seller (petani) agar semua tab konsisten.

/// Latar halaman seller — off-white bernuansa sage supaya kartu putih menonjol.
const sellerCanvas = Color(0xFFF4F7F2);

String rupiah(double v) =>
    'Rp ${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

BoxDecoration sellerCard({double radius = 18, Color color = Colors.white}) => BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(color: const Color(0xFF0B2A14).withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 6)),
      ],
    );

/// Header besar untuk tab seller (pengganti AppBar hijau default).
class SellerPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? bottom;

  const SellerPageHeader({super.key, required this.title, this.subtitle, this.trailing, this.bottom});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5, color: AppColors.textPrimary)),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
            if (bottom != null) ...[const SizedBox(height: 14), bottom!],
          ],
        ),
      ),
    );
  }
}

class SellerSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SellerSectionTitle({super.key, required this.title, this.subtitle, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.2, color: AppColors.textPrimary)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Row(children: [
                Text(actionLabel!,
                    style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700)),
                const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
              ]),
            ),
        ],
      ),
    );
  }
}

/// Pill filter yang dipakai di tab Produk & Pesanan.
class SellerFilterPill extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  const SellerFilterPill({super.key, required this.label, this.count, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE3E8E1)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textPrimary)),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.22) : sellerCanvas,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('$count',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : AppColors.textSecondary)),
            ),
          ],
        ]),
      ),
    );
  }
}

/// Ubin warna + emoji per komoditas, dipakai saat produk belum punya foto.
class CommodityTile extends StatelessWidget {
  final String name;
  final double width;
  final double height;

  const CommodityTile({super.key, required this.name, required this.width, required this.height});

  // ponytail: pencocokan kata kunci sederhana; tambah entri saat komoditas baru muncul.
  static const _styles = <(List<String>, String, Color, Color)>[
    (['wortel'], '🥕', Color(0xFFFFE3C7), Color(0xFFFFB877)),
    (['rawit', 'cabai', 'cabe'], '🌶️', Color(0xFFFFD6D1), Color(0xFFFF8A7A)),
    (['tomat'], '🍅', Color(0xFFFFDAD4), Color(0xFFFF9A8B)),
    (['bawang'], '🧅', Color(0xFFF3DDF0), Color(0xFFD9A6D3)),
    (['kentang', 'umbi', 'singkong'], '🥔', Color(0xFFF5E8D2), Color(0xFFDDBF8E)),
    (['jagung'], '🌽', Color(0xFFFFF2C2), Color(0xFFFFD45E)),
    (['terong'], '🍆', Color(0xFFE6DDF7), Color(0xFFB79BE6)),
    (['beras', 'padi', 'gabah'], '🌾', Color(0xFFF8EED3), Color(0xFFE6CF8A)),
    (['kangkung', 'bayam', 'sawi', 'selada', 'kol', 'brokoli'], '🥬', Color(0xFFDDF3DF), Color(0xFF9ED8A6)),
    (['pisang'], '🍌', Color(0xFFFFF4C9), Color(0xFFFFDF70)),
    (['mangga'], '🥭', Color(0xFFFFE8C4), Color(0xFFFFBF5E)),
    (['jeruk'], '🍊', Color(0xFFFFE4C9), Color(0xFFFFAD5C)),
    (['semangka'], '🍉', Color(0xFFFFDDE0), Color(0xFFFF97A2)),
  ];

  @override
  Widget build(BuildContext context) {
    final n = name.toLowerCase();
    var style = ('🌱', const Color(0xFFDFF1E3), const Color(0xFF9FD3AE));
    for (final s in _styles) {
      if (s.$1.any(n.contains)) {
        style = (s.$2, s.$3, s.$4);
        break;
      }
    }
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [style.$2, style.$3],
        ),
      ),
      child: Stack(children: [
        Positioned(
          right: -width * 0.15,
          bottom: -width * 0.15,
          child: Container(
            width: width * 0.6,
            height: width * 0.6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.25)),
          ),
        ),
        Center(child: Text(style.$1, style: TextStyle(fontSize: (height < width ? height : width) * 0.42))),
      ]),
    );
  }
}

/// Gambar produk: URL http(s) dari DB atau aset lokal, dengan fallback ubin komoditas.
class SellerProductImage extends StatelessWidget {
  final String? url;
  final String name;
  final double width;
  final double height;
  final double radius;

  const SellerProductImage(
      {super.key, this.url, this.name = '', required this.width, required this.height, this.radius = 14});

  @override
  Widget build(BuildContext context) {
    final fallback = CommodityTile(name: name, width: width, height: height);
    final u = url ?? '';
    Widget img;
    if (u.isEmpty) {
      img = fallback;
    } else if (u.startsWith('http')) {
      img = Image.network(u, width: width, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback);
    } else {
      img = Image.asset(u, width: width, height: height, fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback);
    }
    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: img);
  }
}

class SellerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const SellerEmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
          child: Icon(icon, color: AppColors.primary, size: 30),
        ),
        const SizedBox(height: 14),
        Text(title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
      ]),
    );
  }
}

class SellerErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const SellerErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: const Icon(Icons.wifi_off_rounded, color: AppColors.danger, size: 28),
          ),
          const SizedBox(height: 14),
          const Text('Gagal memuat data', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(message.replaceAll(RegExp(r'(Exception|Error):\s*'), ''),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(150, 44)),
          ),
        ]),
      ),
    );
  }
}

/// Angka rupiah yang "menghitung naik" saat pertama tampil / berubah.
class CountUpRupiah extends StatelessWidget {
  final double value;
  final TextStyle style;

  const CountUpRupiah({super.key, required this.value, required this.style});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(rupiah(v), style: style),
    );
  }
}

/// Skeleton shimmer untuk daftar kartu saat memuat.
class SellerSkeletonList extends StatelessWidget {
  final int count;
  final double itemHeight;
  final EdgeInsets padding;

  const SellerSkeletonList({
    super.key,
    this.count = 4,
    this.itemHeight = 104,
    this.padding = const EdgeInsets.fromLTRB(16, 10, 16, 0),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6ECE4),
      highlightColor: const Color(0xFFF7FAF6),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: itemHeight,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }
}

/// Progres 5 tahap pesanan: Menunggu → Dikonfirmasi → Dipanen → Dikirim → Selesai.
class OrderProgressBar extends StatelessWidget {
  final OrderStatus status;
  const OrderProgressBar({super.key, required this.status});

  static const _steps = [
    OrderStatus.menunggu,
    OrderStatus.dikonfirmasi,
    OrderStatus.dipanen,
    OrderStatus.dikirim,
    OrderStatus.selesai,
  ];

  @override
  Widget build(BuildContext context) {
    final cancelled = status == OrderStatus.dibatalkan;
    final reached = cancelled ? 0 : _steps.indexOf(status) + 1;
    return Row(children: [
      for (var i = 0; i < _steps.length; i++) ...[
        if (i > 0) const SizedBox(width: 4),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: cancelled
                  ? AppColors.danger.withValues(alpha: 0.25)
                  : i < reached
                      ? AppColors.primaryMid
                      : const Color(0xFFE6ECE4),
            ),
          ),
        ),
      ],
    ]);
  }
}
