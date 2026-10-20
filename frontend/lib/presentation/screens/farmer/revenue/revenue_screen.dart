import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/order_service.dart';
import '../../../../data/models/farmer_order.dart';
import '../../../../data/mock/orders_mock.dart' show OrderStatus;
import '../../../widgets/seller_ui.dart';

// CATATAN FUTURE: pengguna ingin nantinya petani bisa input sendiri pembanding
// "harga jual ke tengkulak/perantara" vs "jual langsung di SatuTani" untuk
// ditampilkan berdampingan di grafik. Saat ini grafik hanya menampilkan
// pendapatan riil (SatuTani) dari order berstatus selesai.

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
];

class RevenueScreen extends StatefulWidget {
  const RevenueScreen({super.key});

  @override
  State<RevenueScreen> createState() => _RevenueScreenState();
}

class _RevenueScreenState extends State<RevenueScreen> {
  late Future<List<FarmerOrder>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadCompleted();
  }

  Future<List<FarmerOrder>> _loadCompleted() async {
    final raw = await OrderService.getFarmerOrders();
    return FarmerOrder.listFromJson(raw)
        .where((o) => o.status == OrderStatus.selesai)
        .toList();
  }

  static String _fmt(double v) => rupiah(v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: sellerCanvas,
      body: FutureBuilder<List<FarmerOrder>>(
        future: _future,
        builder: (context, snap) {
          final loading = snap.connectionState == ConnectionState.waiting;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SellerPageHeader(
                title: 'Pendapatan',
                subtitle: 'Dihitung dari pesanan yang sudah selesai',
              ),
              Expanded(
                child: loading
                    ? const SellerSkeletonList(itemHeight: 150, count: 3)
                    : snap.hasError
                        ? SellerErrorState(
                            message: '${snap.error}',
                            onRetry: () => setState(() {
                              _future = _loadCompleted();
                            }),
                          )
                        : RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: () async {
                              setState(() {
                                _future = _loadCompleted();
                              });
                              await _future;
                            },
                            child: _buildContent(context, snap.data ?? []),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<FarmerOrder> completed) {
    final now = DateTime.now();
    double totalFor(DateTime d) => completed
        .where((o) => o.createdAt.year == d.year && o.createdAt.month == d.month)
        .fold(0.0, (s, o) => s + o.total);

    // Order selesai bulan ini.
    final thisMonth = completed
        .where((o) => o.createdAt.year == now.year && o.createdAt.month == now.month)
        .toList();
    final monthTotal = thisMonth.fold(0.0, (s, o) => s + o.total);
    final monthCount = thisMonth.length;
    final avg = monthCount > 0 ? monthTotal / monthCount : 0.0;
    final lastMonthTotal = totalFor(DateTime(now.year, now.month - 1, 1));
    final growth = lastMonthTotal > 0 ? (monthTotal - lastMonthTotal) / lastMonthTotal * 100 : null;

    // Pendapatan 6 bulan terakhir (termasuk bulan ini).
    final buckets = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i), 1);
      return (label: _months[d.month - 1], value: totalFor(d));
    });
    final maxVal = buckets.fold(0.0, (m, b) => b.value > m ? b.value : m);
    final maxY = maxVal <= 0 ? 100000.0 : maxVal * 1.25;
    final sixMonthTotal = buckets.fold(0.0, (s, b) => s + b.value);

    // Riwayat transaksi (selesai), terbaru dulu.
    final history = [...completed]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
      children: <Widget>[
        // ── Hero pendapatan bulan ini ─────────────────────────────────────
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0A6B32), AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(color: AppColors.primary.withValues(alpha: 0.28), blurRadius: 22, offset: const Offset(0, 10)),
            ],
          ),
          child: Stack(children: [
            Positioned(
              right: -36,
              top: -46,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.06)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pendapatan ${_months[now.month - 1]} ${now.year}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                CountUpRupiah(
                    value: monthTotal,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                const SizedBox(height: 8),
                if (growth != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(growth >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                          size: 14, color: growth >= 0 ? Colors.greenAccent : Colors.orangeAccent),
                      const SizedBox(width: 4),
                      Text('${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(0)}% dari bulan lalu',
                          style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ]),
                  )
                else
                  Text('Total 6 bulan: ${_fmt(sixMonthTotal)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pencairan dana sedang diproses...'), backgroundColor: AppColors.primary)),
                    icon: const Icon(Iconsax.bank, color: AppColors.primary, size: 19),
                    label: const Text('Cairkan Dana',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      minimumSize: const Size(0, 46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
        const SizedBox(height: 14),

        // ── Statistik ringkas ─────────────────────────────────────────────
        Row(children: [
          Expanded(
            child: _SummaryCard(
              icon: Iconsax.task_square_copy,
              label: 'Transaksi Selesai',
              value: '$monthCount',
              color: AppColors.info,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              icon: Iconsax.receipt_item_copy,
              label: 'Rata-rata / Order',
              value: _fmt(avg),
              color: const Color(0xFFE08A00),
            ),
          ),
        ]),
        const SizedBox(height: 24),

        // ── Grafik ────────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          decoration: sellerCard(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tren 6 Bulan Terakhir',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text('Total ${_fmt(sixMonthTotal)}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 18),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => AppColors.primaryDark,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                        _fmt(rod.toY),
                        const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i >= buckets.length) return const SizedBox.shrink();
                          final current = i == buckets.length - 1;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(buckets[i].label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                                  color: current ? AppColors.primary : AppColors.textSecondary,
                                )),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(buckets.length, (i) {
                    final current = i == buckets.length - 1;
                    return BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: buckets[i].value,
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: current
                              ? const [AppColors.primaryDark, Color(0xFF1F9D55)]
                              : const [Color(0xFFA9D4B6), Color(0xFFCFE9D6)],
                        ),
                        width: 22,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: sellerCanvas,
                        ),
                      ),
                    ]);
                  }),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 26),

        // ── Riwayat ───────────────────────────────────────────────────────
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('Riwayat Transaksi',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ),
        const SizedBox(height: 12),
        if (history.isEmpty)
          const SellerEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Belum ada transaksi selesai',
            subtitle: 'Pendapatan akan tercatat saat pesanan ditandai selesai.',
          )
        else
          Container(
            decoration: sellerCard(),
            child: Column(children: [
              for (final (i, h) in history.indexed) ...[
                if (i > 0) const Divider(height: 1, indent: 66, endIndent: 16, color: Color(0xFFEFF2EE)),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      child: const Icon(Iconsax.money_recive, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(h.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                        const SizedBox(height: 2),
                        Text('${_dateStr(h.createdAt)} · ${h.consumerName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                      ]),
                    ),
                    Text('+${_fmt(h.total)}',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13.5)),
                  ]),
                ),
              ],
            ]),
          ),
      ].animate(interval: 50.ms).fadeIn(duration: 360.ms).slideY(begin: 0.06, curve: Curves.easeOutCubic),
    );
  }

  static String _dateStr(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const _SummaryCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: sellerCard(),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(value,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              ),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ),
        ]),
      );
}
