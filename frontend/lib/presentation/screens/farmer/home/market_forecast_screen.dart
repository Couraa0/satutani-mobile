import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/mock/market_mock.dart';

class MarketForecastScreen extends StatefulWidget {
  const MarketForecastScreen({super.key});

  @override
  State<MarketForecastScreen> createState() => _MarketForecastScreenState();
}

class _MarketForecastScreenState extends State<MarketForecastScreen> with SingleTickerProviderStateMixin {
  String _selectedPeriod = '7 Hari';
  String _selectedCategory = 'Semua';
  late AnimationController _shimmerController;

  final _periods = ['7 Hari', '14 Hari', '30 Hari'];
  final _categories = ['Semua', 'Sayuran', 'Buah', 'Beras', 'Rempah'];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  List<MarketForecastModel> get _filteredForecasts {
    return mockMarketForecasts.where((f) {
      return _selectedCategory == 'Semua' || f.category == _selectedCategory;
    }).toList();
  }

  double _getForecastPrice(MarketForecastModel f) {
    switch (_selectedPeriod) {
      case '14 Hari':
        return f.forecastPrice14d;
      case '30 Hari':
        return f.forecastPrice30d;
      default:
        return f.forecastPrice7d;
    }
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
                              animation: _shimmerController,
                              builder: (context, child) {
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(
                                      alpha: 0.15 + (_shimmerController.value * 0.1),
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 28),
                                );
                              },
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Prakiraan Pasar',
                                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Prediksi harga & rekomendasi penjualan',
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

          // ── Filters ──
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                    ),
                    child: Row(
                      children: _periods.map((period) {
                        final selected = _selectedPeriod == period;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = period),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: selected
                                    ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 6)]
                                    : null,
                              ),
                              child: Text(
                                period,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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

                // Market summary
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.08),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.insights_rounded, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Ringkasan Pasar',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _SummaryChip(
                            icon: Icons.trending_up_rounded,
                            label: 'Naik',
                            value: '${_filteredForecasts.where((f) => f.forecastTrend == 'up').length}',
                            color: AppColors.danger,
                          ),
                          const SizedBox(width: 8),
                          _SummaryChip(
                            icon: Icons.trending_down_rounded,
                            label: 'Turun',
                            value: '${_filteredForecasts.where((f) => f.forecastTrend == 'down').length}',
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 8),
                          _SummaryChip(
                            icon: Icons.trending_flat_rounded,
                            label: 'Stabil',
                            value: '${_filteredForecasts.where((f) => f.forecastTrend == 'stable').length}',
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),

          // ── Forecast Cards ──
          _filteredForecasts.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.analytics_outlined, size: 56, color: AppColors.textSecondary.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        const Text('Tidak ada prakiraan untuk kategori ini', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final forecast = _filteredForecasts[index];
                      return _ForecastCard(
                        forecast: forecast,
                        forecastPrice: _getForecastPrice(forecast),
                        period: _selectedPeriod,
                      );
                    },
                    childCount: _filteredForecasts.length,
                  ),
                ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ── Summary Chip ──
class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              '$value $label',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Forecast Card ──
class _ForecastCard extends StatelessWidget {
  final MarketForecastModel forecast;
  final double forecastPrice;
  final String period;

  const _ForecastCard({required this.forecast, required this.forecastPrice, required this.period});

  Color get _trendColor {
    switch (forecast.forecastTrend) {
      case 'up':
        return AppColors.danger;
      case 'down':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData get _trendIcon {
    switch (forecast.forecastTrend) {
      case 'up':
        return Icons.north_east_rounded;
      case 'down':
        return Icons.south_east_rounded;
      default:
        return Icons.east_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final priceDiff = forecastPrice - forecast.currentPrice;
    final pricePct = (priceDiff / forecast.currentPrice * 100);
    final isUp = priceDiff > 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _trendColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(forecast.emoji, style: const TextStyle(fontSize: 26))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        forecast.productName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              forecast.category,
                              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _DemandBadge(level: forecast.demandLevel),
                        ],
                      ),
                    ],
                  ),
                ),
                // Confidence score
                _ConfidenceRing(score: forecast.confidenceScore),
              ],
            ),
          ),

          // Price forecast bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _trendColor.withValues(alpha: 0.06),
                  _trendColor.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _trendColor.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                // Current price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Harga Saat Ini', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${_fmt(forecast.currentPrice)}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _trendColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_trendIcon, size: 18, color: _trendColor),
                ),
                const SizedBox(width: 14),
                // Forecast price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Prediksi $period', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(
                        'Rp ${_fmt(forecastPrice)}',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _trendColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Change badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _trendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isUp ? '+' : ''}${pricePct.toStringAsFixed(1)}% (${isUp ? '+' : ''}Rp ${_fmt(priceDiff.abs())})',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _trendColor),
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time_rounded, size: 13, color: AppColors.textSecondary.withValues(alpha: 0.6)),
                const SizedBox(width: 4),
                Text(
                  forecast.bestSellWindow,
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
          ),

          // AI Insight
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analisis AI',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        forecast.aiInsight,
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Supply outlook
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.local_shipping_outlined, size: 15, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Outlook Supply',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.warning),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          forecast.supplyOutlook,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

// ── Demand Badge ──
class _DemandBadge extends StatelessWidget {
  final String level;
  const _DemandBadge({required this.level});

  Color get _color {
    switch (level) {
      case 'Tinggi':
        return AppColors.danger;
      case 'Sedang':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _color.withValues(alpha: 0.2)),
      ),
      child: Text(
        'Demand: $level',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _color),
      ),
    );
  }
}

// ── Confidence Ring ──
class _ConfidenceRing extends StatelessWidget {
  final double score;
  const _ConfidenceRing({required this.score});

  Color get _color {
    if (score >= 0.8) return AppColors.success;
    if (score >= 0.6) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 46,
            height: 46,
            child: CircularProgressIndicator(
              value: score,
              strokeWidth: 3.5,
              backgroundColor: _color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(_color),
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(score * 100).toInt()}',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _color),
              ),
              Text(
                '%',
                style: TextStyle(fontSize: 8, color: _color, fontWeight: FontWeight.w500, height: 0.9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
