import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/mock/market_mock.dart';

class AiPriceCheckScreen extends StatefulWidget {
  const AiPriceCheckScreen({super.key});

  @override
  State<AiPriceCheckScreen> createState() => _AiPriceCheckScreenState();
}

class _AiPriceCheckScreenState extends State<AiPriceCheckScreen> with SingleTickerProviderStateMixin {
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  final _searchController = TextEditingController();
  int? _expandedIndex;
  late AnimationController _pulseController;

  final _categories = ['Semua', 'Sayuran', 'Buah', 'Beras', 'Rempah'];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<MarketPriceModel> get _filteredPrices {
    return mockMarketPrices.where((p) {
      final matchCategory = _selectedCategory == 'Semua' || p.category == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          p.productName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverAppBar(
            pinned: true,
            expandedHeight: 160,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF005C25), Color(0xFF00441b)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.15 + (_pulseController.value * 0.1),
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 28),
                                );
                              },
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cek Harga AI',
                                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Harga pasar terkini & prediksi AI',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Search & Filter ──
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Cari komoditas...',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 14),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),

                // Category chips
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final selected = _selectedCategory == _categories[i];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = _categories[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? AppColors.primary : AppColors.border,
                            ),
                            boxShadow: selected
                                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                : null,
                          ),
                          child: Text(
                            _categories[i],
                            style: TextStyle(
                              color: selected ? Colors.white : AppColors.textSecondary,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // AI badge
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.primary.withValues(alpha: 0.05)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Harga diperbarui real-time menggunakan analisis AI dari 12 pasar induk.',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Price Cards ──
          _filteredPrices.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.search_off_rounded, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text('Komoditas tidak ditemukan', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final price = _filteredPrices[index];
                      final isExpanded = _expandedIndex == index;
                      return _PriceCard(
                        price: price,
                        isExpanded: isExpanded,
                        onTap: () {
                          setState(() {
                            _expandedIndex = isExpanded ? null : index;
                          });
                        },
                      );
                    },
                    childCount: _filteredPrices.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Price Card Widget ──
class _PriceCard extends StatelessWidget {
  final MarketPriceModel price;
  final bool isExpanded;
  final VoidCallback onTap;

  const _PriceCard({required this.price, required this.isExpanded, required this.onTap});

  Color get _trendColor {
    switch (price.trend) {
      case 'up':
        return AppColors.danger;
      case 'down':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _trendIcon {
    switch (price.trend) {
      case 'up':
        return Icons.trending_up_rounded;
      case 'down':
        return Icons.trending_down_rounded;
      default:
        return Icons.trending_flat_rounded;
    }
  }

  String get _trendLabel {
    switch (price.trend) {
      case 'up':
        return '+${price.changePercent.toStringAsFixed(1)}%';
      case 'down':
        return '${price.changePercent.toStringAsFixed(1)}%';
      default:
        return 'Stabil';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpanded ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
          boxShadow: [
            BoxShadow(
              color: isExpanded
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.04),
              blurRadius: isExpanded ? 16 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Main row
            Row(
              children: [
                // Emoji
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _trendColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(price.emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        price.productName,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        price.category,
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                // Price & Trend
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rp ${_formatPrice(price.currentPrice)}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _trendColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_trendIcon, size: 14, color: _trendColor),
                          const SizedBox(width: 3),
                          Text(
                            _trendLabel,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _trendColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Expanded detail
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: _buildExpandedContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            color: AppColors.border.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 14),

          // AI Predicted Price
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withValues(alpha: 0.06), AppColors.primary.withValues(alpha: 0.02)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Prediksi Harga AI',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${_formatPrice(price.aiPredictedPrice)}/${price.unit}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _confidenceColor(price.aiConfidence).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_rounded, size: 13, color: _confidenceColor(price.aiConfidence)),
                      const SizedBox(width: 4),
                      Text(
                        price.aiConfidence,
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _confidenceColor(price.aiConfidence)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Price comparison
          Row(
            children: [
              Expanded(
                child: _PriceCompareItem(
                  label: '1 Minggu Lalu',
                  price: price.weekAgoPrice,
                  unit: price.unit,
                  currentPrice: price.currentPrice,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PriceCompareItem(
                  label: '1 Bulan Lalu',
                  price: price.monthAgoPrice,
                  unit: price.unit,
                  currentPrice: price.currentPrice,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Mini chart
          const Text(
            'Tren Harga 7 Hari',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 60,
            child: _MiniChart(history: price.priceHistory, trendColor: _trendColor),
          ),

          const SizedBox(height: 14),

          // AI Reason
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_rounded, size: 16, color: AppColors.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    price.aiReason,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _confidenceColor(String conf) {
    switch (conf) {
      case 'Tinggi':
        return AppColors.success;
      case 'Sedang':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }
}

// ── Price Comparison Item ──
class _PriceCompareItem extends StatelessWidget {
  final String label;
  final double price;
  final String unit;
  final double currentPrice;

  const _PriceCompareItem({
    required this.label,
    required this.price,
    required this.unit,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final diff = currentPrice - price;
    final pct = (diff / price * 100);
    final isUp = diff > 0;
    final color = isUp ? AppColors.danger : (diff < 0 ? AppColors.success : AppColors.textSecondary);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(
            'Rp ${_fmt(price)}',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            '${isUp ? '+' : ''}${pct.toStringAsFixed(1)}%',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  String _fmt(double p) => p.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
}

// ── Mini Chart ──
class _MiniChart extends StatelessWidget {
  final List<PriceHistory> history;
  final Color trendColor;

  const _MiniChart({required this.history, required this.trendColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 60),
      painter: _ChartPainter(history: history, color: trendColor),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<PriceHistory> history;
  final Color color;

  _ChartPainter({required this.history, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    final prices = history.map((h) => h.price).toList();
    final minP = prices.reduce((a, b) => a < b ? a : b);
    final maxP = prices.reduce((a, b) => a > b ? a : b);
    final range = maxP - minP == 0 ? 1 : maxP - minP;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    for (var i = 0; i < prices.length; i++) {
      final x = (i / (prices.length - 1)) * size.width;
      final y = size.height - ((prices[i] - minP) / range) * (size.height - 10) - 5;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    // Draw dots
    final dotPaint = Paint()..color = color;
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < prices.length; i++) {
      final x = (i / (prices.length - 1)) * size.width;
      final y = size.height - ((prices[i] - minP) / range) * (size.height - 10) - 5;
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
      canvas.drawCircle(Offset(x, y), 3.5, dotBorderPaint);
    }

    // Draw date labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 0; i < history.length; i += 2) {
      final x = (i / (history.length - 1)) * size.width;
      textPainter.text = TextSpan(
        text: history[i].date.split(' ')[0],
        style: TextStyle(fontSize: 9, color: AppColors.textSecondary.withValues(alpha: 0.7)),
      );
      textPainter.layout();
      final dx = (x - textPainter.width / 2).clamp(0, size.width - textPainter.width);
      textPainter.paint(canvas, Offset(dx.toDouble(), size.height - 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
