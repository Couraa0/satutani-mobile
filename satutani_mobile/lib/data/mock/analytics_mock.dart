class RevenueMonth {
  final String month;
  final double withMiddleman;
  final double direct;
  const RevenueMonth({required this.month, required this.withMiddleman, required this.direct});
}

class ForecastWeek {
  final String label;
  final Map<String, double> demandByKomoditas;
  const ForecastWeek({required this.label, required this.demandByKomoditas});
}

class ProvinceDemand {
  final String province;
  final Map<String, String> levelByKomoditas; // 'Tinggi', 'Sedang', 'Rendah'
  const ProvinceDemand({required this.province, required this.levelByKomoditas});
}

// 6-month revenue comparison (perantara vs SatuTani)
final List<RevenueMonth> mockRevenue = [
  const RevenueMonth(month: 'Okt', withMiddleman: 2100000, direct: 3800000),
  const RevenueMonth(month: 'Nov', withMiddleman: 1950000, direct: 3500000),
  const RevenueMonth(month: 'Des', withMiddleman: 2400000, direct: 4200000),
  const RevenueMonth(month: 'Jan', withMiddleman: 1800000, direct: 3200000),
  const RevenueMonth(month: 'Feb', withMiddleman: 2050000, direct: 3900000),
  const RevenueMonth(month: 'Mar', withMiddleman: 2300000, direct: 4500000),
];

// Demand forecast 4 minggu per 5 komoditas (unit: ton)
final List<ForecastWeek> mockForecast = [
  const ForecastWeek(label: 'Mg 1', demandByKomoditas: {
    'Bawang Merah': 45.0, 'Cabai': 38.0, 'Tomat': 52.0, 'Beras': 120.0, 'Sayuran': 85.0,
  }),
  const ForecastWeek(label: 'Mg 2', demandByKomoditas: {
    'Bawang Merah': 50.0, 'Cabai': 42.0, 'Tomat': 48.0, 'Beras': 130.0, 'Sayuran': 92.0,
  }),
  const ForecastWeek(label: 'Mg 3', demandByKomoditas: {
    'Bawang Merah': 55.0, 'Cabai': 60.0, 'Tomat': 44.0, 'Beras': 125.0, 'Sayuran': 110.0,
  }),
  const ForecastWeek(label: 'Mg 4', demandByKomoditas: {
    'Bawang Merah': 65.0, 'Cabai': 75.0, 'Tomat': 40.0, 'Beras': 140.0, 'Sayuran': 125.0,
  }),
];

// Demand per provinsi
final List<ProvinceDemand> mockProvinceDemand = [
  const ProvinceDemand(province: 'DKI Jakarta', levelByKomoditas: {
    'Bawang Merah': 'Tinggi', 'Cabai': 'Tinggi', 'Tomat': 'Sedang', 'Beras': 'Tinggi', 'Sayuran': 'Tinggi',
  }),
  const ProvinceDemand(province: 'Jawa Barat', levelByKomoditas: {
    'Bawang Merah': 'Sedang', 'Cabai': 'Sedang', 'Tomat': 'Tinggi', 'Beras': 'Tinggi', 'Sayuran': 'Tinggi',
  }),
  const ProvinceDemand(province: 'Jawa Tengah', levelByKomoditas: {
    'Bawang Merah': 'Tinggi', 'Cabai': 'Sedang', 'Tomat': 'Rendah', 'Beras': 'Sedang', 'Sayuran': 'Sedang',
  }),
  const ProvinceDemand(province: 'Jawa Timur', levelByKomoditas: {
    'Bawang Merah': 'Sedang', 'Cabai': 'Tinggi', 'Tomat': 'Sedang', 'Beras': 'Sedang', 'Sayuran': 'Rendah',
  }),
  const ProvinceDemand(province: 'Sumatera Utara', levelByKomoditas: {
    'Bawang Merah': 'Rendah', 'Cabai': 'Rendah', 'Tomat': 'Rendah', 'Beras': 'Tinggi', 'Sayuran': 'Sedang',
  }),
];

// Market events affecting demand
class MarketEvent {
  final String title, description, impact, emoji;
  const MarketEvent({required this.title, required this.description, required this.impact, required this.emoji});
}

final List<MarketEvent> mockMarketEvents = [
  const MarketEvent(
    emoji: '🌙', title: 'Ramadan (Apr 2026)',
    description: 'Permintaan sayuran naik signifikan selama bulan puasa',
    impact: '+45% demand sayuran',
  ),
  const MarketEvent(
    emoji: '🎊', title: 'Lebaran (Mei 2026)',
    description: 'Lonjakan kebutuhan beras dan bahan masakan rumahan',
    impact: '+60% demand beras & rempah',
  ),
  const MarketEvent(
    emoji: '🌧️', title: 'Musim Hujan (Mar-Mei)',
    description: 'Produksi cabai turun karena curah hujan tinggi',
    impact: '+30% harga cabai',
  ),
];
