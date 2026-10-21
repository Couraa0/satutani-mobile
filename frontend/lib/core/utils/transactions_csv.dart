import 'package:intl/intl.dart';
import '../../data/mock/orders_mock.dart' show OrderStatusExt;
import '../../data/models/farmer_order.dart';

/// CSV riwayat transaksi petani, siap dibuka di Excel/Google Sheets.
///
/// - Pemisah `;` (default list separator Excel berbahasa Indonesia).
/// - Diawali BOM UTF-8 agar nama ber-aksen/emoji tidak rusak di Excel.
/// - Angka mentah tanpa "Rp"/titik ribuan supaya bisa dijumlah.
String buildTransactionsCsv(List<FarmerOrder> orders) {
  final date = DateFormat('yyyy-MM-dd HH:mm');
  final rows = <List<String>>[
    ['Tanggal', 'ID Pesanan', 'Produk', 'Jumlah', 'Satuan', 'Harga Satuan', 'Ongkir', 'Total', 'Pembeli', 'Telepon', 'Status'],
    for (final o in orders)
      [
        date.format(o.createdAt.toLocal()),
        o.id,
        o.productName,
        _num(o.quantity),
        o.unit,
        _num(o.pricePerUnit),
        _num(o.shippingCost),
        _num(o.total),
        o.consumerName,
        o.consumerPhone,
        o.status.label,
      ],
  ];
  return '﻿${rows.map((r) => r.map(_cell).join(';')).join('\r\n')}\r\n';
}

/// 12.0 -> "12", 2.5 -> "2,5" (koma desimal untuk Excel Indonesia).
String _num(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString().replaceAll('.', ',');

String _cell(String v) {
  // Cegah formula injection saat dibuka di spreadsheet (nama/telepon diisi pengguna lain).
  final safe = RegExp(r'^[=+\-@\t\r]').hasMatch(v) && double.tryParse(v.replaceAll(',', '.')) == null ? "'$v" : v;
  return RegExp(r'[;"\r\n]').hasMatch(safe) ? '"${safe.replaceAll('"', '""')}"' : safe;
}
