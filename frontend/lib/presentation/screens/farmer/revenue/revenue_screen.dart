import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/services/order_service.dart';
import '../../../../data/models/farmer_order.dart';
import '../../../../data/mock/orders_mock.dart' show OrderStatus;

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

  static String _fmt(double v) => v
      .toStringAsFixed(0)
      .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pendapatan')),
      body: FutureBuilder<List<FarmerOrder>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('${snap.error}', textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      _future = _loadCompleted();
                    }),
                    child: const Text('Coba Lagi'),
                  ),
                ]),
              ),
            );
          }
          return _buildContent(context, snap.data ?? []);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<FarmerOrder> completed) {
    final now = DateTime.now();
    // Order selesai bulan ini.
    final thisMonth = completed
        .where((o) => o.createdAt.year == now.year && o.createdAt.month == now.month)
        .toList();
    final monthTotal = thisMonth.fold(0.0, (s, o) => s + o.total);
    final monthCount = thisMonth.length;
    final avg = monthCount > 0 ? monthTotal / monthCount : 0.0;

    // Pendapatan 6 bulan terakhir (termasuk bulan ini).
    final buckets = List.generate(6, (i) {
      final d = DateTime(now.year, now.month - (5 - i), 1);
      final sum = completed
          .where((o) => o.createdAt.year == d.year && o.createdAt.month == d.month)
          .fold(0.0, (s, o) => s + o.total);
      return (label: _months[d.month - 1], value: sum);
    });
    final maxVal = buckets.fold(0.0, (m, b) => b.value > m ? b.value : m);
    final maxY = maxVal <= 0 ? 100000.0 : maxVal * 1.25;

    // Riwayat transaksi (selesai), terbaru dulu.
    final history = [...completed]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary cards
        Row(children: [
          Expanded(child: _SummaryCard(label: 'Total Bulan Ini', value: 'Rp ${_fmt(monthTotal)}')),
          const SizedBox(width: 10),
          Expanded(child: _SummaryCard(label: 'Transaksi Selesai', value: '$monthCount', color: AppColors.info)),
          const SizedBox(width: 10),
          Expanded(child: _SummaryCard(label: 'Rata-rata/Order', value: 'Rp ${_fmt(avg)}', color: AppColors.secondary)),
        ]),
        const SizedBox(height: 24),
        const Text('Pendapatan 6 Bulan Terakhir', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Container(
          height: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                    'Rp ${_fmt(rod.toY)}',
                    const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                  if (v.toInt() < buckets.length) {
                    return Padding(padding: const EdgeInsets.only(top: 4), child: Text(buckets[v.toInt()].label, style: const TextStyle(fontSize: 10)));
                  }
                  return const SizedBox.shrink();
                })),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(buckets.length, (i) {
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: buckets[i].value,
                    color: AppColors.primary,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ]);
              }),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Riwayat Transaksi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        if (history.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('Belum ada transaksi selesai', style: TextStyle(color: AppColors.textSecondary)),
          )
        else
          ...history.map((h) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(h.productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('${_dateStr(h.createdAt)} · ${h.consumerName}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ]),
                  ),
                  Text('Rp ${_fmt(h.total)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
                ]),
              )),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pencairan dana sedang diproses...'), backgroundColor: AppColors.primary)),
          icon: const Icon(Icons.account_balance_outlined, color: Colors.white),
          label: const Text('Cairkan Dana', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  static String _dateStr(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ]),
      );
}
