import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/colors.dart';
import '../../../../data/mock/analytics_mock.dart';

class RevenueScreen extends StatelessWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final total = mockRevenue.fold(0.0, (s, r) => s + r.direct);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pendapatan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards row
          Row(children: [
            Expanded(child: _SummaryCard(label: 'Total Bulan Ini', value: 'Rp ${_fmt(total)}')),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard(label: 'Transaksi Selesai', value: '18', color: AppColors.info)),
            const SizedBox(width: 10),
            Expanded(child: _SummaryCard(label: 'Rata-rata/Order', value: 'Rp ${_fmt(total / 18)}', color: AppColors.secondary)),
          ]),
          const SizedBox(height: 24),
          // Chart title
          const Text('Perbandingan Pendapatan 6 Bulan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(children: [
            _Legend(color: AppColors.danger, label: 'Dengan Perantara'),
            const SizedBox(width: 16),
            _Legend(color: AppColors.primary, label: 'SatuTani'),
          ]),
          const SizedBox(height: 16),
          // Bar chart
          Container(
            height: 240,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10)]),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 5000000,
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
                    if (v.toInt() < mockRevenue.length) return Padding(padding: const EdgeInsets.only(top: 4), child: Text(mockRevenue[v.toInt()].month, style: const TextStyle(fontSize: 10)));
                    return const SizedBox.shrink();
                  })),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(mockRevenue.length, (i) {
                  final r = mockRevenue[i];
                  return BarChartGroupData(x: i, barsSpace: 4, barRods: [
                    BarChartRodData(toY: r.withMiddleman, color: AppColors.danger.withValues(alpha: 0.7), width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                    BarChartRodData(toY: r.direct, color: AppColors.primary, width: 12, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                  ]);
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Transaction history
          const Text('Riwayat Transaksi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._sampleHistory.map((h) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)]),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(h['product']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${h['date']} · ${h['buyer']}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ])),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(h['amount']!, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 13)),
                Text('Diterima: ${h['net']!}', style: const TextStyle(fontSize: 10, color: AppColors.success)),
              ]),
            ]),
          )),
          const SizedBox(height: 20),
          // Cairkan dana button
          ElevatedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pencairan dana sedang diproses...'), backgroundColor: AppColors.primary)),
            icon: const Icon(Icons.account_balance_outlined, color: Colors.white),
            label: const Text('Cairkan Dana', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static String _fmt(double v) => v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SummaryCard({required this.label, required this.value, this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    ]),
  );
}

class _Legend extends StatelessWidget {
  final Color color; final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
  ]);
}

const _sampleHistory = [
  {'product': 'Beras Pandan Wangi 10kg', 'date': '15 Mar 2026', 'buyer': 'Resto Makan Enak', 'amount': 'Rp 180.000', 'net': 'Rp 171.000'},
  {'product': 'Udang Vaname 2kg', 'date': '8 Mar 2026', 'buyer': 'Andi Pratama', 'amount': 'Rp 160.000', 'net': 'Rp 152.000'},
  {'product': 'Apel Manalagi 20kg', 'date': '12 Mar 2026', 'buyer': 'Hotel Grand Nusa', 'amount': 'Rp 440.000', 'net': 'Rp 418.000'},
];
