import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  static const _pages = [
    _Page(
      emoji: '🥬',
      chips: ['🍓 Segar', '🥕 Organik', '🌿 Alami'],
      accentColor: AppColors.primary,
      title: 'Produk segar\nlangsung ke pintumu',
      subtitle:
          'Beli sayuran dan buah segar langsung dari petani tanpa perantara. Lebih hemat, lebih segar.',
    ),
    _Page(
      emoji: '🤝',
      chips: ['👨‍🌾 Petani', '💰 Harga Adil', '✅ Terpercaya'],
      accentColor: AppColors.secondary,
      title: 'Dukung petani lokal\nharga tetap adil',
      subtitle:
          'Setiap pembelianmu langsung menghidupi petani. Tanpa tengkulak, semua untung.',
    ),
    _Page(
      emoji: '🚚',
      chips: ['❄️ Cold Chain', '📦 Aman', '⚡ Cepat'],
      accentColor: AppColors.info,
      title: 'Pengiriman cepat\nsampai ke rumah',
      subtitle:
          'Lacak paketmu setiap langkah — dari kebun dipanen sampai tiba di depan pintu.',
    ),
  ];

  bool get _isLast => _page == _pages.length - 1;

  void _next() {
    if (!_isLast) {
      _ctrl.nextPage(
          duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_page];
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                  child: const Text(
                    'Lewati',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (i) => setState(() => _page = i),
                itemCount: _pages.length,
                itemBuilder: (ctx, idx) => _PageContent(page: _pages[idx]),
              ),
            ),
            // Bottom navigation
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _ctrl,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: page.accentColor,
                      dotColor: page.accentColor.withValues(alpha: 0.25),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  // Tombol lanjut — melebar jadi "Mulai" di halaman terakhir
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: _isLast ? 168 : 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: page.accentColor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: page.accentColor.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _isLast
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Mulai Sekarang',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded,
                                    color: Colors.white, size: 22),
                              ],
                            )
                          : const Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 26),
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
}

class _PageContent extends StatelessWidget {
  final _Page page;
  const _PageContent({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ilustrasi: lingkaran besar + emoji utama + chip mengambang
          SizedBox(
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.accentColor.withValues(alpha: 0.10),
                  ),
                )
                    .animate()
                    .scale(
                        duration: 500.ms,
                        begin: const Offset(0.7, 0.7),
                        curve: Curves.easeOutBack),
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: page.accentColor.withValues(alpha: 0.14),
                  ),
                  child: Center(
                    child: Text(page.emoji,
                        style: const TextStyle(fontSize: 76)),
                  ),
                )
                    .animate(delay: 120.ms)
                    .scale(
                        duration: 500.ms,
                        begin: const Offset(0.6, 0.6),
                        curve: Curves.easeOutBack)
                    .fadeIn(),
                // Chip info mengambang
                Positioned(
                  top: 26,
                  left: 6,
                  child: _chip(page.chips[0], 300.ms),
                ),
                Positioned(
                  top: 96,
                  right: 0,
                  child: _chip(page.chips[1], 420.ms),
                ),
                Positioned(
                  bottom: 26,
                  left: 34,
                  child: _chip(page.chips[2], 540.ms),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms).slideY(
              begin: 0.2, curve: Curves.easeOut),
          const SizedBox(height: 14),
          Text(
            page.subtitle,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ).animate(delay: 280.ms).fadeIn(duration: 400.ms).slideY(
              begin: 0.25, curve: Curves.easeOut),
        ],
      ),
    );
  }

  Widget _chip(String label, Duration delay) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12.5, fontWeight: FontWeight.w700)),
    )
        .animate(delay: delay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.5, curve: Curves.easeOutBack)
        .then()
        .moveY(
            begin: 0,
            end: -5,
            duration: 1800.ms,
            curve: Curves.easeInOut);
  }
}

class _Page {
  final String emoji;
  final List<String> chips;
  final Color accentColor;
  final String title;
  final String subtitle;

  const _Page({
    required this.emoji,
    required this.chips,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });
}
