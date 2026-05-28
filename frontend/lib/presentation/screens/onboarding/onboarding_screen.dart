import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      emoji: '🥦🥕🥑',
      topEmoji: '🫐🍓🌿',
      bgColor: Color(0xFFFAFAFA),
      accentColor: AppColors.primary,
      title: 'Produk segar\nlangsung ke pintumu!',
      subtitle:
          'Beli sayuran dan buah segar langsung dari petani tanpa perantara. Lebih hemat, lebih segar.',
    ),
    _Page(
      emoji: '🌶️🧄🥐',
      topEmoji: '☕🫚🫙',
      bgColor: Color(0xFFFFF8F0),
      accentColor: Color(0xFFF5A623),
      title: 'Belanja kebutuhanmu\nsetiap hari!',
      subtitle:
          'Temukan berbagai produk pertanian segar berkualitas tinggi dari ribuan petani terpercaya.',
    ),
    _Page(
      emoji: '📦🛵💨',
      topEmoji: '🏠🔑✨',
      bgColor: Color(0xFFF0F7FF),
      accentColor: Color(0xFF1976D2),
      title: 'Pengiriman cepat\nsampai ke rumah!',
      subtitle:
          'Nikmati kemudahan berbelanja dengan pengiriman cepat dan terpercaya langsung ke rumahmu.',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
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
      backgroundColor: page.bgColor,
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
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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
                itemBuilder: (ctx, idx) {
                  final p = _pages[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration box
                        Container(
                          width: double.infinity,
                          height: 260,
                          decoration: BoxDecoration(
                            color: p.accentColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Top floating items
                              Positioned(
                                top: 24,
                                left: 30,
                                child: Text(p.topEmoji.split('').take(1).join(),
                                    style: const TextStyle(fontSize: 36)),
                              ),
                              Positioned(
                                top: 16,
                                right: 28,
                                child: Text(p.topEmoji.split('').skip(1).take(1).join(),
                                    style: const TextStyle(fontSize: 30)),
                              ),
                              Positioned(
                                top: 48,
                                right: 60,
                                child: Text(p.topEmoji.split('').skip(2).take(1).join(),
                                    style: const TextStyle(fontSize: 26)),
                              ),
                              // Center big emoji
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    p.emoji,
                                    style: const TextStyle(fontSize: 64),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          p.title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          p.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom navigation
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator
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
                  // Next button – arrow circle style
                  GestureDetector(
                    onTap: _next,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: page.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: page.accentColor.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
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

class _Page {
  final String emoji;
  final String topEmoji;
  final Color bgColor;
  final Color accentColor;
  final String title;
  final String subtitle;

  const _Page({
    required this.emoji,
    required this.topEmoji,
    required this.bgColor,
    required this.accentColor,
    required this.title,
    required this.subtitle,
  });
}
