class TraceabilityStep {
  final String icon, title, date, description;
  final bool isCompleted;
  const TraceabilityStep({
    required this.icon, required this.title, required this.date,
    required this.description, required this.isCompleted,
  });
}

class ColdChainPoint {
  final String time;
  final double temperature;
  final double humidity;
  const ColdChainPoint({required this.time, required this.temperature, required this.humidity});
}

class TraceabilityRecord {
  final String code, productName, farmerId, farmerName, farmerLocation;
  final String farmingMethod, fertilizer, pesticideHistory;
  final List<TraceabilityStep> journey;
  final List<ColdChainPoint> coldChain;
  const TraceabilityRecord({
    required this.code, required this.productName, required this.farmerId,
    required this.farmerName, required this.farmerLocation,
    required this.farmingMethod, required this.fertilizer, required this.pesticideHistory,
    required this.journey, required this.coldChain,
  });
}

final List<TraceabilityRecord> mockTraceability = [
  const TraceabilityRecord(
    code: 'TD-2026-001',
    productName: 'Beras Pandan Wangi Cianjur',
    farmerId: 'f2', farmerName: 'Siti Rahayu', farmerLocation: 'Cianjur, Jawa Barat',
    farmingMethod: 'Organik Bersertifikat',
    fertilizer: 'Kompos organik, pupuk kandang',
    pesticideHistory: 'Tidak menggunakan pestisida kimia. Pengendalian hama alami.',
    journey: [
      TraceabilityStep(icon: '🌱', title: 'Ditanam', date: '1 Jan 2026', description: 'Sawah Siti Rahayu, Cianjur — lahan 2 ha', isCompleted: true),
      TraceabilityStep(icon: '🌾', title: 'Dipanen', date: '5 Mar 2026', description: 'Panen raya — hasil 8 ton', isCompleted: true),
      TraceabilityStep(icon: '📦', title: 'Dikemas', date: '6 Mar 2026 08:00', description: 'Dikemas 25 kg/karung, label organik', isCompleted: true),
      TraceabilityStep(icon: '🌡️', title: 'Cold Storage', date: '6 Mar 2026 10:00', description: 'Suhu 18°C, kelembaban 65%', isCompleted: true),
      TraceabilityStep(icon: '🚛', title: 'Diambil Kurir', date: '7 Mar 2026 09:00', description: 'Kurir SatuTani Express', isCompleted: true),
      TraceabilityStep(icon: '🏠', title: 'Diterima', date: '8 Mar 2026 14:30', description: 'Diterima konsumen di Jakarta', isCompleted: true),
    ],
    coldChain: [
      ColdChainPoint(time: '06:00', temperature: 18.2, humidity: 65.0),
      ColdChainPoint(time: '08:00', temperature: 17.8, humidity: 64.5),
      ColdChainPoint(time: '10:00', temperature: 18.0, humidity: 65.2),
      ColdChainPoint(time: '12:00', temperature: 18.5, humidity: 66.0),
      ColdChainPoint(time: '14:00', temperature: 18.1, humidity: 65.5),
      ColdChainPoint(time: '16:00', temperature: 17.9, humidity: 64.8),
    ],
  ),
  const TraceabilityRecord(
    code: 'TD-2026-002',
    productName: 'Udang Vaname Segar',
    farmerId: 'f5', farmerName: 'Rudi Hartono', farmerLocation: 'Sidoarjo, Jawa Timur',
    farmingMethod: 'Budidaya Organik Tambak',
    fertilizer: 'Probiotik alami, pakan non-GMO',
    pesticideHistory: 'Bebas antibiotik dan bahan kimia berbahaya.',
    journey: [
      TraceabilityStep(icon: '🌊', title: 'Benih Ditebar', date: '1 Feb 2026', description: 'Tambak Pak Rudi, Sidoarjo — 5 kolam', isCompleted: true),
      TraceabilityStep(icon: '🦐', title: 'Dipanen', date: '1 Mar 2026', description: 'Panen udang segar — 500 kg', isCompleted: true),
      TraceabilityStep(icon: '📦', title: 'Dikemas', date: '1 Mar 2026 06:00', description: 'Dikemas 1 kg/pack vakum, coolbox', isCompleted: true),
      TraceabilityStep(icon: '🌡️', title: 'Cold Chain', date: '1 Mar 2026 07:00', description: 'Suhu 4°C sepanjang perjalanan', isCompleted: true),
      TraceabilityStep(icon: '🚛', title: 'Diambil Kurir', date: '2 Mar 2026 08:00', description: 'Armada pendingin SatuTani', isCompleted: true),
      TraceabilityStep(icon: '🏠', title: 'Diterima', date: '3 Mar 2026 13:00', description: 'Diterima konsumen — kondisi segar', isCompleted: true),
    ],
    coldChain: [
      ColdChainPoint(time: '07:00', temperature: 4.1, humidity: 90.0),
      ColdChainPoint(time: '09:00', temperature: 3.9, humidity: 89.5),
      ColdChainPoint(time: '11:00', temperature: 4.2, humidity: 90.2),
      ColdChainPoint(time: '13:00', temperature: 4.0, humidity: 90.0),
    ],
  ),
];
